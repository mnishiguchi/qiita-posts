---
title: 'Tapyrus ブロックチェーンに挑戦: 環境構築（devモード）'
tags:
  - Docker
  - Bitcoin
  - Blockchain
  - Tapyrus
  - chaintope
private: false
updated_at: '2025-06-04T20:25:27+09:00'
id: 2cd72b485ddf2e178f3f
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

「ブロックチェーン技術を学びたい」と思いながらも、これまでなかなか行動に移せずにいました。  
ローカル環境で Tapyrus ブロックチェーンを触ってみることで、「ブロックチェーンとは何か？」を体験しながら学んでいきます。

本記事では、Tapyrus の dev モードを使って、最小構成の [Docker Compose][docker-compose-docs] 環境を構築する手順をまとめます。  

## Tapyrus とは

[Tapyrus][tapyrus-core-github] は、[Bitcoin][bitcoin-org] をベースにしたオープンソースのブロックチェーンプラットフォームです。日本の企業 [Chaintope][chaintope-site] によって開発されており、企業や自治体での実用を想定した設計が特徴です。

#### 主な特徴

- オープンソース: Bitcoin をフォークし、独自機能を追加
- ハイブリッド設計: 制御されたネットワークで運用しつつ、透明性も確保
- カスタムトークン: `OP_COLOR` による独自トークンの発行が可能

#### 資料

- [Chaintope 公式サイト][chaintope-site]
- [Tapyrus Core GitHub][tapyrus-core-github]
- [Tapyrus Docker ドキュメント][tapyrus-core-docs-docker]

## 手元の環境

今回の動作確認は、以下のローカル環境で行いました。

- OS：LMDE 6（Linux Mint Debian Edition）
- [Docker][docker-site]：28.2.2
- [Docker Compose][docker-compose-docs]：v2.36.2
- シェル：[bash][bash-site]
- その他：インターネット接続（イメージ取得のため）

※ Docker 環境があれば、macOS や WSL2 でも同様に動くはずです。

## Tapyrus 環境構築の概要

今回は Tapyrus の dev モード（開発・テスト用モード）を使って、単一ノード構成の最小ブロックチェーン環境を [Docker Compose][docker-compose-docs] で構築します。  
短時間でセットアップでき、動作確認や [RPC][rpc-wiki] の試行にも便利です。

以下のようなディレクトリ構成を前提として進めます：

```bash
├── docker-compose.yml  # Tapyrus ノードと Ruby クライアントを定義
├── tapyrus.conf        # ノードの設定ファイル（dev モード用）
├── data/               # ブロックチェーン・ウォレットの永続化領域
└── tapyrus-client/
    └── Dockerfile.dev  # tapyrus gem を含んだ Ruby IRB 環境
````

この環境はすべてローカルで完結しており、他のノードやインターネットへの常時接続も不要です。
外部ネットワークとつながない単一ノード構成なので、自分のマシンだけで安全にブロックチェーンを試せます。

## `docker-compose.yml` の内容

ここでは、Tapyrus ノード（`tapyrusd`）と、Ruby 製クライアント（`tapyrus-client`）の 2 つのサービスを定義しています。

```yaml
services:
  tapyrusd:
    image: tapyrus/tapyrusd:v0.6.1
    ports:
      - "2377:2377"
    environment:
      GENESIS_BLOCK_WITH_SIG: |
        0100000000000000000000000000000000000000000000000000000000000000000000002b5331139c6bc8646bb4e5737c51378133f70b9712b75548cb3c05f9188670e7440d295e7300c5640730c4634402a3e66fb5d921f76b48d8972a484cc0361e66ef74f45e012103af80b90d25145da28c583359beb47b21796b2fe1a23c1511e443e7a64dfdb27d40e05f064662d6b9acf65ae416379d82e11a9b78cdeb3a316d1057cd2780e3727f70a61f901d10acbe349cd11e04aa6b4351e782c44670aefbe138e99a5ce75ace01010000000100000000000000000000000000000000000000000000000000000000000000000000000000ffffffff0100f2052a010000001976a91445d405b9ed450fec89044f9b7a99a4ef6fe2cd3f88ac00000000
    volumes:
      - ./tapyrus.conf:/etc/tapyrus/tapyrus.conf
      - ./data:/root/.tapyrus

  tapyrus-client:
    build:
      context: ./tapyrus-client
      dockerfile: Dockerfile.dev
    depends_on:
      - tapyrusd
    environment:
      TAPYRUS_RPC_HOST:     "tapyrusd"
      TAPYRUS_RPC_PORT:     "2377"
      TAPYRUS_RPC_USER:     "rpcuser"
      TAPYRUS_RPC_PASSWORD: "rpcpassword"
    tty: true
    stdin_open: true
