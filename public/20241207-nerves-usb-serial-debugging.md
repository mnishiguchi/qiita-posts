---
title: 'Nerves × Raspberry Pi: USB-シリアルケーブルを使ったデバッグ方法'
tags:
  - RaspberryPi
  - Elixir
  - IoT
  - USB-TTLシリアル変換
  - Nerves
private: false
updated_at: '2024-12-07T13:13:47+09:00'
id: 34cb9787894024187625
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

この記事では[Nerves] を活用した [Raspberry Pi][Raspberry Pi Zero WH] のデバッグにおいて、[USB to TTL シリアルケーブル]を使って[シリアル通信]してみます。

対象デバイスと直接シリアル通信することで、メンテナンスや[ファームウェア]異常時のデバッグに役立ちます。
ブート時のオペレーティングシステム（OS）のログも見れます。

また、[Wi-Fi][無線 LAN] や [Ethernet] が利用できない環境でも通信が可能です。

## 必要なもの

参考までに、この記事で使用する製品と環境は以下の通りです。

### ハードウェア

- [Adafruit USB to TTL Serial Cable]
- [Raspberry Pi Zero WH] (GPIO ピン付きモデル)

### ソフトウェア

- シリアルターミナルソフトウェア (例: `screen`、`picocom`)
- すでに Nerves プロジェクトの環境が構築済みの前提で進めます。

## 電子工作におけるシリアル通信

シリアル通信は、電子工作や IoT の分野で頻繁に使われる通信方法です。1[ビット](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88)ずつ、逐次的にデータを伝送するシンプルな仕組みが特徴です。

