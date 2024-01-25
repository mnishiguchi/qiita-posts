---
title: ElixirでRaspberry Piのピン配置を確認
tags:
  - Linux
  - RaspberryPi
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-01-25T10:01:17+09:00'
id: b08c920f841996d1cdaf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir] で [Raspberry Pi] のピン配置を確認します。

## pinout パッケージとは

[pinout パッケージ][cavocado/pinout] は、[Raspberry Pi] や[BeagleBone] を含む一般的な組み込みデバイスを検出し、[ピン配置図]を出力します。

[pinout パッケージ][cavocado/pinout] が提供する便利な関数いくつか試してみます。

## pinout パッケージをインストール

お手元に[Elixir]の使える組み込みデバイスがない方もいらっしゃると思いますので、ここでは PC 上の[IEx]で[pinout パッケージ][cavocado/pinout]を試してみることにします。

PC のターミナルで[IEx]を起動します。

```bash:PCのターミナル
iex
```

以下のコードを実行して[pinout パッケージ][cavocado/pinout]をインストールします。

```elixir:IEx
Mix.install([{:pinout, "~> 0.1.3"}])
```

## 現在のボードのピン配置を印字

使い方は簡単です。`Pinout.print/0` で現在のボードのピン配置図を印字します。
デバイスが検知できなかった場合は、`Unknown Board` が印字されます。

```elixir:IEx
Pinout.print()
```

おそらく PC はサポート対象外なのでデバイスの検知ができないことと思いますが、[Raspberry Pi Zero W] 上で実行した場合は以下のとおり出力されます。

```txt:出力例
╭------------------------╮
|  oooooooooooooooooooo  |
|  1ooooooooooooooooooo  |
|  Raspberry Pi Zero W   |
|  ╭---╮     ╭--╮  ╭--╮  |
╰--╰---╯-----╰--╯--╰--╯--╯
        3v3 Power  [1] [2]  5v Power
  GPIO 2/I2C1 SDA  [3] [4]  5v Power
  GPIO 3/I2C1 SCL  [5] [6]  Ground
    GPIO 4/GPCLK0  [7] [8]  GPIO 14/UART TX
           Ground  [9] [10] GPIO 15/UART RX
          GPIO 17 [11] [12] GPIO 18/PCM CLK
          GPIO 27 [13] [14] Ground
          GPIO 22 [15] [16] GPIO 23
        3v3 Power [17] [18] GPIO 24
GPIO 10/SPI0 MOSI [19] [20] Ground
 GPIO 9/SPI0 MISO [21] [22] GPIO 25
GPIO 11/SPI0 SCLK [23] [24] GPIO 8/SPI0 CE0
           Ground [25] [26] GPIO 7/SPI0 CE1
GPIO 0/EEPROM SDA [27] [28] GPIO 1/EEPROM SCL
           GPIO 5 [29] [30] Ground
           GPIO 6 [31] [32] GPIO 12/PWM0
     GPIO 13/PWN1 [33] [34] Ground
   GPIO 19/PCM FS [35] [36] GPIO 16
          GPIO 26 [37] [38] GPIO 20/PCM DIN
           Ground [39] [40] GPIO 21/PCM DOUT
```

## 他のボードを確認してみたい場合

実は、現在のボード以外のボードのピン配置図を確認することもできます。

まず、[pinout パッケージ][cavocado/pinout] がサポートしているボードの名称を列挙します。

```elixir:IEx
Pinout.known_boards()
```

```elixir:戻り値の例
["BeagleBone Black", "BeagleBone Black Wireless", "BeagleBone Blue",
 "BeagleBone Green Wireless", "GRiSP2", "MangoPi MQ-Pro", "NPi i.MX6 ULL",
 "PocketBeagle", "Raspberry Pi 2B", "Raspberry Pi 3B", "Raspberry Pi 3B+",
 "Raspberry Pi 400", "Raspberry Pi 4B", "Raspberry Pi T-Cobbler",
 "Raspberry Pi Zero 2 W", "Raspberry Pi Zero W"]
```

これらのボード名を識別子として`Pinout.print/1`に渡すと、現在のボードに関係なくピン配列を印刷できます。