```

### 各サービスの役割

#### `tapyrusd`（ノード）

* Tapyrus Core の公式イメージを使って、dev モードのノードを起動。
* `GENESIS_BLOCK_WITH_SIG` により、初期ブロック生成を省略し即起動。
* `tapyrus.conf` で各種設定を行い、ブロックチェーンデータは `./data` に永続化。

#### `tapyrus-client`（Ruby クライアント）

* `tapyrus` gem を入れた [Ruby][ruby-site] イメージをビルドし、[IRB][irb-docs]（対話環境）を起動。
* 起動時に `$client` が自動で生成され、すぐにノードと RPC でやり取り可能。

## `tapyrus-client/Dockerfile.dev` の内容

Tapyrus に接続するための Ruby クライアント用 Docker イメージは、以下のような構成になっています。

```dockerfile
FROM ruby:3.4.2-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libssl-dev \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN gem install tapyrus -v "~> 0.3.9" --no-document

RUN cat << 'EOF' > /root/.irbrc
require 'tapyrus'

$client = Tapyrus::RPC::TapyrusCoreClient.new(
  schema:   'http',
  host:     ENV.fetch('TAPYRUS_RPC_HOST')     { abort "Missing ENV[TAPYRUS_RPC_HOST]" },
  port:     ENV.fetch('TAPYRUS_RPC_PORT')     { abort "Missing ENV[TAPYRUS_RPC_PORT]" },
  user:     ENV.fetch('TAPYRUS_RPC_USER')     { abort "Missing ENV[TAPYRUS_RPC_USER]" },
  password: ENV.fetch('TAPYRUS_RPC_PASSWORD') { abort "Missing ENV[TAPYRUS_RPC_PASSWORD]" }
)

puts "→ $client ready (#{ENV['TAPYRUS_RPC_HOST']}:#{ENV['TAPYRUS_RPC_PORT']})"
EOF

CMD ["irb", "-r", "tapyrus"]
```

### 各ステップの説明

#### ベースイメージの選定

* `ruby:3.4.2-slim` を使用（軽量で必要最小限）。
* C 拡張ビルド用に `build-essential`, `libssl-dev` を追加。

#### `tapyrus` gem の導入

* RPC クライアントとして `tapyrus` をインストール。

#### `.irbrc` による初期化

* [IRB][irb-docs] 起動時に `$client` を自動生成。
* 接続情報は環境変数から取得。

#### IRB の起動設定

* `CMD` により `tapyrus` 読み込み済みの IRB を起動。
* `$client.getblockchaininfo` などがすぐ使える状態に。

## `tapyrus.conf` の内容

Tapyrus ノードの dev モード動作用の設定ファイルです。
以下のような内容になっています：

```toml
networkid=1905960821
dev=1

[dev]
server=1
keypool=1
discover=0
bind=127.0.0.1

