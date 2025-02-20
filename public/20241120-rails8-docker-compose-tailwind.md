---
title: Rails 8 で Tailwind CSS に挑戦
tags:
  - Rails
  - Docker
  - tailwindcss
  - Rails8
private: false
updated_at: '2025-02-12T17:55:40+09:00'
id: d8d9d092fa4e786a37ba
organization_url_name: haw
slide: false
ignorePublish: false
---
[daisyUI]: https://daisyui.com
[Tailwind CSS]: https://tailwindcss.com
[Rails 8]: https://edgeguides.rubyonrails.org/8_0_release_notes.html
[rails new]: https://guides.rubyonrails.org/command_line.html#creating-a-rails-app

## はじめに

[Rails 8] で、いろんな新しい機能や改善点が追加されたようです。
本記事では、手を動かしながら[Rails 8] で [Tailwind CSS]の設定に挑戦した結果を記録します。

## 前提

- OS: Linux Mint Debian Edition 6
- Ruby: 3.3.5
- Rails: 8.0.0
- Docker: 27.3.1
- Docker Compose: 2.29.7

## 本件に取り組んだ経緯

以前、Elixir の Web 開発フレームワークである Phoenix を用いて、同様の構成でプロジェクトを構築した経験があります。この際、Phoenix の環境構築の手軽さや生産性の高さを実感しました。

一方で、[Rails 8] でも同じような構成を試してみたくなり、今回の記事ではその手順や学びを共有します。特に Docker Compose を活用した開発環境の構築や Tailwind CSS の導入に注目しました。

参考までに、以前投稿した Phoenix 関連の記事は以下の通りです。

https://qiita.com/mnishiguchi/items/11bd7a1e1784fc86dacc

https://qiita.com/mnishiguchi/items/6f219be33384cd36e836

## Rails プロジェクトの作成

Rails プロジェクトを作成する方法はいくつかありますが、今回はあえて [Docked Rails CLI] を利用します。このツールを使うことで、PC に Ruby を直接インストールしていなくても、Rails アプリの作成が可能になります。

通常の Docker コマンドでも Rails プロジェクトを作成できますが、[Docked Rails CLI] を利用することで、面倒な設定を省略し、すぐに Rails プロジェクトを生成できるのがうれしい氣がしています。

[Docked Rails CLI]の利用には Docker がインストールされているのが前提です。

```bash
docker --version
```

Docked Rails CLI を[公式ドキュメント][Docked Rails CLI]にしたがって準備します。

```bash
docker volume create ruby-bundle-cache
alias docked='docker run --rm -it -v ${PWD}:/rails -u $(id -u):$(id -g) -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'
```

任意の作業場所に移動します。

```bash
cd ~/my/workspace
```

`rails new` コマンドを用いて、任意の名称の Rails プロジェクトを作成します。

```bash
docked rails _8.0.0_ new sample_app --database=postgresql --css=tailwind --skip-bundle
```

:::note info
オプションの説明

- `--database=postgresql` - デフォルトの SQLite ではなく PostgreSQL データベースを使用
- `--css=tailwind` - Tailwind CSS のセットアップを含めてプロジェクトを生成
- `--skip-bundle` - Gem のインストールは後から実行したいので、自動インストールを行わないようにする
:::

[Docked Rails CLI]: https://github.com/rails/docked

生成された Rails プロジェクトのディレクトリに移動します。

```bash
cd sample_app
```

後に作成する`Dockerfile` で`Gemfile.lock` を コピーする手順があるので、予め空のファイル `Gemfile.lock` を生成して `Dockerfile` のビルドができるように準備しておきます。

```bash
touch Gemfile.lock
```

### 開発用 Dockerfile の作成

[本番用に使える Dockerfile]: https://github.com/rails/rails/blob/6230bd334ab47f9efc6d97c6627abe76c80d8058/railties/lib/rails/generators/rails/app/templates/Dockerfile.tt

Rails 8 の [rails new] コマンドにより生成される Rails プロジェクトには、デフォルトで[本番用に使える Dockerfile] が含まれています。この Dockerfile の冒頭には以下のコメントが記載されています。

> This Dockerfile is designed for production, not development.

このため、本番環境用の Dockerfile とは別に、簡易的な開発用の Dockerfile を作成することにしました。以下はその手順です。

#### 1. 本番用 Dockerfile のバックアップ
まず、デフォルトの `Dockerfile` を `Dockerfile.prod` という名前に変更し、本番環境用として保持します。

