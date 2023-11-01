---
title: Phoenix Docker コンテナをさまざまな開発マシンで動かす
tags:
  - Bash
  - Elixir
  - Docker
  - Phoenix
  - docker-compose
private: false
updated_at: '2023-11-10T08:13:41+09:00'
id: e367743bca3520e2a387
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Docker] コンテナ と [Docker Compose] を利用して、さまざまなマシンで [Phoenix] アプリを開発する方法について考えます。

## @koyo-miyamura さんの記事

やり方や問題点については、[@koyo-miyamura さんの記事]に詳しく解説されています。

https://qiita.com/koyo-miyamura/items/a609de2e9fadaf198243

https://github.com/koyo-miyamura/elixir_phoenix_docker

https://moneyforward-dev.jp/entry/2023/08/31/100000

よって、題目の課題自体は同記事を読めば解決してしまいます。

本記事では、[@koyo-miyamura さんの記事]で未解決の部分に挑戦してみたいと思います。

[Phoenix]: https://www.phoenixframework.org/
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[Docker]: https://docs.docker.jp/get-started/overview.html
[Docker Compose]: https://docs.docker.com/compose
[@koyo-miyamura さんの記事]: https://qiita.com/koyo-miyamura/items/a609de2e9fadaf198243
[Linux]: https://ja.wikipedia.org/wiki/Linux

## 未解決の部分

未解決の部分とは、具体的にはこれらの問題です。

### 問題1

> これで解決・・・と思いきや Mac 環境で上記の `Dockerfile` をビルドしてみると問題が発生してしまいます。
どうも Mac 側の GID と衝突してしまうよう・・・（いい回避策知ってたら教えてくださいｗ）。

### 問題2

> 今回のDockerfileは一例ですので、alpineを使わないようにしてみるなど、プロジェクトの構成に併せて適宜カスタマイズしてみてください！（alpine使わずに動かす Dockerfile 書いたらぜひ記事にして教えてください！）

[オープンソースソフトウェア]のコミュニティではこういうのを見て見ぬ振りするのは好ましくありません。何らかの恩返しを試みます！

## オープンソースソフトウェア

> オープンソースソフトウェアの利用者は共同開発者のように扱われる。利用者はソフトウェアのソースコードにアクセスすることができ、ソフトウェアへの機能追加、ソースコードの修正、バグの報告、ドキュメントの提出が可能である。利用者はそれらをソフトウェア開発のメインストリームに反映することができるし、利用者が望むのであれば自身の製品として頒布することもできる。オープンソースソフトウェアで複数の共同開発者を持つことは、ソフトウェアの発展を手助けする。-- [Wikipedia][オープンソースソフトウェア]

[オープンソースソフトウェア]: https://ja.wikipedia.org/wiki/オープンソースソフトウェア

## 実行環境

### macOS
```
OS: macOS 13.5.2 22G91 arm64
Host: MacBookPro18,1
Kernel: 22.6.0
```

```
Docker version 24.0.6, build ed223bc
Docker Compose version v2.23.0-desktop.1
```

### Linux

```
OS: Arch Linux x86_64
Host: MacBookAir7,2 1.0
Kernel: 6.5.9-arch2-1
```

```
Docker version 24.0.7, build afdd53b4e3
Docker Compose version 2.23.0
```

### Elixir

- Elixir:  1.15.7
- Erlang:  26.1
- Phoenix: 1.7.10

## 問題1: Mac 側の GID が衝突してしまう

厳密にいうと [@koyo-miyamura さんの記事]で既に解決されています。[@koyo-miyamura さんの記事]ではマルチステージビルドで２種類のビルドターゲットを用意し、ホストマシンのOSに応じて使い分けるという技で解決されていました。しかしながら、ホストマシンを設定する人間が自分で判断してセットアップ手順を使い分けないといけないという問題は残ります。

ここでは、ビルドターゲットを分けずに共通のセットアップ手順で解決する方法に取り組んでみます。

