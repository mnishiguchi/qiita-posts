---
title: Arch Linux に Docker をインストールする
tags:
  - Linux
  - archLinux
  - Elixir
  - Docker
private: false
updated_at: '2023-11-23T22:57:09+09:00'
id: e5b61ec702d21165b079
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Arch Linux] に [Docker] をインストールします。

https://docs.docker.jp/get-started/overview.html

https://wiki.archlinux.jp/index.php/Docker

## TL;DR

- [docker](https://www.archlinux.jp/packages/?name=docker) パッケージをインストール
- `docker.service` を起動/有効化
- `docker` コマンドを非 root ユーザとして実行できるようにする（任意）

## 環境

- OS: Arch Linux x86_64
- ホスト: MacBookAir6,2 1.0
- デスクトップ環境: Xfce 4.18

## docker パッケージをインストール

```shell:terminal
sudo pacman -S docker
```

## docker.service を起動/有効化

[systemd] を使用して `docker` と `containerd` を自動的に起動するには、以下のコマンドを実行します。

```shell:terminal
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service
```

現在の状態は以下のコマンドで確認できます。

```shell:terminal
systemctl status docker.service --no-pager
```

https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot-with-systemd

https://wiki.archlinux.jp/index.php/Systemd#.E3.83.A6.E3.83.8B.E3.83.83.E3.83.88.E3.82.92.E4.BD.BF.E3.81.86

## docker コマンドを非 root ユーザとして実行できるようにする（任意）

初期設定では、Unix ソケットを所有するのは `root` ユーザーであり、他のユーザーは `sudo` を使用してのみアクセスできます。 Docker デーモンは常に `root` ユーザーとして実行されます。

毎回 `sudo` して `docker` コマンドを打ちたくない場合は、ユーザを `docker` グループに所属させます。

```shell:terminal
# 「docker」という名前の新しいグループを作成
sudo groupadd -f docker

# ユーザーを「docker」グループに追加
sudo usermod -aG docker $USER

# グループへの変更をアクティブ化
newgrp docker
```

https://docs.docker.com/engine/install/linux-postinstall/

## 動作確認

インストールされた [Docker] についての情報を印字してみます。

```shell:terminal
docker info
```

`sudo` なしで `docker` コマンドを実行できるのか確認。

```shell:terminal
docker run hello-world
```

https://docs.docker.com/engine/install/linux-postinstall

:tada::tada::tada:

[Elixir] 言語のイメージを使って色々Runしてみます。

https://qiita.com/torifukukaiou/items/e07ed758d1259d14a2b7

```shell:terminal
docker run --rm elixir:slim elixir -e 'IO.puts("元氣があればなんでもできる")'
```

[progress_bar](https://hex.pm/packages/progress_bar) パッケージを利用して[プログレスバー]を印字してみます。

```shell:terminal
docker run --rm elixir:slim elixir -e 'Mix.install([:progress_bar]); for i <- 0..100, do: (ProgressBar.render(i, 100); Process.sleep(10)); :ok'
```

[toolshed](https://hex.pm/packages/toolshed) パッケージを利用してお天気情報を印字してみます。

```shell:terminal
docker run --rm elixir:slim elixir -e 'Mix.install([:toolshed]); Toolshed.weather'
```

:tada::tada::tada:

https://qiita.com/advent-calendar/2023/elixir

[Elixir] 言語を使ってサーバーの費用を **$2 Million/年** 節約できたというウワサがあります。

https://paraxial.io/blog/elixir-savings

## さいごに

本記事は [闘魂Elixir #57](https://autoracex.connpass.com/event/300540/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->
[プログレスバー]: https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%AC%E3%82%B9%E3%83%90%E3%83%BC
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[Docker]: https://wiki.archlinux.jp/index.php/Docker
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Arch Linux]: https://ja.wikipedia.org/wiki/Arch_Linux
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
<!-- end links -->
