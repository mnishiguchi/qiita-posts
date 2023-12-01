---
title: phx-docker-compose-new を mix phx.new の代わりに使って気軽に Phoenix の開発環境を構築
tags:
  - Erlang
  - Elixir
  - Docker
  - Phoenix
  - docker-compose
private: false
updated_at: '2023-11-29T08:29:46+09:00'
id: 425a7e55f05a7ab6359b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[mix phx.new] の代わりに使える [phx-docker-compose-new] というスクリプトを書いてみました。

[Phoenix]アプリの開発環境を[Docker Compose]で構築すると、アプリのみならず[PostgreSQL]データベースや[Livebook]なども一氣にまとめてセットアップすることができて便利です。

しかしながら、現実は一筋縄ではいかない面もあり、いろんなノウハウが必要となるのも事実です。


https://qiita.com/koyo-miyamura/items/a609de2e9fadaf198243

https://zenn.dev/koga1020/articles/d260bc1bde8267

https://qiita.com/mnishiguchi/items/e367743bca3520e2a387

そこで、初学者でも気軽に[Phoenix]アプリの開発環境を[Docker Compose]で構築できるスクリプトがあればいいんじゃないかと思ったのです。もちろん、ただ思っているだけでは何も変わらないので、すぐに取り組みました。

[English version](https://dev.to/mnishiguchi/build-phoenix-docker-compose-development-environment-using-phx-docker-compose-new-instead-of-mix-phxnew-20n2)

## やりかた

念の為 [Git]、[Docker]、[Docker Compose]がインストールされているか確認します。

```shell:terminal
git version
docker --version
docker compose version
```

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

## Livebook

https://moneyforward-dev.jp/entry/2023/08/31/100000

## さいごに

これでいつでも気軽に [Phoenix] アプリ開発環境の構築ができます。

本記事は [autoracex #259](https://autoracex.connpass.com/event/300537/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


<!-- begin links -->
[Docker]: https://docs.docker.jp/get-started/overview.html
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[heroicons_elixir]: https://github.com/mveytsman/heroicons_elixir
[heroicons]: https://heroicons.com/
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/
[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
[phx-docker-compose-new]: https://github.com/mnishiguchi/phx-docker-compose-new
[Docker Compose]: https://docs.docker.jp/compose/
[PostgreSQL]: https://www.postgresql.org/
[Git]: https://git-scm.com/
<!-- end links -->