### 解決案

`Dockerfile` の中でホストマシンの OS により条件分岐するというやり方を検討してみようと思います。

[@koyo-miyamura さんの記事]で、問題の現象が macOS で group の設定を行うときだけに起きることがわかっているので、ホストマシンが macOS の時に group の設定をやらないようにすれば上手くいくはずです。

それを実現するには、いくつか調査が必要です。

- `Dockerfile` の中で条件分岐するスクリプトを書く方法
- `Dockerfile` の中でホストマシンの OS を検知する方法

同様の問題に取り組んでいる Github Issue を一つ見つけました。

https://github.com/pyro-ppl/pyro/issues/700

https://github.com/pyro-ppl/pyro/pull/719/files

#### Dockerfile の中で条件分岐するスクリプトを書く方法

調査したところ、簡単そうなのは [RUN] や [ENTRYPOINT] で普通にシェルスクリプトを書くというやり方です。

[RUN] を使って直接 `Dockerfile` の中でスクリプトを書くことにします。

```Dockerfile:例
RUN echo piyopiyo
```

[RUN] が水面下で `/bin/sh -c` を実行しているとのことです。[Bash] ではありません。どうしても [Bash] を使いたい場合は書き方に工夫が必要となります。

```Dockerfile:例
RUN /bin/bash -c 'echo piyopiyo'
```

https://docs.docker.com/engine/reference/builder/#run

試行錯誤の結果こんな感じで書けることがわかりました。このスタイルで行きます。

```Dockerfile:例
RUN if [ "$HOST_OSTYPE" = "Linux" ]; then echo "This is a Linux machine."; fi
```

[RUN] に渡すスクリプトはワンライナーでなければなりません。でもそれだと人間にはみにくいので、バックスラッシュ（`\`）で分割して適当に見た目を整えます。

```Dockerfile:例
RUN if [ "$HOST_OSTYPE" = "Linux" ]; then \
      echo "This is a Linux machine."; \
    else \
      echo "This is not a Linux machine."; \
    fi
```

シェルスクリプトの変数はダブルクォートした方がいいそうなので、そうするように心がけています。

https://qiita.com/ko1nksm/items/60b67cb24aa4ae634dd5

本件の場合はダブルクォートしなくてもいいのですが、今後うっかり罠にかからないよう自分のスクリプトでは文字列や変数を冗長的にダブルクォートする方針にします。そうすることにより、テキストエディターでもシンタックスハイライトが見やすくなるという利点もあります。

```Dockerfile:実はこれでもOKなはず！
RUN if [ $HOST_OSTYPE = Linux ]; then echo This is a Linux machine.; fi
```

[RUN]: https://docs.docker.jp/engine/articles/dockerfile_best-practice.html#run
[ENTRYPOINT]: https://docs.docker.jp/engine/articles/dockerfile_best-practice.html#entrypoint
[Bash]: https://ja.wikipedia.org/wiki/Bash
[Bourne Shell]: https://ja.wikipedia.org/wiki/Bourne_Shell

#### Dockerfile の中でホストマシンの OS を検知する方法

ホストマシンの OS を検知する方法は簡単です。`uname` コマンドがあります。

```sh:ホストマシンのターミナル
uname
```

macOS だと `Darwin`、Linux だと `Linux` という文字列が買えると思います。

あとは [@koyo-miyamura さんの記事]で紹介されている方法を応用します。

`Dockerfile` に引数を渡します。引数として受け取りたい変数名を ARG を用いて明示します。

```Dockerfile:例
ARG HOST_OSTYPE
```

[@koyo-miyamura さんの記事]では、引数をホストマシンの `.env` から `docker-compose.yml` へ、`docker-compose.yml` から `Dockerfile` へと渡していく技が紹介されていました。

## 問題2: alpine 以外のイメージで Dockerfile を書く

### どのイメージを使うか決定

[Phoenix 公式ドキュメント](https://hexdocs.pm/phoenix/releases.html#containers)で紹介されている Docker イメージでやってみようと思います。

[Debian GNU/Linux] をベースにしたイメージが使用されています。

https://hexdocs.pm/phoenix/releases.html#containers

[Debian GNU/Linux]: https://en.wikipedia.org/wiki/Debian

### 最新版のイメージを探す

最新版を Dockerhub で検索します。

https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm-20230612

### Dockerfile で実行するコードの調整

依存関係のインストールや user/group の設定が OS により異なるので適宜調整が必要です。ネット検索で使えそうなものを探します。

## できたもの

```Dockerfile:Dockerfile
FROM hexpm/elixir:1.15.7-erlang-26.1.1-debian-bookworm-20230612-slim

ARG HOST_USER_NAME
ARG HOST_GROUP_NAME
ARG HOST_UID
ARG HOST_GID
ARG HOST_OSTYPE

# install build dependencies
RUN apt-get update -y && apt-get install -y \
      build-essential \
      git \
      inotify-tools \
      nodejs \
      npm \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# sync user
RUN if [ "$HOST_OSTYPE" = "Linux" ]; then \
      addgroup --gid "$HOST_GID" "$HOST_GROUP_NAME"; \
      adduser --uid "$HOST_UID" --gid "$HOST_GID" "$HOST_USER_NAME"; \
    else \
      adduser --uid "$HOST_UID" --gid "$HOST_GID" "$HOST_USER_NAME"; \
    fi

USER $HOST_USER_NAME

# install hex + rebar + phx_new
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new
```

[inotify-tools] がないとこういうエラーがでます。このエラーを見たら思い出してください。

> [error] `inotify-tools` is needed to run `file_system` for your system, check https://github.com/rvoicilas/inotify-tools/wiki for more information about how to install it. If it's already installed but not be found, appoint executable file with `config.exs` or `FILESYSTEM_FSINOTIFY_EXECUTABLE_FILE` env.

`nodejs` と `npm` は [DaisyUI] 等の [Tailwind CSS] のプラグイン を使いたい場合などに必要となります。初期設定の [Phoenix] アプリではそれらは不要です。

> [debug] Downloading esbuild from https://registry.npmjs.org/@esbuild/linux-x64/-/linux-x64-0.17.11.tgz
>
> Rebuilding...
> Error: Cannot find module 'tailwindcss/plugin'
> Require stack:
> - /app/assets/tailwind.config.js
>     at Function.Module._resolveFilename (node:internal/modules/cjs/loader:933:15)
>     at Function._resolveFilename (pkg/prelude/bootstrap.js:1955:46)
>     at Function.resolve (node:internal/modules/cjs/helpers:108:19)
>     at _resolve (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:241025)
>     at jiti (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:243309)
>     at /app/assets/tailwind.config.js:4:16
>     at jiti (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:245784)
>     at /snapshot/tailwindcss/lib/lib/load-config.js:37:30
>     at loadConfig (/snapshot/tailwindcss/lib/lib/load-config.js:39:6)
>     at Object.loadConfig (/snapshot/tailwindcss/lib/cli/build/plugin.js:135:49) {
>   code: 'MODULE_NOT_FOUND',
>   requireStack: [ '/app/assets/tailwind.config.js' ]
> }
> ** (Mix) `mix tailwind default` exited with 1

https://github.com/phoenixframework/tailwind#tailwind

https://qiita.com/mnishiguchi/items/11bd7a1e1784fc86dacc

[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/
[inotify-tools]: https://github.com/inotify-tools/inotify-tools

## さいごに

今回の作業を通して、Docker コンテナをさまざまな開発マシンで動かす技を習得するとともに、[Docker]、[Docker Compose]、[Linux] 等についての理解を深めることができました。

本記事は [autoracex #253](https://autoracex.connpass.com/event/298184/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
