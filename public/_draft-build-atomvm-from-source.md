---
title: AtomVM 入門: ソースコードからビルド (2025年12月)
tags:
  - ''
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---

## はじめに


以前、[AtomVM] に思い切って挑戦してみたものの、当時は細部を理解せずに進めた部分もありました。

そこで今回は、環境構築に焦点を絞り、とくに [AtomVM] をソースコードからビルドする手順をまとめておきたいと思います。

[AtomVM] に少しでも興味を持った方の参考になれば幸いです。

## 対象環境・機材

今回試したときの環境は次のとおりです。

- マイコン
  - Seeed Studio XIAO ESP32-S3（オンボード LED は GPIO 21）
- ホスト PC
  - Debian 系 Linux（LMDE7）
- 主なソフトウェア
  - Elixir 1.17（Erlang/OTP 27）
  - AtomVM 0.7.0-dev+git.6ef74599
  - Python 3.14.1
  - [ESP-IDF] v5.5
  - [esptool] 5.1.0
  - [picocom] 3.1（シリアルモニタ）

## 手順の全体像

やることをざっくり並べると、以下のとおりです。

1. AtomVM・ESP-IDF・esptool の準備  
2. Elixir コアライブラリ生成  
3. ESP32-S3 向け AtomVM をビルドし、Release イメージを作成  
4. XIAO ESP32-S3 に AtomVM を書き込み  
5. Elixir の Blinky サンプルを書き込んで L チカ

順に見ていきます。

## AtomVM と ESP-IDF の準備

### 必要な道具

まずはホスト側の前提となる道具を入れておきます。

```bash
# elixir が任意の方法でインストールされていること (AtomVM の開発に必要)
# https://doc.atomvm.org/latest/release-notes.html#required-software
elixir --version

# python 3 (Python 3.10 以上) が任意の方法でインストールされていること (esptool, ESP-IDF に必要)
python3 --version

# 必要なシステムパッケージをインストール (ESP-IDF に必要)
# https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/linux-macos-setup.html
sudo apt install git wget flex bison gperf cmake ninja-build \
  ccache libffi-dev libssl-dev dfu-util libusb-1.0-0
````

### AtomVM のソースコードを取得

```bash
# AtomVMのソースコードの保存場所は任意
mkdir -p $HOME/Projects/atomvm
cd $HOME/Projects/atomvm

# ソースコードを取得
git clone https://github.com/atomvm/AtomVM
cd AtomVM
```

以降は、AtomVM のソースコードのルートディレクトリを`$HOME/Projects/atomvm/AtomVM`とします。

### ESP-IDF（ESP32-S3 用）をインストール

```bash
# esp-idfのソースコードの保存場所は任意
mkdir -p $HOME/esp
cd $HOME/esp

# ソースコードを取得
# https://doc.atomvm.org/latest/release-notes.html#required-software
git clone --branch v5.5 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf

# esp32s3 向けツール群をインストール
./install.sh esp32s3

idf.py --version
```

ESP-IDF のインストール方法や前提パッケージについては、公式の「Standard Toolchain Setup for Linux and macOS」が参考になります。

https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/linux-macos-setup.html

### esptool のインストール

```bash
pip install esptool
esptool version
```

詳しくは esptool の詳細は公式ドキュメントを参照してください。

https://docs.espressif.com/projects/esptool/en/latest/esp32/

## Elixir コアライブラリ生成

ESP32 用の完全なイメージを作るためには、先にホスト PC 上で Generic UNIX 版 AtomVM をビルドしておく必要があります。ここで Elixir 向けコアライブラリを含んだ `elixir_esp32boot.avm` などが生成されます。

```bash
cd "$HOME/Projects/atomvm/AtomVM"

mkdir -p build
cd build

cmake ..
make -j"$(nproc)"

# 任意だが、atomvm コマンドをインストールしておくと便利
sudo make install
which atomvm
````

ビルド完了後、次のようなファイルが生成されているはずです。

```bash
ls build/libs/esp32boot
# esp32boot.avm
# elixir_esp32boot.avm
# ...
```

ここで生成された `elixir_esp32boot.avm` を、のちほど ESP32 側の `boot.avm` パーティションに書き込みます。

AtomVM 全体のビルド手順については、公式ドキュメントもあわせて確認しておくと全体像がつかみやすいです。

https://doc.atomvm.org/main/build-instructions.html

## ESP32-S3 向け AtomVM をビルドし Release イメージを作成

### ESP-IDF 環境を読み込む

```bash
cd $HOME/Projects/atomvm/AtomVM/src/platforms/esp32
source $HOME/esp/esp-idf/export.sh
```

### Elixir 用パーティションテーブルを指定

Elixir 用のパーティションレイアウトを使うため、`sdkconfig.defaults` に `partitions-elixir.csv` を指定します。

```ini:$HOME/Projects/atomvm/AtomVM/src/platforms/esp32/sdkconfig.defaults
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions-elixir.csv"
CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y
CONFIG_MBEDTLS_ECP_FIXED_POINT_OPTIM=y
CONFIG_LWIP_IPV6=n
```

これで、`boot.avm` / `main.avm` などが Elixir 向けの構成になります。

### ESP32-S3 向けにビルド

```bash
cd $HOME/Projects/atomvm/AtomVM/src/platforms/esp32

idf.py fullclean
idf.py set-target esp32s3
idf.py reconfigure
idf.py build
```

ここまでで

* ESP32-S3 向け AtomVM 本体
* Elixir / Erlang コアライブラリを含むビルド成果物
* 各種補助スクリプト（`mkimage.sh` / `flashimage.sh` など）

がそろった状態になります。

