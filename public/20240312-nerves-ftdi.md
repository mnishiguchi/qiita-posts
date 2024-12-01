---
title: 'Nerves × Raspberry Pi: FTDIケーブルを使ったデバッグ方法'
tags:
  - RaspberryPi
  - Elixir
  - IoT
  - USB-TTLシリアル変換
  - Nerves
private: false
updated_at: '2024-12-07T13:13:47+09:00'
id: dc5a88e8d16a4a878248
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir] [Nerves] で構築した [Raspberry Pi Zero WH] に対して、 FTDI ケーブルを使って[シリアル通信]してみます。

対象デバイスと直接シリアル通信するので、メンテナンスや[ファームウェア]に異常がある場合のデバッグに有用です。ブート時のオペレーティングシステム（OS）のログも見れます。

また、[Wi-Fi][無線 LAN] や [Ethernet] が使えない環境でも通信できるので便利です。

## Elixir と Nerves で Raspberry Pi を氣樂に試す

https://qiita.com/mnishiguchi/items/d2df8cac1f973204b843

## 電子工作におけるシリアル通信

- [電気通信](https://ja.wikipedia.org/wiki/%E9%9B%BB%E6%B0%97%E9%80%9A%E4%BF%A1)において[伝送路](https://ja.wikipedia.org/wiki/%E4%BC%9D%E9%80%81%E8%B7%AF)上を一度に 1[ビット](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88)ずつ、逐次的にデータを送る
- [UART](https://ja.wikipedia.org/wiki/UART)を使った[シリアルポート](https://ja.wikipedia.org/wiki/%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%83%9D%E3%83%BC%E3%83%88)という入出力機器でこのシリアル通信システムに接続

https://ja.wikipedia.org/wiki/シリアル通信

https://qiita.com/dz_/items/277eba8cb760b81a2688

https://slides.com/jasonmj/workflows-for-elixir-nerves#/6/0/0

https://www.youtube.com/watch?v=qoSNsmOp2zU

## FTDI ケーブルとは

- FTDI チップを内蔵した USB シリアル変換ケーブル
- 対象デバイスの基板上にピンヘッダを用意するだけで PC とのシリアル通信が可能
- 内蔵されたチップに対応するドライバーを PC にインストールする必要があり

https://www.google.com/search?q=FTDI%20%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB

https://www.adafruit.com/product/70

https://www.sparkfun.com/products/9717

:::note info
FTDI チップでないチップ（SiLabs CP210x、Prolific PL2303 等）を内蔵した USB シリアル変換ケーブルもあります。それらは厳密にいうと FTDI ケーブルではありませんが、使い方は同じようです。

- https://www.adafruit.com/product/954
- https://www.digikey.com/en/products/detail/olimex-ltd/USB-SERIAL-F/3471379

:::

## FTDI のドライバーをインストール

1. [ドライバー](https://ftdichip.com/drivers/vcp-drivers/)を FTDI 社のサイトからダウンロード（[マニュアル](https://ftdichip.com/document/installation-guides/)）
1. FTDI ケーブルの USB コネクタを一度 PC に接続
1. ドライバーをインストール

## FTDI ケーブルのピン

FTDI ケーブルの USB コネクタでない方は製品により、ピンが 4 個のものや 6 個のものがあるそうですが、[Elixir] [Nerves] での使い方は同じです。

Raspberry Pi には既に電源が供給されているので FTDI ケーブルの電源のピンは使いません。

| FTDI ケーブル ピン名 | 説明       |
| -------------------- | ---------- |
| RX                   | 受信用ピン |
| TX                   | 送信用ピン |
| GND                  | グランド   |
| VCC                  | 電源を出力 |

ネットワーク通信の文脈では「TX (送信)」「RX (受信)」という言葉がよく使用されるようです。

| FTDI ケーブル | 通信の方向 | Raspberry Pi |
| ------------- | ---------- | ------------ |
| TX (送信)     | →          | RX (受信)    |
| RX (受信)     | ←          | TX (送信)    |

## FTDI ケーブルの接続方法

Raspberry Pi のピン 6、8、10 が便利です。

- FTDI ケーブルの GND は、Raspberry Pi の GND に接続
- FTDI ケーブルの RX は、Raspberry Pi の UART TX に接続
- FTDI ケーブルの TX は、Raspberry Pi の UART RX に接続

| FTDI ケーブル ピン名 | Raspberry Pi ピン名 | Raspberry Pi ピン番号 |
| -------------------- | ------------------- | --------------------- |
| RX                   | UART TX (GPIO 14)   | 8                     |
| TX                   | UART RX (GPIO 15)   | 10                    |
| GND                  | GND                 | 6                     |

[![](https://user-images.githubusercontent.com/7563926/181919087-03649fb1-b7c5-4601-bbb4-994fb07ea39e.png)](https://pinout.xyz/pinout/uart)

[Elixir]で Raspberry Pi のピン配置を確認することもできます。

https://qiita.com/mnishiguchi/items/b08c920f841996d1cdaf

## シリアル接続 CLI クライアントをインストール

FTDI ケーブルは、テキスト出力を標準のシリアル USB ポートに変換します。
[シリアルコンソール] をサポートするオープンソースのシリアル接続クライアントがいくつかあります。

- [screen](https://en.wikipedia.org/wiki/GNU_Screen)
- [picocom](https://github.com/npat-efault/picocom)
- [bootterm](https://github.com/wtarreau/bootterm)
- [tio](https://github.com/tio/tio)

## シリアル接続 CLI クライアントを実行

```bash:ホストPCのターミナルでpicocomを使う場合
picocom /dev/tty.usb* -b 115200
```

`usb*`は自動的にホストマシン上の USB ポート名に展開されます。

[Nerves] のファームウエアが起動している場合には、`iex(1)>`プロンプトが表示されると思います。

何も表示されない場合は、Enter を数回押してみてください。それでもだめなら RX と TX を入れ替えてみてください。

`screen` コマンドの使い方は下記の記事に書かれています。

https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/test-and-configure

## さいごに一言

よく考えたら過去にも似たようなメモをまとめてました。

https://qiita.com/mnishiguchi/items/dddbac0262bcff4dca23

本記事は [闘魂 Elixir #72](https://autoracex.connpass.com/event/312394/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[asdf plugins]: https://asdf-vm.com/manage/plugins.html
[asdf]: https://asdf-vm.com/
[bash]: https://ja.wikipedia.org/wiki/Bash
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[Buildroot]: https://buildroot.org/
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang versions]: https://github.com/erlang/otp/tags
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[Ethernet]: https://ja.wikipedia.org/wiki/Ethernet
[fwup]: https://github.com/fwup-home/fwup
[Gadget Mode]: http://www.linux-usb.org/gadget/
[hex]: https://github.com/hexpm/hex
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[LAN ケーブル]: https://search.brave.com/images?q=LAN%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB&source=web
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Livebook]: https://livebook.dev/
[microSD カード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[Mix]: https://hexdocs.pm/mix/Mix.html
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Systems Builder]: https://github.com/nerves-project/nerves_systems
[nerves systems compatibility]: https://hexdocs.pm/nerves/systems.html#compatibility
[Nerves Target]: https://hexdocs.pm/nerves/supported-targets.html
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[nerves_system_br]: https://github.com/nerves-project/nerves_system_br
[nerves_system_rp4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_systems]: https://github.com/nerves-project/nerves_systems
[nerves]: https://github.com/nerves-project/nerves
[Nerves]: https://github.com/nerves-project/nerves
[Phoenix]: https://www.phoenixframework.org/
[PowerShell]: https://learn.microsoft.com/en-us/powershell/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[Raspberry Pi Zero WH]: https://www.switch-science.com/products/3646
[Raspberry Pi Zero]: https://www.raspberrypi.com/products/raspberry-pi-zero/
[Raspberry Pi]: https://www.raspberrypi.com/
[rebar]: https://github.com/erlang/rebar3
[rebar]: https://github.com/erlang/rebar3
[rebar3]: https://github.com/erlang/rebar3
[SD カードリーダー]: https://search.brave.com/images?q=SD+%E3%82%AB%E3%83%BC%E3%83%89%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC
[SDカード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
[SFTP]: https://ja.wikipedia.org/wiki/SSH_File_Transfer_Protocol
[SquashFS]: https://ja.wikipedia.org/wiki/SquashFS
[systemd]: https://wiki.archlinux.jp/index.php/Systemd
[UART]: https://ja.wikipedia.org/wiki/UART
[Ubuntu]: https://ubuntu.com/
[USB On-The-Go]: https://ja.wikipedia.org/wiki/USB_On-The-Go
[USB to TTL シリアルケーブル]: https://search.brave.com/images?q=USB%20to%20TTL%20%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB
[USB WiFi ドングル]: https://search.brave.com/images?q=+USB+WiFi+%E3%83%89%E3%83%B3%E3%82%B0%E3%83%AB&source=web
[USB ガジェットモード]: http://www.linux-usb.org/gadget/
[USB ケーブル]: https://search.brave.com/images?q=USB+cable+for+Raspberry+Pi&source=web
[USB]: https://ja.wikipedia.org/wiki/%E3%83%A6%E3%83%8B%E3%83%90%E3%83%BC%E3%82%B5%E3%83%AB%E3%83%BB%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%83%BB%E3%83%90%E3%82%B9
[アーカイブ]: https://ja.wikipedia.org/wiki/アーカイブ_(コンピュータ)
[イーサネット]: https://ja.wikipedia.org/wiki/Ethernet
[インクリメンタルビルド]: https://ja.wikipedia.org/wiki/ビルド_(ソフトウェア)
[オープンソース]: https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E3%82%BD%E3%83%BC%E3%82%B9
[クロスコンパイラ]: https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9
[シェル]: https://ja.wikipedia.org/wiki/シェル
[シリアル通信]: https://ja.wikipedia.org/wiki/シリアル通信
[ブートローダ]: https://wiki.archlinux.jp/index.php/Arch_%E3%83%96%E3%83%BC%E3%83%88%E3%83%97%E3%83%AD%E3%82%BB%E3%82%B9
[ファームウェア]: https://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A1%E3%83%BC%E3%83%A0%E3%82%A6%E3%82%A7%E3%82%A2
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[対象ボード]: https://hexdocs.pm/nerves/targets.html
[無線 LAN]: https://ja.wikipedia.org/wiki/%E7%84%A1%E7%B7%9ALAN
[組み込みシステム]: https://ja.wikipedia.org/wiki/%E7%B5%84%E3%81%BF%E8%BE%BC%E3%81%BF%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0
[シリアルコンソール]: https://wiki.archlinux.jp/index.php/%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%82%B3%E3%83%B3%E3%82%BD%E3%83%BC%E3%83%AB

<!-- end links -->
