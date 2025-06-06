---
title: 'Tapyrus ブロックチェーンに挑戦: RPC を叩いてみる'
tags:
  - Docker
  - Bitcoin
  - Blockchain
  - Tapyrus
  - chaintope
private: false
updated_at: '2025-06-11T11:02:12+09:00'
id: 56c56d13f1f57b56537e
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

「ブロックチェーン技術を学びたい」と思いながらも、なかなか行動に移せずにいました。
ローカル環境で Tapyrus ブロックチェーンを触ってみることで、「ブロックチェーンとは何か？」を体験しながら学んでいきます。

本記事では、[前回の記事](https://qiita.com/mnishiguchi/items/2cd72b485ddf2e178f3f) で構築した Docker Compose 環境をもとに、  
Ruby 製クライアント（[`tapyrusrb` gem][tapyrusrb]）から Tapyrus ノードに JSON-RPC 経由でリクエストを送り、基本的な操作を試してみます。

以下の 3 コマンドを通じて、RPC の流れを体験します：

1. `getblockchaininfo` — チェーン情報の取得
2. `getnewaddress` — 新しいアドレスの生成
3. `listunspent` — 未使用トランザクション出力（UTXO）の確認

## Tapyrus とは

[Tapyrus][tapyrus-core-github] は [Bitcoin][bitcoin-org] をベースにしたオープンソースのブロックチェーンプラットフォームで、日本の企業 [Chaintope][chaintope-site] によって開発されています。企業や自治体での実用を想定した設計が特徴です。

## 手元の環境

今回の動作確認は以下のローカル環境で行いました：

* OS：LMDE 6（Linux Mint Debian Edition）
* [Docker][docker-site]：28.2.2
* [Docker Compose][docker-compose-docs]：v2.36.2
* シェル：[bash][bash-site]
* その他：インターネット接続（イメージ取得のため）

※ Docker 環境があれば、macOS や WSL2 でも同様に動くはずです。

## よく使われる RPC コマンド

Tapyrus（および Bitcoin Core）は [JSON-RPC][rpc-wiki] を通じてノードやウォレットを操作できます。  
ここでは、特に代表的なコマンドを紹介します。

| コマンド                         | 説明                                                                                   |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| `getblockchaininfo`          | ブロックチェーン全体の状態を取得（最新ブロック数、難易度、同期状況など）                              |
| `getnetworkinfo`             | ネットワーク設定や接続情報を取得（プロトコルバージョン、接続中のノード数、サポートするサービスなど）       |
| `getblockcount`              | 現在のブロック数（チェーンの高さ）を取得                                                  |
| `getblockhash <height>`      | 指定したブロック高さ（`height`）のブロックハッシュを取得                                 |
| `getblock <blockhash>`       | 指定したブロックハッシュのブロック情報を取得（取得時に `verbosity` パラメータを指定可能。トランザクション一覧などを含む） |
| `getrawtransaction <txid>`   | 指定したトランザクションID（`txid`）の生データ（hex形式）を取得                           |
| `decoderawtransaction`       | 生トランザクション（hex）を人間が読める JSON 形式にデコード                             |
| `getnewaddress`              | 新しいウォレットアドレスを生成                                                       |
| `getwalletinfo`              | 現在アクティブなウォレットの情報を取得（残高やアカウント数など）                          |
| `getbalance`                 | デフォルトアカウント（もしくは指定アカウント）の現在のウォレット残高を取得                       |
| `listunspent`                | ウォレット内の UTXO（未使用出力）の一覧を取得                                         |
| `sendtoaddress <addr> <amt>` | 指定したアドレス（`addr`）に指定金額（`amt`）を送金                                     |
| `settxfee <amt>`             | トランザクション手数料を設定（以降、新しいトランザクションにはこの手数料が適用される）                   |

今回は、特に以下の 3 つに絞って試していきます：

* チェーン情報の取得（`getblockchaininfo`）
* アドレス生成（`getnewaddress`）
* UTXO の確認（`listunspent`）

## 実際に RPC を叩いてみる

以下は、[前回の記事](https://qiita.com/mnishiguchi/items/2cd72b485ddf2e178f3f) で構築した Docker Compose 環境が既に起動している前提です。

### Tapyrus ノードをバックグラウンドで起動

```bash:ターミナル
docker compose up -d tapyrusd
```

### Ruby クライアントで IRB を起動

```bash:ターミナル
docker compose run --rm tapyrus-client
```

```txt:IRB
irb(main):001:0>
```

この時点で `$client` が`Tapyrus::RPC::TapyrusCoreClient` のインスタンスとして利用可能です。これで RPC 接続の準備は完了です。

### `getblockchaininfo` — チェーン情報の取得

まずはチェーンの基本情報を取得してみます。

```ruby:IRB
irb> info = $client.getblockchaininfo
#=> {
#     "chain" => "1905960821",
#     "mode"  => "dev",
#     "blocks"=> 0,
#     "headers"=> 0,
#     …（省略）…
#   }
```

* `mode: "dev"` → 現在 dev モードで動作している
* `blocks: 0` → まだブロックは生成されていない
* 正常にレスポンスが返っていることで、RPC 接続が機能していると確認できます

### `getnewaddress` — アドレスの生成

次にウォレットから新しいアドレスを作成します。

```ruby:IRB
irb> address = $client.getnewaddress
#=> "TmTzQ6yvJqSRtCgzBArg2YxwFqvYpabdGe"
```

* dev モード用（テストネット相当）のアドレスが返ってきます
* 今後このアドレス宛にブロック報酬をマイニングすれば、残高が得られます

### `listunspent` — UTXO の確認

最後に、ウォレットが保持する UTXO（未使用出力）を確認してみます。

```ruby:IRB
irb> $client.listunspent
#=> []
```

* 現時点ではまだブロック生成をしていないため、UTXO は存在せず空配列が返ります。
* 実際にブロックをマイニングすれば、ここに UTXO が表示されるようになります。

## おわりに

本記事では、Tapyrus ノードに対して基本的な RPC を実行し、以下の流れを体験しました：

* ノードの状態を確認（`getblockchaininfo`）
* 新しいアドレスを取得（`getnewaddress`）
* ウォレット内の UTXO を確認（`listunspent`）

これにより、外部アプリケーションが JSON-RPC を通じてノードとやり取りする基本的な仕組みを体験できました。

次回は、実際にブロックをマイニングして UTXO を生成し、`listunspent` の結果がどう変わるかを確認してみる予定です。

## 資料

* [Tapyrus Core GitHub][tapyrus-core-github]
* [Tapyrus Docker イメージ][tapyrusd-docker-hub]
* [Tapyrus 開発者向けドキュメント（Docker）][tapyrus-core-docs-docker]
* [Tapyrus 開発者向けドキュメント（Getting Started）][tapyrus-core-docs-getting-started]
* [Tapyrus Ruby gem (tapyrusrb)][tapyrusrb]
* [Chaintope 公式サイト][chaintope-site]
* https://qiita.com/mnishiguchi/items/2cd72b485ddf2e178f3f
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