### `mkimage.sh` で Release イメージを生成

ESP32-S3 に書き込むための「ひとまとめのイメージ」を `mkimage.sh` で作成します。

```bash
cd $HOME/Projects/atomvm/AtomVM/src/platforms/esp32

./build/mkimage.sh
```

内部で `elixir_esp32boot.avm` などが取り込まれ、ESP32-S3 向けのイメージファイルが生成されます。

```bash
ls -lh build/atomvm-esp32*
# build/atomvm-esp32s3-xxxxxx.img  のようなファイルができているはず
```

## XIAO ESP32-S3 に AtomVM を書き込む

### フラッシュ全消去

```bash
esptool --chip auto \
  --port /dev/ttyACM0 \
  --baud 115200 \
  erase-flash
```

以前のファームウェアやパーティション情報が残っていると、思わぬところで混ざって不具合が出ることがあるので、
初回は一度消しておくと安心です。

### Release イメージを書き込む

`mkimage.sh` が生成したイメージを、`flashimage.sh` でまとめて書き込みます。

```bash
cd $HOME/Projects/atomvm/AtomVM/src/platforms/esp32
source $HOME/esp/esp-idf/export.sh

./build/flashimage.sh
```

`flashimage.sh` の中では `esptool.py` が呼ばれ、適切なオフセットに bootloader / パーティションテーブル / AtomVM 本体 / Elixir コアライブラリが書き込まれます。

ここまで終わると、XIAO ESP32-S3 上に AtomVM 本体と Elixir 標準ライブラリ入りの `boot.avm` がそろった状態になっています。

## Elixir 版 Blinky を書き込んで L チカ

次に、Elixir 側の Blinky サンプルを `.avm` にして書き込みます。

### サンプル取得と依存関係

AtomVM 公式のサンプル集から Elixir 版 Blinky を使います。

```bash
cd $HOME/Projects/atomvm

git clone https://github.com/atomvm/atomvm_examples.git

cd atomvm_examples/elixir/Blinky
mix deps.get
```

### XIAO ESP32-S3 用に GPIO 番号を変更

XIAO ESP32-S3 のオンボード LED は GPIO 21 に接続されています。

`lib/blinky.ex` を次のように書き換えます。

```elixir
defmodule Blinky do
  @pin 21

  def start() do
    :gpio.set_pin_mode(@pin, :output)
    loop(@pin, :low)
  end

  defp loop(pin, level) do
    :io.format(~c"Setting pin ~p ~p~n", [pin, level])
    :gpio.digital_write(pin, level)
    Process.sleep(1000)
    loop(pin, toggle(level))
  end

  defp toggle(:high), do: :low
  defp toggle(:low), do: :high
end
```

### `.avm` を生成する

```bash
mix atomvm.packbeam
```

成功すると、カレントディレクトリに `Blinky.avm` などが生成されます。

```bash
ls -1 *.avm
# Blinky.avm など
```

### ESP32-S3 にアプリケーションをフラッシュ

AtomVM 本体はすでに書き込まれているので、以降は `.avm` だけ差し替えれば足ります。

```bash
mix atomvm.esp32.flash --port /dev/ttyACM0
```

これで `main.avm` パーティションに `Blinky.avm` が書き込まれます。

シリアルモニタでログを眺めると、次のような出力とともに LED が点滅するはずです。

```text
Setting pin 21 low
Setting pin 21 high
...
```

## おわりに

本記事では、AtomVM をソースからビルドし、XIAO ESP32-S3 で Elixir の L チカを動かすまでの流れを、整理しました。

ソースからビルドできるようになることで、用途にあわせた AtomVM 本体・ライブラリの調整や、専用ボード向けの独自イメージ作成がしやすくなります。

今後はこの環境を土台に、XIAO ESP32-S3 向けの GPIO・I2C・SPI・LCD まわりのサンプルも少しずつ増やしていく予定です。
どこかでつまずいたり、より良い手順に氣づいたら、また記事にまとめます。

[NervesJP]: https://nerves-jp.connpass.com/
[piyopiyo.ex]: https://piyopiyoex.connpass.com/
[autoracex]: https://autoracex.connpass.com/
[IoT]: https://www.google.com/search?q=IoT%E3%81%A8%E3%81%AF
[AtomVM]: https://github.com/atomvm/AtomVM
[Elixir]: https://hexdocs.pm/elixir/introduction.html
[Nerves]: https://github.com/nerves-project
[SWEST27]: https://swest.toppers.jp/phx/
[Seeed Studio XIAO ESP32-S3]: https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
[ESP32]: https://www.google.com/search?q=ESP32%E3%81%A8%E3%81%AF
[ESP32-S3]: https://www.espressif.com/ja-jp/products/socs/esp32-s3
[AtomVM/releases]: https://github.com/atomvm/AtomVM/releases
[AtomVM/doc/getting-started]: https://doc.atomvm.org/latest/getting-started-guide.html#getting-started-on-the-esp32-platform
[Blinky]: https://github.com/atomvm/atomvm_examples/tree/master/elixir/Blinky
[Erlang]: https://www.erlang.org/doc/readme.html
[ESP-IDF]: https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/
[esptool]: https://docs.espressif.com/projects/esptool/en/latest/esp32/
[screen]: https://www.google.com/search?q=screen+linux
[minicom]: https://www.google.com/search?q=minicom+linux
[picocom]: https://www.google.com/search?q=picocom+linux
[AtomVM/releases]: https://github.com/atomvm/AtomVM/releases
[Blink]: https://github.com/atomvm/AtomVM/blob/main/examples/elixir/esp32/Blink.ex
[exatomvm]: https://github.com/atomvm/exatomvm