```bash
mv Dockerfile Dockerfile.prod
```
#### 2. 開発用 Dockerfile の作成
次に、`Dockerfile.dev` という名前で新しい Dockerfile を作成します。以下の内容を含む開発用 Dockerfile を作成します。

```Dockerfile
ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev

# アプリケーションディレクトリを作成
RUN mkdir /myapp
WORKDIR /myapp

# Gemfile と Gemfile.lock をコピーし、依存関係をインストール
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# アプリケーションの全ファイルをコンテナ内にコピー
ADD . /myapp
```

:::note info
- [docs.docker.jp]の[クィックスタート: Compose と Rails]が参考になりました。
- RUBY_VERSIONは Rails 8 プロジェクトのRubyバージョンと一致させています。
- vim は、コンテナ内での編集が必要な場合に備えて追加しています（任意）。
:::

[docs.docker.jp]: https://docs.docker.jp/compose/rails.html
[クィックスタート: Compose と Rails]: https://docs.docker.jp/compose/rails.html

### 開発用 docker-compose.yml の作成

Rails アプリの開発環境用にマルチコンテナ構成を定義する最低限の`docker-compose.yml` ファイルを作成します。

このファイルでは以下を構成します。

- Web コンテナ: Rails アプリケーションのコードを実行するコンテナ。
- DB コンテナ: PostgreSQL をホストするコンテナ。

```yaml
cat <<'EOF' > docker-compose.yml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    entrypoint: ["bin/docker-entrypoint"]
    command: bash -c "rm -f tmp/pids/server.pid && ./bin/dev -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/myapp
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:17-alpine
    ports:
      - 5432:5432
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - db_data:/var/lib/postgresql/data
volumes:
  db_data: {}
EOF
```

:::note info
データベース接続情報の整合性

Rails アプリケーション側の `config/database.yml` ファイルでも、db サービスのホスト名 (db)、ユーザー名 (postgres)、パスワード (postgres) を指定してください。
:::

### config/database.yml の編集

Docker 環境で定義された`db`サービスに接続するために必要な情報（ホスト名、ユーザー名、パスワード）を追加して、Rails アプリがデータベースと正しく通信できるようにします。

```diff_yaml
 default: &default
   adapter: postgresql
   encoding: unicode
   # For details on connection pooling, see Rails configuration guide
   # https://guides.rubyonrails.org/configuring.html#database-pooling
   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

 development:
   <<: *default
   database: sample_app_development
+  host: db
+  username: postgres
+  password: postgres

 test:
   <<: *default
   database: sample_app_test
+  host: db
+  username: postgres
+  password: postgres
...
```

### データベースを準備

コンテナの中で`./bin/rails db:prepare`コマンドを実行し、データベースの準備をします。

```bash
docker compose run --rm web rails db:prepare
```

### Rails アプリを起動

以下のコマンドを打ち、Rails アプリと依存するサービスを起動します。

```bash
docker compose up
```

この状態でウエブブラウザで http://localhost:3000 を開くとおなじみの Rails 8 のデフォルトの頁が表示されます。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/83cab03c-3034-c9d5-3ab9-b716fc1c99ce.png)

### ページをひとつ作成

後にTailwind CSSのインストールを確認できるよう、簡単な静的ページを作成します。

新しいターミナルを開き、以下のコマンドを実行して、最低限必要なルート、コントローラー、ビューを生成します。

```bash
docker compose run --rm web bin/rails generate controller Pages home
```

:::note info
ファイルマウントの権限問題

Linux 環境で Docker を利用している場合、Docker コンテナが `root` ユーザー権限で実行されるため、ホスト側のディレクトリに作成されるファイルの所有者が `root` になることがあります。

たとえば、`rails new` やその他のコマンドで生成されたファイルが `root` ユーザーの所有となり、編集や削除に問題が生じることがあります。この場合、以下のコマンドを使用してファイルの所有権を修正してください。

```bash
sudo chown -R $USER:$USER .
```
:::

これが完了したら、ウェブブラウザで http://localhost:3000/pages/home を開いて、生成されたページを確認します。

### bin/devコマンド

`./bin/dev` コマンドは、Rails 7以降でデフォルトで導入された開発環境用のコマンドです。

先程作成した`docker-compose.yml`では`web` サービスを起動するコマンドとして利用しています。

Rails 7ではforemanなどのプロセスマネージャを利用して、複数のプロセス（例：Railsサーバー、WebpackerまたはVite、Redisなど）を同時に起動・管理するのに利用されていました。