- **シリアル通信とは？**
  - [電気通信](https://ja.wikipedia.org/wiki/%E9%9B%BB%E6%B0%97%E9%80%9A%E4%BF%A1)の一種で、[伝送路](https://ja.wikipedia.org/wiki/%E4%BC%9D%E9%80%81%E8%B7%AF)上を逐次的にデータを送信する方式。
  - 一般的には[UART](https://ja.wikipedia.org/wiki/UART)を利用して、[シリアルポート](https://ja.wikipedia.org/wiki/%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%83%9D%E3%83%BC%E3%83%88)という入出力機器で通信。

### 参考リンク

- [シリアル通信（Wikipedia）](https://ja.wikipedia.org/wiki/シリアル通信)
- [シリアル通信を始めよう(Qiita 記事)](https://qiita.com/dz_/items/277eba8cb760b81a2688)
- [Nerves のワークフロー(YouTube)](https://www.youtube.com/watch?v=qoSNsmOp2zU)
- [Nerves のワークフロー(プレゼン資料)](https://slides.com/jasonmj/workflows-for-elixir-nerves#/6/0/0)
- [Raspberry Pi のシリアルポート設定（UART）を理解する](https://toki-blog.com/pi-serial/)

## USB to TTL シリアルケーブルとは

USB to TTL シリアルケーブルは、PC の USB ポートを介してデバイスとシリアル通信を可能にする変換ケーブルです。このケーブルは、電子工作や組み込みシステムのデバッグに広く利用されています。以下に主な特徴をまとめます。

### 主な特徴

- **シリアル通信の簡易化**: デバイスに直接接続するだけで、[UART] を介したシリアル通信が可能。
- **デバッグ用途に最適**: ブート時のログ確認や[ファームウェア]異常時のトラブルシューティングに役立ちます。
- **ネットワーク環境が不要**: Wi-Fi やイーサネットが使えない環境でもシリアル通信でアクセス可能。

### Nerves 開発での利点

- **デバッグの効率化**: ネットワークなしでも[ファームウェア]の動作確認が可能。
- **ブート時のログ取得**: 初回起動時やエラー時の詳細ログを確認できる。
- **IEx シェル操作**: Nerves プロジェクトのライブデバッグや設定変更が可能。

## Adafruit USB to TTL シリアルケーブル

この記事で使用する [Adafruit USB to TTL シリアルケーブル](https://www.adafruit.com/product/954) は、USB を介してデバイスとシリアル通信を可能にするチップを内蔵しています。このチップが PC とデバイス間のデータ変換を実現します。

以下の機能を備えています。

- 内蔵チップで USB と UART (TTL レベル) の信号変換を実現。
- 3.3V または 5V のシステムに対応。
- 公式ドライバーを使用して PC との接続が簡単。

詳細は、以下を参照してください。

- [Adafruit 製品ページ](https://www.adafruit.com/product/954)
- [Adafruit のチュートリアル](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable)

## ドライバーをインストール

Adafruit USB to TTL シリアルケーブルを使用するには、OS に応じたドライバーをインストールする必要があります。
ドライバーをインストールすることで、PC 上の仮想 COM ポートを介して通信が可能になります。

参考までに手順の概略を記しますが、詳細は[公式チュートリアル](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/overview)をご参照ください。

:::note info
Linux ユーザーは追加のドライバーインストールを省略できる可能性が高いです。まずは接続を試してください。
:::

### Windows と Mac

使用しているケーブルのチップセットに応じたドライバーをインストールする必要があります。

1. 次のいずれかのドライバーをダウンロード：
   - Prolifics 製のドライバー
   - SiLabs 製のドライバー
2. インストーラを実行し、画面の指示に従ってインストールを完了。
3. 必要に応じて PC を再起動してください。

:::note info
ケーブルのチップセットが不明な場合は、両方のドライバーをインストールしたら、どちらかがいい感じに適用されるようです。しらんけど。
:::

### Linux

Linux の場合、必要なドライバー (PL2303 および CP210X) はカーネル 2.4.31 以降に組み込まれているため、通常はドライバーの追加インストールは不要です。

## 配線方法

Adafruit USB to TTL シリアルケーブルの配線は簡単です。公式ドキュメントの手順を参考にしつつ、以下の通り接続してください：

### ケーブルの色とピンの対応

| ケーブルの色 | Raspberry Pi GPIO ピン |
| ------------ | ---------------------- |
| 黒 (GND)     | 6 (GND)                |
| 白 (RX)      | 8 (TXD)                |
| 緑 (TX)      | 10 (RXD)               |

:::note tip
赤いケーブル (5V) は接続しないでください。Raspberry Pi は自身で電源を供給します。
:::

![DSC_0129.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/9248c832-4a80-a385-7482-fffb79988def.jpeg)

[![](https://user-images.githubusercontent.com/7563926/181919087-03649fb1-b7c5-4601-bbb4-994fb07ea39e.png)](https://pinout.xyz/pinout/uart)

[Elixir]で Raspberry Pi のピン配置を確認することもできます。

https://qiita.com/mnishiguchi/items/b08c920f841996d1cdaf

詳しくは [Adafruit の配線ガイド](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/connect-the-lead) を参照してください。

## シリアルターミナルソフトウェアをインストール

Adafruit USB to TTL シリアルケーブルを使って、Raspberry Pi からのログを確認するには、シリアルターミナルソフトウェアを使用します。

オープンソースのシリアル接続クライアントをいくつか列挙します。

- [screen](https://en.wikipedia.org/wiki/GNU_Screen)
- [picocom](https://github.com/npat-efault/picocom)
- [bootterm](https://github.com/wtarreau/bootterm)
- [tio](https://github.com/tio/tio)

ここでは、`screen` と`picocom`の使い方を紹介します。

必要に応じて、インストールしてください。

**Ubuntu/Debian 系**:

```bash
sudo apt install screen picocom
```

**Mac (Homebrew)**:

```bash
brew install screen picocom
```

## `screen` を実行する方法

```bash
screen /dev/ttyUSB0 115200
```

- `/dev/ttyUSB0` は接続したデバイスに応じて変更してください。
- 終了する場合は、`Ctrl+A` を押してから `K` を入力し、`y` で確認。

## `picocom` を実行する方法

```bash
picocom /dev/ttyUSB0 -b 115200
```

- `-b` オプションでボーレートを指定します。
- 終了する場合は、`Ctrl+A` を押してから `Ctrl+X` を入力します。

以下は出力の例です。

```
mnishiguchi@thinkpad:~ 1m57s
$ ls /dev/tty*
/dev/tty   /dev/tty6   /dev/tty13  /dev/tty20  /dev/tty27  /dev/tty34  /dev/tty41  /dev/tty48  /dev/tty55  /dev/tty62
/dev/tty0  /dev/tty7   /dev/tty14  /dev/tty21  /dev/tty28  /dev/tty35  /dev/tty42  /dev/tty49  /dev/tty56  /dev/tty63
/dev/tty1  /dev/tty8   /dev/tty15  /dev/tty22  /dev/tty29  /dev/tty36  /dev/tty43  /dev/tty50  /dev/tty57  /dev/ttyS0
/dev/tty2  /dev/tty9   /dev/tty16  /dev/tty23  /dev/tty30  /dev/tty37  /dev/tty44  /dev/tty51  /dev/tty58  /dev/ttyS1
/dev/tty3  /dev/tty10  /dev/tty17  /dev/tty24  /dev/tty31  /dev/tty38  /dev/tty45  /dev/tty52  /dev/tty59  /dev/ttyS2
/dev/tty4  /dev/tty11  /dev/tty18  /dev/tty25  /dev/tty32  /dev/tty39  /dev/tty46  /dev/tty53  /dev/tty60  /dev/ttyS3
/dev/tty5  /dev/tty12  /dev/tty19  /dev/tty26  /dev/tty33  /dev/tty40  /dev/tty47  /dev/tty54  /dev/tty61  /dev/ttyUSB0

mnishiguchi@thinkpad:~
$ picocom /dev/ttyUSB0 -b 115200
picocom v3.1

port is        : /dev/ttyUSB0
flowcontrol    : none
baudrate is    : 115200
parity is      : none
databits are   : 8
stopbits are   : 1
escape is      : C-a
local echo is  : no
noinit is      : no
noreset is     : no
hangup is      : no
nolock is      : no
send_cmd is    : sz -vv
receive_cmd is : rz -vv -E
imap is        :
omap is        :
emap is        : crcrlf,delbs,
logfile is     : none
initstring     : none
exit_after is  : not set
exit is        : no

Type [C-a] [C-h] to see available commands
Terminal ready
warning: :simple_one_for_one strategy is deprecated, please use DynamicSupervisor instead
  (elixir 1.16.2) lib/supervisor.ex:762: Supervisor.init/2
  (stdlib 5.2.1) supervisor.erl:330: :supervisor.init/1
  (stdlib 5.2.1) gen_server.erl:980: :gen_server.init_it/2
  (stdlib 5.2.1) gen_server.erl:935: :gen_server.init_it/6
  (stdlib 5.2.1) proc_lib.erl:241: :proc_lib.init_p_do_apply/3

[Livebook] Application running at http://nerves-777f.local/
Erlang/OTP 26 [erts-14.2.3] [source] [32-bit] [smp:1:1] [ds:1:1:10] [async-threads:1]

Interactive Elixir (1.16.2) - press Ctrl+C to exit (type h() ENTER for help)
████▄▄    ▐███
█▌  ▀▀██▄▄  ▐█
█▌  ▄▄  ▀▀  ▐█   N  E  R  V  E  S
█▌  ▀▀██▄▄  ▐█
███▌    ▀▀████
nerves_livebook 0.12.3 (a54e5048-1af7-5244-61ec-afe6d4eaf5bc) arm rpi0
  Serial       : 777f
  Uptime       : 37.380 seconds
  Clock        : 2024-06-22 09:20:17 UTC (unsynchronized)
  Temperature  : 31.5°C

  Firmware     : Valid (A)               Applications : 113 started
  Memory usage : 85 MB (27%)             Part usage   : 0 MB (0%)
  Hostname     : nerves-777f             Load average : 0.70 0.19 0.06

  usb0         : 172.31.7.141/30

Nerves CLI help: https://hexdocs.pm/nerves/iex-with-nerves.html

Toolshed imported. Run h(Toolshed) for more info.
iex(livebook@nerves-777f.local)1> IO.puts "元氣ですかー"
元氣ですかー
:ok
iex(livebook@nerves-777f.local)2>
```

## トラブルシューティング

- **ログが表示されない場合**:
  1. 配線を確認してください (特に GND)。
  2. `RX` と `TX` を入れ替えてみてください。
- **文字化け**:
  - ボーレート (115200) が正しく設定されているか確認してください。

詳細は[公式チュートリアル](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/test-and-configure)
を参照してください。

## おわりに

この記事では、Adafruit USB to TTL シリアルケーブルを用いた Nerves プロジェクトのデバッグ手法を紹介しました。

記事が、Nerves プロジェクトを始めるきっかけとなれば幸いです。

ぜひ [NervesJP Advent Calendar 2024](https://qiita.com/advent-calendar/2024/nervesjp) もご覧いただき、IoT を Nerves をたのしんでいきましょう！

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

あ、よく考えたら過去にも似たようなメモをまとめてましたね。そのうちまた整理します！

- [USB-Serial ケーブルで Raspberry Pi をデバッグする](https://qiita.com/mnishiguchi/items/dc5a88e8d16a4a878248)
- [Elixir/Nerves UART でシリアルコンソール接続](https://qiita.com/mnishiguchi/items/dddbac0262bcff4dca23)
- [USB-シリアルケーブルを簡単かつ安全に Raspberry Pi に接続する方法](https://qiita.com/mnishiguchi/items/db574d3aac1653e9ffa3)

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
[Adafruit USB to TTL Serial Cable]: https://www.adafruit.com/product/954

<!-- end links -->