rpcuser=rpcuser
rpcpassword=rpcpassword
rpcallowip=0.0.0.0/0
rpcport=2377
```

### 各設定項目の説明

#### ネットワーク設定

* `networkid=1905960821`
  開発用ネットワーク ID。`GENESIS_BLOCK_WITH_SIG` と一致させる必要あり。
* `dev=1`
  dev モードを有効化（ジェネシスブロック自動インポートなどが有効に）。

#### dev セクションの設定

* `server=1`
  JSON-RPC を有効化。外部からコマンドを受け付けられるように。
* `keypool=1`
  鍵を事前生成しておき、`getnewaddress` の待ち時間を削減。
* `discover=0`
  ピア探索を無効化。単一ノード構成向け。
* `bind=127.0.0.1`
  ノードのバインド先。ローカルホスト内の通信のみ許可。

#### RPC 認証・接続設定

* `rpcuser` / `rpcpassword`
  RPC のユーザー名・パスワード。Docker 側の環境変数と一致させる必要あり。
* `rpcallowip=0.0.0.0/0`
  全ての IP を許可（※ dev モード限定で想定）。
* `rpcport=2377`
  JSON-RPC の待ち受けポート。`docker-compose.yml` のポートと合わせる。

## 動作確認・操作例

セットアップが完了したら、以下の手順で Tapyrus ノードを起動し、Ruby クライアントから接続してみましょう。

### 1. ノードを起動

```bash:ターミナル
docker compose up tapyrusd
```

* Tapyrus ノードが dev モードで起動します。
* `GENESIS_BLOCK_WITH_SIG` により、ブロックチェーンが即座に初期化されます。
* RPC サーバがポート `2377` で待ち受け状態になります。

### 2. Ruby クライアントを起動

別ターミナルで以下を実行：

```bash:ターミナル
docker compose run --rm tapyrus-client
```

* `tapyrus` を読み込んだ [IRB][irb-docs] セッションが起動。
* 起動時に `$client` が定義されており、すぐに [RPC][rpc-wiki] を試せます。

### 3. 何か試してみる

ノードのブロックチェーン情報が表示されれば接続成功です。

```ruby:irb
$client.getblockchaininfo
```

### 4. クリーンアップ

以下のコマンドで、コンテナとボリュームを削除して、環境を初期化できます。

```bash:ターミナル
docker compose down --volumes --remove-orphans
```

## おわりに

本記事では、Tapyrus の dev モードを使ってローカル環境に最小構成のブロックチェーンノードを立ち上げ、Ruby クライアントから接続して簡単な RPC を試すところまでを紹介しました。

[Docker Compose][docker-compose-docs] を使うことで、複雑なビルドや依存関係を気にせず、手元でブロックチェーンの挙動を確認できるのはとても便利だと感じました。

今回は「まずは Tapyrus を動かしてみる」ことを主な目的としましたが、今後はトランザクション生成など、もう一歩踏み込んだ内容にも挑戦していく予定です。

Tapyrus を通じて、ブロックチェーンの基本を一緒に学んでいきましょう！

---

## 資料

* [Tapyrus Core GitHub][tapyrus-core-github]
* [Tapyrus Docker イメージ][tapyrusd-docker-hub]
* [Tapyrus 開発者向けドキュメント（Docker）][tapyrus-core-docs-docker]
* [Tapyrus 開発者向けドキュメント（Getting Started）][tapyrus-core-docs-getting-started]
* [Tapyrus Ruby gem (tapyrusrb)][tapyrusrb]
* [Chaintope 公式サイト][chaintope-site]
* https://qiita.com/John110/items/0ac6deb458af976b0cf8

<!-- リンク定義 -->

[bitcoin-org]: https://bitcoin.org/
[bash-site]: https://www.gnu.org/software/bash/
[chaintope-site]: https://www.chaintope.com/
[docker-site]: https://www.docker.com/
[docker-compose-docs]: https://docs.docker.com/compose/
[irb-docs]: https://docs.ruby-lang.org/ja/latest/library/irb.html
[rpc-wiki]: https://ja.wikipedia.org/wiki/Remote_Procedure_Call
[ruby-site]: https://www.ruby-lang.org/
[tapyrus-core-github]: https://github.com/chaintope/tapyrus-core
[tapyrus-core-docs-docker]: https://github.com/chaintope/tapyrus-core/blob/master/doc/docker_image.md
[tapyrus-core-docs-getting-started]: https://github.com/chaintope/tapyrus-core/blob/master/doc/tapyrus/getting_started.md
[tapyrusrb]: https://github.com/chaintope/tapyrusrb
[tapyrusd-docker-hub]: https://hub.docker.com/r/tapyrus/tapyrusd