Rails 8では、このコマンドの中身が簡素化され、より統一的な方法で開発環境を起動できるようになりました。以下はDHH氏の[プルリクエスト](https://github.com/rails/rails/pull/52433)に記載されているコメントです。

> Add bin/dev by default
> Then we have a uniform way of starting dev mode whether someone is using jsbundling or importmaps.
> This can also be overwritten by teams using docker compose or the like to boot their dev modes.

以下はその意訳です。

> `./bin/dev` コマンドを使えば、JavaScriptのビルドツール（例：jsbundling）や importmaps の使用有無に関わらず、同じ方法で開発サーバーを起動できます。
> また、チーム独自の設定（例：Docker Composeの利用）に合わせて上書きも可能です。

Rails 8のデフォルトは、以下のようなシンプルな実装になっています。

```rb
#!/usr/bin/env ruby
exec "./bin/rails", "server", *ARGV
```

例えば、`tailwindcss-rails` はインストール時にこのコマンドの内容を上書きします。詳しくは以下のリンクを参照してください。

- [tailwindcss-rails #385](https://github.com/rails/tailwindcss-rails/pull/385)
- [tailwindcss-rails/lib/install/dev](https://github.com/rails/tailwindcss-rails/blob/main/lib/install/dev)

### Tailwind CSSのインストール

次に、Tailwind CSSをインストールします。

`tailwindcss-rails` は、Rails 8のデフォルトの `bin/dev` やその他のファイルの内容を上書きします。
ですので、今の設定に満足している場合は、Tailwind CSSをインストールする前に、問題が起きたときに備えてファイルをバックアップしておくのがいいかもしれません。

以下のコマンドで、Tailwind CSSをセットアップできます。

```bash
docker compose run --rm web bin/rails tailwindcss:install
```

ただし、`tailwindcss-rails` によって更新された `bin/dev` は、僕の Docker Compose 環境では正しく動作しませんでした。

そこで、Rails 8 のデフォルトで提供されているシンプルな `bin/dev` の内容を使用することにしました。

```rb
#!/usr/bin/env ruby
exec "./bin/rails", "server", *ARGV
```

セットアップ後に生成されたファイルを見ると、`Procfile.dev` が作成され、それに伴い `bin/dev` では Foreman を利用してアプリケーションを動作させる構成となっていました。今回は Foreman を使用しないため、以下のコマンドで `Procfile.dev` を削除しました。

```bash
rm Procfile.dev
```

なお、これらのファイルは必要になった場合、簡単に再生成できますので心配はありません。

### config/puma.rb の編集

Tailwind CSSのリアルタイムリビルドを有効にするため、`tailwindcss-rails` gemが提供するPuma用プラグインを利用します。このプラグインを使うことで、コード編集後すぐに変更が反映されるようになります。

詳しくは、[公式ドキュメント](https://github.com/rails/tailwindcss-rails#live-rebuild)を参照してください。

以下のように `config/puma.rb` にプラグインを追加します。

```diff_ruby
+ plugin :tailwindcss if ENV.fetch("RAILS_ENV", "development") == "development"
```

これでTailwind CSSのスタイルが適用されているはずです！

試しに`app/views/pages/home.html.erb` に色々変更を加えてみてください。

### もうちょっと Tailwind CSS っぽいスタイリングにしてみる

Tailwind CSS の基本的なスタイリングクラスを試してみます。
以下のコードで `app/views/pages/home.html.erb` の中身を入れ替えてみてください。

```html
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  <div class="text-center py-16">
    <h1 class="text-4xl font-bold text-gray-900 sm:text-5xl">
      Welcome to MyApp
    </h1>
    <p class="mt-4 text-lg text-gray-500">
      Peace of mind from prototype to production. Build faster, deploy easier.
    </p>
    <div class="mt-6">
      <a href="#" class="px-6 py-3 bg-indigo-600 text-white text-lg font-semibold rounded-md hover:bg-indigo-500">
        Get Started
      </a>
    </div>
  </div>
</div>
```

以下のようなページが表示されるはずです。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/bdf896de-6344-24c5-9a87-c9b9806e9c6f.png)

:tada::tada::tada:

### さいごに

以上で、Rails 8 における Tailwind CSS の設定手順をご紹介いたしました。
このプロセスを通じて、Docked Rails CLI や Docker Compose を活用し、効率的な開発環境を構築する方法を学ぶことができました。

さらに、柔軟性の高いスタイリングを実現する非常に強力なツールである Tailwind CSS を比較的かんたんに導入できることも確認できました。

次のステップとして、Rails 8 の新機能をさらに探求したりすることで、開発の幅を広げていきたいと思います。
