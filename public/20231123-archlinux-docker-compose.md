---
title: Arch Linux に Docker Compose をインストールする
tags:
  - Linux
  - Elixir
  - Docker
  - Phoenix
  - docker-compose
private: false
updated_at: '2023-11-27T22:55:38+09:00'
id: 62744d09ce9a8a2d109c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Arch Linux] に [Docker Compose] をインストールします。

https://wiki.archlinux.jp/index.php/Docker#Docker_Compose

## TL;DR

- [docker](https://archlinux.org/packages/?name=docker) (Docker Engine and Docker CLI) をインストール
- [docker-compose](https://archlinux.org/packages/extra/x86_64/docker-compose)（Compose plugin）をインストール

## 環境

- OS: Arch Linux x86_64
- ホスト: MacBookAir6,2 1.0
- デスクトップ環境: Xfce 4.18

## docker (Docker Engine and Docker CLI) をインストール

https://qiita.com/mnishiguchi/items/e5b61ec702d21165b079

https://archlinux.org/packages/?name=docker

## docker-compose（Compose plugin）をインストール

Docker の公式ドキュメントによると Compose plugin が使えるのは Linux マシンのみとのことです。

他の OS で [Docker Compose] を使うには [Docker Desktop] が必要となります。せっかく[プロプライエタリソフトウェア]である [Docker Desktop] を使わないという選択肢が用意されているので、 [Docker Desktop] を使わない方向で行こうと思います。

https://docs.docker.com/compose/install

https://archlinux.org/packages/?name=docker-compose

```shell:terminal
sudo pacman -S docker-compose
```

## 動作確認

バージョンを確認して、[Docker Compose] が正しくインストールされていることを確認します。

```shell:terminal
docker compose version
```

[Elixir] 言語で書かれた Web 開発フレームワーク [Phoenix] のアプリを起動してみます。

https://www.phoenixframework.org/

https://qiita.com/tags/phoenix


[Phoenix]アプリの開発環境を[Docker Compose]で構築できる [phx-docker-compose-new] という便利なスクリプトがあるので、それを活用します。

https://qiita.com/mnishiguchi/items/425a7e55f05a7ab6359b

[Phoenix]アプリの開発環境構築の詳細にご興味のある方のために資料を置いておきます。

https://qiita.com/koyo-miyamura/items/a609de2e9fadaf198243

https://moneyforward-dev.jp/entry/2023/08/31/100000

https://zenn.dev/koga1020/articles/d260bc1bde8267

https://qiita.com/mnishiguchi/items/e367743bca3520e2a387

[phx-docker-compose-new] コマンドのソースコードをダウンロードします。

```shell:terminal
git clone https://github.com/mnishiguchi/phx-docker-compose-new.git ~/.phx-docker-compose-new
```

ターミナルで [phx-docker-compose-new] コマンドが使えるように偽名を定義します。

```shell:terminal
alias phx-docker-compose-new=~/.phx-docker-compose-new/phx-docker-compose-new.sh
```

[phx-docker-compose-new] コマンドを用いて [Phoenix] のサンプルアプリを生成します。

[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html

```shell:terminal
phx-docker-compose-new sample_phx_app --no-assets --no-gettext --no-mailer
```

生成されたアプリのディレクトリに入り、アプリを起動します。

```shell:terminal
cd sample_phx_app

bin/start
```

以下の URL にアクセスして今すぐ [Phoenix] アプリを開発できます！

- [http://localhost:4000/](http://localhost:4000/)
- [http://localhost:4000/dev/dashboard/](http://localhost:4000/dev/dashboard/)
- [http://localhost:4001/](http://localhost:4001/)

![docker-compose-demo 2023-11-23 09-44-06.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/ee30129d-9d51-0156-6a89-96707d38c25b.png)

ログを見てみます。ログを閉じるときは「Ctrl + C」を押します。

```shell:terminal
bin/logs --follow
```

[Elixir] の対話コンソール（IEx）は以下のコマンドで起動できます。

```shell:terminal
bin/console
```

せっかく IEx を開いたのでプロセスの一覧を表示してみましょう。

```elixir:IEx
IEx.configure inspect: [limit: :infinity]

for pid <- Process.list, do: {pid, Process.info(pid, :registered_name) |> elem(1)}
```

https://qiita.com/mnishiguchi/items/990be2c72cb526681d0b

アプリの停止は以下のコマンドで行います。

```shell:terminal
bin/stop
```

:tada::tada::tada:

https://qiita.com/advent-calendar/2023/elixir

[Elixir] 言語を使ってサーバーの費用を **$2 Million/年** 節約できたというウワサがあります。

https://paraxial.io/blog/elixir-savings

## さいごに

[Arch Linux] に [Docker Compose] をインストールして、 [Phoenix] アプリ開発環境の構築ができました。

本記事は [闘魂Elixir #57](https://autoracex.connpass.com/event/300540/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->
[プロプライエタリソフトウェア]: https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%83%97%E3%83%A9%E3%82%A4%E3%82%A8%E3%82%BF%E3%83%AA%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[Docker]: https://wiki.archlinux.jp/index.php/Docker
[Docker Compose]: https://docs.docker.jp/compose/
[Docker Desktop]: https://docs.docker.com/desktop
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Arch Linux]: https://ja.wikipedia.org/wiki/Arch_Linux
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Phoenix]: https://www.phoenixframework.org/
[phx-docker-compose-new]: https://github.com/mnishiguchi/phx-docker-compose-new
<!-- end links -->
