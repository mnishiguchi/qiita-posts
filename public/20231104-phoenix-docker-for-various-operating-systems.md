---
title: Phoenix Docker コンテナをさまざまな開発マシンで動かす
tags:
  - 初心者
  - Elixir
  - Docker
  - Phoenix
  - docker-compose
private: true
updated_at: '2023-11-05T06:42:49+09:00'
id: e367743bca3520e2a387
organization_url_name: null
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

## 未解決の部分

未解決の部分とは、具体的にはこれらの問題です。

### 問題1

> これで解決・・・と思いきや Mac 環境で上記の `Dockerfile` をビルドしてみると問題が発生してしまいます。
どうも Mac 側の GID と衝突してしまうよう・・・（いい回避策知ってたら教えてくださいｗ）。

### 問題2

> 今回のDockerfileは一例ですので、alpineを使わないようにしてみるなど、プロジェクトの構成に併せて適宜カスタマイズしてみてください！（alpine使わずに動かす Dockerfile 書いたらぜひ記事にして教えてください！）

オープンソースソフトウエアのコミュニティーではこういうのを見て見ぬ振りするのは好ましくありません。何らかの恩返しを試みます！

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

厳密にいうと解決されています。[@koyo-miyamura さんの記事]ではマルチステージビルドで２種類のビルドターゲットを用意し、ホストマシンのOSに応じて使い分けるという技で解決されていました。ホストマシンを設定する人間が、自分で判断してセットアップ手順を使い分けないといけないという問題は残ります。

ここでは、ビルドターゲットを分けずに共通のセットアップ手順で解決する方法に取り組んでみます。

### 解決案

一つ思いついたのが `Dockerfile` の中でホストマシンの OS により条件分岐するということです。

[@koyo-miyamura さんの記事]で、問題の現象が macOS で group の設定を行うときだけに起きることがわかっているので、ホストマシンが macOS の時に group の設定をやらないようにすれば上手くいくはずです。

それを実現するには、いくつか調査が必要です。

- `Dockerfile` の中で条件分岐するスクリプトを書く方法
- `Dockerfile` の中でホストマシンの OS を検知する方法

#### Dockerfile の中で条件分岐するスクリプトを書く方法

調査したところ、簡単そうなのは [RUN] や [ENTRYPOINT] で普通にシェルスクリプトを書くというやり方です。

[RUN] を使って直接 `Dockerfile` の中でスクリプトを書くことにします。

```Dockerfile:例
RUN echo piyopiyo
```

余談ですが、[RUN] が水面下で `/bin/sh -c` を実行しているとのことです。[Bash] ではありません。どうしても [Bash] を使いたい場合は書き方に工夫が必要となります。

```Dockerfile:例
RUN /bin/bash -c 'echo piyopiyo'
```

https://docs.docker.com/engine/reference/builder/#run

試行錯誤の結果こんな感じで書けることがわかりました。

```Dockerfile:例
RUN if [ "$HOST_OSTYPE" = "Linux" ]; then \
      echo "This is a Linux machine." \
    fi
```

[RUN] に渡すスクリプトはワンライナーでなければなりません。でもそれだと人間にはみにくいので、バックスラッシュ（`\`）で適当に見た目を整えます。

シェルスクリプトの変数はダブルクォートしなければいけないそうなので、そうするように心がけています。

https://qiita.com/ko1nksm/items/60b67cb24aa4ae634dd5

[RUN]: https://docs.docker.jp/engine/articles/dockerfile_best-practice.html#run
[ENTRYPOINT]: https://docs.docker.jp/engine/articles/dockerfile_best-practice.html#entrypoint
[Bash]: https://ja.wikipedia.org/wiki/Bash
[Bourne Shell]: https://ja.wikipedia.org/wiki/Bourne_Shell

#### Dockerfile の中でホストマシンの OS を検知する方法

まずは、ホストマシンの OS を検知する方法ですが、これは簡単です。

```sh:macOS
uname
```

あとは [@koyo-miyamura さんの記事]で紹介されている方法を応用します。

`Dockerfile` に引数を渡します。引数として受け取りたい変数名を ARG を用いて明示します。

```Dockerfile:例
ARG HOST_OSTYPE
```

[@koyo-miyamura さんの記事]では、引数をホストマシンの `.env` から `docker-compose.yml` へ、`docker-compose.yml` から `Dockerfile` へと渡していく技が紹介されていました。

## 問題2: alpine 以外のイメージで Dockerfile を書く

### 解決案

[Phoenix 公式ドキュメント](https://hexdocs.pm/phoenix/releases.html#containers)で紹介されている Docker イメージでやってみようと思います。

https://hexdocs.pm/phoenix/releases.html#containers

[Debian GNU/Linux] をベースにしたイメージが使用されています。

最新版を Dockerhub で検索します。

https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm-20230612

[Debian GNU/Linux]: https://en.wikipedia.org/wiki/Debian

依存関係のインストールや user/group の設定が異なるようなので適宜調整が必要です。

## できたもの

```Dockerfile:例
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
    fi

USER $HOST_USER_NAME

# install hex + rebar + phx_new
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new
```

余談ですが、`nodejs` と `npm` は [DaisyUI] 等の [Tailwind CSS] のプラグイン を使いたい場合などに必要となります。初期設定の [Phoenix] での時点ではそれらは不要です。

```sh:daisyuiのインストール
npm install --save-dev --prefix tailwindcss daisyui
```

https://github.com/phoenixframework/tailwind#tailwind

[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/

## さいごに

今回の作業を通して、Docker コンテナをさまざまな開発マシンで動かす技を習得するとともに、[Docker]、[Docker Compose]、Linux等についての理解を深めることができました。

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd
