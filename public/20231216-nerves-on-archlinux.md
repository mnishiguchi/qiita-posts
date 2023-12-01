---
title: Arch LinuxでNervesをビルドすることを楽しむ
tags:
  - Erlang
  - Linux
  - archLinux
  - RaspberryPi
  - Elixir
private: false
updated_at: '2023-12-17T23:39:55+09:00'
id: 87b1d42f87d9931d6df5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Arch Linux]で[Nerves]のファームウエアを公式ソースコードからビルドしてみようと思います。

## Elixir（えりくさ）言語

[Elixir]は耐障害性、高い並列性能で長年実績のある[Erlang]の上に実装されたプログラミング言語で、世界中のメッセージアプリ、チャットアプリ等でも使用されており、その性能に改めて注目が集まっていると聞きます。[Elixir]を使ってサーバーの費用を  $2 Million/年   節約できたという話もあります。

https://paraxial.io/blog/elixir-savings

## Nerves（なあぶす）フレームワーク

[Nerves（なあぶす）](https://www.nerves-project.org/)という IoT フレームワークを使うと、[Elixir]の強力な性能を[ラズパイ][Raspberry Pi 5]等の手のひらサイズのコンピュータの上で活用し、堅牢な IoT システムの構築が比較的簡単にできてしまいます。すごいです！

Nerves について詳しくは@takasehideki さんの[「Slideshare：Elixir で IoT！？ナウでヤングで cool な Nerves フレームワーク」](https://www2.slideshare.net/takasehideki/elixiriotcoolnerves-236780506)がわかりやすいです。

https://www2.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

https://nerves-jp.connpass.com/

[Nerves]にはいろんな概念や構成要素が含まれているので、「[Nerves]とはなにか」を考えるときに混乱することがあるかと思います。

### nerves パッケージ

[Nerves]への入り口であり、[コアツール](https://github.com/nerves-project/nerves#nerves-projects)と[ドキュメント](https://hexdocs.pm/nerves/getting-started.html)を[Nerves]ユーザーに提供。

https://github.com/nerves-project/nerves

### Buildroot

[Nerves]が内部で使用する、[クロスコンパイル][クロスコンパイラ]で組み込み Linux システムを生成するためのツール。

[Nerves]がナイスな形で隠蔽してくれているので、通常は[Nerves]ユーザーが直接[Buildroot]を触ることはありません。

https://git.busybox.net/buildroot

### nerves_system_br 　パッケージ

組み込み [Erlang]、[Elixir]、[Lisp Flavored Erlang (LFE)][LFE] プロジェクト用の開発プラットフォーム。[Buildroot]を使用して[Nerves]を構築するための共通ロジックを提供します。通常は直接触ることは無いです。

https://github.com/nerves-project/nerves_system_br

### nerves_system_xxx パッケージ

[nerves_system_br]パッケージによって提供される共通ロジックに[Nerves Target]デバイス専用の設定を加えてできたアダプターのようなもの。別の言葉でいうと[Nerves]チームが提供してくれているおすすめの設定です。カスタマイズすることも可能です。

`nerves_system_xxx`の`xxx`の部分はお手元のデバイスに対応する[Nerves Target]に読み替えてください。[Nerves]公式サポートの[Nerves Target]以外にもコミュニティによって制作されたカスタムシステムも多数あります。

https://hex.pm/packages?search=nerves_system_&sort=recent_downloads

例として挙げると、[Raspberry Pi 5]に対応する[Nerves Target]は`rpi5`になります。

https://github.com/nerves-project/nerves_system_rpi5

## 環境

- ホスト OS: Arch Linux x86_64
- ホストマシン: MacBookAir6,2 1.0

## やること

[Arch Linux]のマシンが手元にあるという前提です。

- [asdf] をインストール
- [Erlang] をインストール
- [Elixir] をインストール
- [Nerves]をソースからビルドするのに必要なパッケージをインストール
- [Nerves Systems Builder]をダウンロード
- [Nerves Systems Builder]の README に従う

## asdf Erlang Elixir をインストール

https://qiita.com/mnishiguchi/items/122249b6c27391f03d82

もちろん他の[Linuxディストリビューション]でもできます！

https://qiita.com/clsource/items/41a6f0a6b45e50cc5dc0

比較的簡単にインストールできるので、[Arch Linux]以外をお使いの方もぜひとも挑戦してみてください。

https://asdf-vm.com/guide/getting-started.html

https://github.com/asdf-vm/asdf-erlang

https://github.com/asdf-vm/asdf-elixir

https://qiita.com/torifukukaiou/items/9009191de6873664bb58

万一、戸惑うことがあれば、お気軽にコミュニティに顔を出してみてください。みんなで助け合いながら楽しく一歩ずつ前へ進んでます。

https://nerves-jp.connpass.com/

https://elixir-lang.info/

## Nerves をファームウエアを開発するのに最低限必要なパッケージをインストール

[Nerves]ドキュメントに紹介されているインストール方法は、[Arch Linux]公式の [pacman] パッケージマネージャを使用していません。[Arch User Repository (AUR)][AUR] を利用するための非公式ヘルパーコマンド [yay](https://github.com/Jguer/yay)を使ってます。ひょっとしたらドキュメントを執筆当時は公式の[Arch リポジトリ](https://archlinux.org/packages/)に存在しなかったパッケージがあったのかもしれません。

2023 年 12 月現在では [pacman] パッケージマネージャでインストールできるのでそれで行きます。

```bash:ホストマシンのターミナル
sudo pacman -S --needed \
  base-devel \
  ncurses \
  lxqt-openssh-askpass \
  git \
  squashfs-tools \
  curl
```

https://hexdocs.pm/nerves/installation.html

## Nerves Systems Builder を利用するのに必要なパッケージをインストール

[Nerves Systems Builder]という Nerves コアチームが使っているツールが公開されています。

https://github.com/nerves-project/nerves_systems

一つ問題は、Nerves コアチームが Debian 系 OS しか使っていないため、他の OS で必要なパッケージの検証はされていません。

[Arch Linux]で使えるパッケージをひとつひとつ探していくしかありません。

![nerves-system-pacman-deps-install 2023-09-27 12-57-19.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/71eec432-d590-b5bd-a4fc-f5dde6ba708c.png)

結果、以下のパッケージで同じことを[Arch Linux]でもできることがわかりました。

```bash:ホストマシンのターミナル
sudo pacman -S --needed \
  base-devel \
  bc \
  cmake \
  cpio \
  curl \
  cvs \
  gawk \
  git \
  jq \
  mercurial \
  ncurses \
  lxqt-openssh-askpass \
  python \
  python-aiohttp \
  python-ijson \
  python-nose2 \
  python-pexpect \
  python-pip \
  python-requests \
  rsync \
  squashfs-tools \
  subversion \
  unzip \
  wget
```

## Nerves Systems Builder をダウンロード

```
git clone git@github.com:nerves-project/nerves_systems.git
cd nerves_systems
```

## Nerves Systems Builder の README に従う

あとは [Nerves Systems Builder] の README にある手順に従うだけで、比較的簡単にファームウエアをソースファイルからビルドできます。

https://github.com/nerves-project/nerves_systems

https://qiita.com/mnishiguchi/items/206961699345ee8cf528

比較的簡単とはいえ、まだ[Nerves]をやったことのない方が、いきなりファームウエアを公式ソースコードからビルドするというのは大変だと思います。

まずは[Nerves Livebook]をお試しになればと思います。楽しいですよ。

## Nerves Livebook

ビルド済み[Nerves Livebook]ファームウェアを使用すると、何も構築せずに実際のハードウェアで [Nerves] プロジェクトを試すことができます。 数分以内に、[Raspberry Pi][Raspberry Pi 5] や [BeagleBone] で [Nerves] を実行できるようになります。 Livebook でコードを実行し、ブラウザーで快適に Nerves チュートリアルを進めることができます。

有志の方々が [Nerves Livebook] のセットアップ方法ついてのビデオを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

[Nerves Livebook] の中に ネットワーク関連のノートブックが含まれており、ブラウザ上で Wi-Fi の設定ができてしまいます。

- [WiFi 設定についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/configure_wifi.livemd)
- [VintageNet についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/vintage_net.livemd)

https://qiita.com/mnishiguchi/items/9d7ed9f674423be26598

## さいごに

これで[Arch Linux]をお使いの方も[Elixir]や[Nerves]を楽しめます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[aarch64]: https://ja.wikipedia.org/wiki/AArch64
[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[Arch Linux]: https://ja.wikipedia.org/wiki/Arch_Linux
[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[Buildroot]: https://buildroot.org/
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Linuxディストリビューション]: https://ja.wikipedia.org/wiki/Linux%E3%83%87%E3%82%A3%E3%82%B9%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3
[Livebook]: https://livebook.dev/
[Mix]: https://hexdocs.pm/mix/Mix.html
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[rebar]: https://github.com/erlang/rebar3
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SFTP]: https://ja.wikipedia.org/wiki/SSH_File_Transfer_Protocol
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[x86_64]: https://ja.wikipedia.org/wiki/X64
[アーカイブ]: https://ja.wikipedia.org/wiki/アーカイブ_(コンピュータ)
[インクリメンタルビルド]: https://ja.wikipedia.org/wiki/ビルド_(ソフトウェア)
[シェル]: https://ja.wikipedia.org/wiki/シェル
[プロプライエタリソフトウェア]: https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%83%97%E3%83%A9%E3%82%A4%E3%82%A8%E3%82%BF%E3%83%AA%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[対象ボード]: https://hexdocs.pm/nerves/targets.html
[クロスコンパイラ]: https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9
[Buildroot]: https://buildroot.org/
[LFE]: https://en.wikipedia.org/wiki/LFE_(programming_language)
[pacman]: https://wiki.archlinux.jp/index.php/Pacman
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[AUR]: https://aur.archlinux.org/packages
<!-- end links -->