```elixir:IEx
Pinout.print("Raspberry Pi 4B")
```

```txt:出力例
╭----------------------------------╮
|  oooooooooooooooooooo       ╭-----╮
|  1ooooooooooooooooooo       |     |
|                             ╰-----╯
|                             ╭-----╮
|       Raspberry Pi 4B       |     |
|                             ╰-----╯
|                           ╭-------╮
|          ╭------╮         |       |
|  ╭--╮    |      |         ╰-------╯
╰--╰--╯----╰------╯-----------------╯
        3v3 Power  [1] [2]  5v Power
  GPIO 2/I2C1 SDA  [3] [4]  5v Power
  GPIO 3/I2C1 SCL  [5] [6]  Ground
    GPIO 4/GPCLK0  [7] [8]  GPIO 14/UART TX
           Ground  [9] [10] GPIO 15/UART RX
          GPIO 17 [11] [12] GPIO 18/PCM CLK
          GPIO 27 [13] [14] Ground
          GPIO 22 [15] [16] GPIO 23
        3v3 Power [17] [18] GPIO 24
GPIO 10/SPI0 MOSI [19] [20] Ground
 GPIO 9/SPI0 MISO [21] [22] GPIO 25
GPIO 11/SPI0 SCLK [23] [24] GPIO 8/SPI0 CE0
           Ground [25] [26] GPIO 7/SPI0 CE1
GPIO 0/EEPROM SDA [27] [28] GPIO 1/EEPROM SCL
           GPIO 5 [29] [30] Ground
           GPIO 6 [31] [32] GPIO 12/PWM0
     GPIO 13/PWN1 [33] [34] Ground
   GPIO 19/PCM FS [35] [36] GPIO 16
          GPIO 26 [37] [38] GPIO 20/PCM DIN
           Ground [39] [40] GPIO 21/PCM DOUT

```

## Nerves + Livebook

まだ、実際の組み込みハードウェア（[Raspberry Pi] 等）を使ったことがない方、組み込みの経験があるけど [Elixir] や [Nerves] を使ったことがない方には[Nerves Livebook]をオススメします。

[Nerves Livebook]を使用すると、何も構築せずに実際のハードウェアで [Nerves] プロジェクトを試すことができます。 数分以内に、[Raspberry Pi] や [Beaglebone] で [Nerves] を実行できるようになります。 [Livebook] でコードを実行し、ブラウザーで快適に [Nerves] チュートリアルを進めることができます。

有志の方々が [Nerves Livebook] のセットアップ方法ついてのビデオを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

[Livebook](https://livebook.dev/) のノートブック上でコードを実際に実行しながら進められるので、楽しく効率的に学べます。例えばブラウザ上で Wi-Fi の設定もできます。

- [WiFi 設定についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/configure_wifi.livemd)
- [VintageNet についてのノートブック](https://github.com/nerves-livebook/nerves_livebook/blob/main/priv/samples/networking/vintage_net.livemd)

[pinout パッケージ][cavocado/pinout] にもノートブックがあります。

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fcavocado%2Fpinout%2Fblob%2Fmain%2Fnotebooks%2Fbasics.livemd)

## インターネットで Raspberry Pi のピン配置確認

[https://pinout.xyz](https://pinout.xyz) も便利です。

https://pinout.xyz

:tada::tada::tada:

## 最後に一言

本記事は [闘魂 Elixir #65](https://autoracex.connpass.com/event/308573/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[Buildroot]: https://buildroot.org/
[cavocado/pinout]: https://hex.pm/packages/pinout
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[LFE]: https://en.wikipedia.org/wiki/LFE_(programming_language)
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Livebook]: https://livebook.dev/
[Mix]: https://hexdocs.pm/mix/Mix.html
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[Raspberry Pi Zero W]: https://www.raspberrypi.com/products/raspberry-pi-zero-w/
[Raspberry Pi]: https://www.raspberrypi.com/products/raspberry-pi-5/
[rebar]: https://github.com/erlang/rebar3
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[シェル]: https://ja.wikipedia.org/wiki/シェル
[ピン配置図]: https://en.wikipedia.org/wiki/Pinout
[対象ボード]: https://hexdocs.pm/nerves/targets.html

<!-- end links -->
