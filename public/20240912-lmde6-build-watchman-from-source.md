---
title: Linux Mint (LMDE6) で watchman をソースコードからビルドすることに挑戦
tags:
  - Linux
  - Debian
  - reactnative
  - watchman
  - LMDE6
private: false
updated_at: '2024-09-12T19:46:19+09:00'
id: 5bada235e79cee554daf
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

Linux Mint (LMDE6) の PC に[watchman]をソースコードからビルドしてインストールしました。

2024 年 9 月初旬現在、わかりにくかったのでメモします。

[watchman]: https://facebook.github.io/watchman/

## 実行環境

- OS: [LMDE 6 (faye) x86_64](https://linuxmint.com/edition.php?id=308)

## 公式インストール方法

[公式ドキュメント][Installation]によると、Debian 向けのやり方は複数あります。

- [Homebrew on Linux を使う](https://facebook.github.io/watchman/docs/install#homebrew)
- [ソースコードからビルド](https://facebook.github.io/watchman/docs/install#-building-from-source)
- [ビルド済みバイナリをダウンロード](https://facebook.github.io/watchman/docs/install#prebuilt-binaries-2)

[Installation]: https://facebook.github.io/watchman/docs/install

## ソースコードからビルドすることになった経緯

Homebrew は使っていないので除外することにしました。

まずビルド済みバイナリをダウンロードする方法を試してみました。
ところが、手順通りにインストールしましたが、エラーがでて使えませんでした。

> watchman: error while loading shared libraries: libcrypto.so.1.1: cannot open shared object file: No such file or directory

どうも Issues にもいくつか上がっているようですが、長い間解決していない問題のようです。

- https://github.com/facebook/watchman/issues/1241
- https://github.com/facebook/watchman/issues/1019

[Releases](https://github.com/facebook/watchman/tags) を見てみると、最近のリリースに Linux 版のバイナリが含まれていません。Linux 版のバイナリはあまりメンテナンスされていないのかもしれません。

そういう経緯があってソースコードからビルドしてみようということになりました。

## ソースコードをダウンロードする

[最新リリース](https://github.com/facebook/watchman/releases/latest)からダウンロードするか、[GitHub リポジトリ](https://github.com/facebook/watchman/)からクローンします。

Git を使う場合は以下の通りです。

```bash
git clone https://github.com/facebook/watchman
```

そしてソースコードのディレクトリに移動します。

```bash
cd watchman
```

### install-system-packages.sh

依存関係が公式ドキュメントには見当たらなかったですが、リポジトリを見た印象だと`install-system-packages.sh`スクリプトを実行すれば必要なものがインストールされる設計になっているようです。

残念ながら、執筆時点では Linux Mint には対応してないようでした。

```bash
$ ./install-system-packages.sh
++ dirname ./install-system-packages.sh
+ python3 ./build/fbcode_builder/getdeps.py install-system-deps --recursive watchman
I don't know how to install any packages on this system linux-lmde-6
```

Debian 12 の Docker コンテナで色々試しているときに遭遇したエラーメッセージをもとに必要なパッケージを見つけ出すことができました。

手動でインストールする方針で行きます。

### autogen.sh

このスクリプトを実行するだけでビルドできるようです。

必要なパッケージがインストールされいない状態だと様々なエラーがでます。

## やってみる

### 必要なパッケージをインストール

システム上のパッケージリストを更新します。

```bash
apt update -yqq
```

Dockeｒコンテナ内で`./install-system-packages.sh`を実行したときにたまたま遭遇したエラーメッセージに以下のコードがありました。それをそのまま使います。ソースコードのどこかにあるのかもしれません。

```bash
apt install -yqq \
  autoconf \
  automake \
  binutils-dev \
  cmake \
  libboost-all-dev \
  libbz2-dev \
  libdouble-conversion-dev \
  libdwarf-dev \
  libevent-dev \
  libfast-float-dev \
  libffi-dev \
  libgflags-dev \
  libgmock-dev \
  libgoogle-glog-dev \
  libgtest-dev \
  liblz4-dev \
  liblzma-dev \
  libncurses-dev \
  libpcre2-dev \
  libsnappy-dev \
  libsodium-dev \
  libtool \
  libunwind-dev \
  libzstd-dev \
  ninja-build \
  python3-all-dev \
  zlib1g-dev
```

更に、以下は様々なエラーに対処しているときにインストールしたものです。詳しくは覚えてません。

エラーメッセージをヒントに適宜足りないものをインストールしてください。

```bash
apt install \
  build-essential \
  curl \
  git \
  libssl-dev \
  m4 \
  pkg-config \
  python3
```

### ビルドを実行

ソースコードのディレクトリ内で`./autogen.sh`を実行します。

```bash
./autogen.sh
```

何度もエラーに遭遇しましたが、ほとんどの場合が依存関係の不備でした。

### ビルド結果を確認

`built`ディレクトリが生成され、その中にビルド結果が格納されます。以下は一例です。

```bash
$ tree ./built
./built
├── bin
│   ├── watchman
│   └── watchmanctl
└── lib
    ├── libevent-2.1.so.7
    ├── libgflags.so.2.2
    ├── libglog.so.0
    ├── libsnappy.so.1
    └── libunwind.so.8

3 directories, 7 files
```

動作確認をします。

```bash
./built/bin/watchman --version
./built/bin/watchmanctl --help
```

たしかこの時点では`./built/bin/watchman --version`の方でエラーがでたと記憶しています。

> ./built/bin/watchman: error while loading shared libraries: /usr/local/lib/libglog.so.0: cannot open shared object file: No such file or directory

### 必要なファイルをつくり、ビルド結果を適切な場所にコピー

- `./built/bin/*` → `/usr/local/bin/`
- `./built/lib/*` → `/usr/local/lib`

```bash
sudo mkdir -p /usr/local/{bin,lib}
sudo mkdir -p /usr/local/var/run/watchman

cd path/to/watchman
cp -iv built/bin/* /usr/local/bin/
cp -iv built/lib/* /usr/local/lib/

sudo chmod 755 /usr/local/bin/watchman
sudo chmod 2777 /usr/local/var/run/watchman
```

再度`./built/bin/watchman --version`を実行すると成功するはずです。

```bash
$ ./built/bin/watchman --version
20240905.175743.0
```

また、パスの通っている場所にコピーを置いたので、`watchman --version`も機能するはずです。

```bash
$ watchman --version
20240905.175743.0
```

## おわりに

依存関係さえしっかりインストールされていれば、スクリプトを実行するだけで簡単にビルドできることがわかりました。

2024 年 9 月初旬現在、ドキュメント上ではわかりにくい部分があったので、このメモが何らかの一助になれば幸いです。

なにか情報があれば、ぜひお便りください :bow:
