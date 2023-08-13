---
title: Elixir/Nerves UARTでシリアルコンソール接続
tags:
  - RaspberryPi
  - Elixir
  - Nerves
  - 40代駆け出しエンジニア
  - AdventCalendar2022
private: false
updated_at: '2022-09-14T10:44:30+09:00'
id: dddbac0262bcff4dca23
organization_url_name: fukuokaex
slide: false
---
## はじめに

[NervesJP #28 夏休みにNervesでこんなんやってみましたLT回！！](https://nerves-jp.connpass.com/event/257021/)でのLTを目標に取り組んだ活動をまとめます。技術力はありません。ただ楽しんでいます。

組み込み開発の基本中の基本（多分）のUARTシリアルコンソール接続をまだやったことがなかったので、挑戦しました。

https://nerves-jp.connpass.com/event/257021

Nervesマシンに接続する方法は複数ありますが、僕は基本的に今までずっとUSBもしくはWiFiでホストマシンからRaspberry Pi Zero Wに接続して通信するパターンのみでやってきました。

USBでの接続は一見簡単で便利そうなのですが、トラブルも起こりがちです。
例えば、USBケーブルが充電専用の場合はデータ通信ができないのですが、見た目で区別するのが困難です。
また、ブート時に問題がある場合に何も見ることができません。

ベテランのNervesアルケミストや組込エンジニアの話を聞いていると、どうもUARTシリアルコンソール接続がよく使用されるらしいです。
ネットワークやブートプロセスのデバグ、および高度な開発ワークフローに役立つそうです。

https://slides.com/jasonmj/workflows-for-elixir-nerves#/4

https://youtu.be/qoSNsmOp2zU

## USB-to-TTLシリアルケーブルを入手する

バラ線がRaspberry PiのUARTピンにつながり、USBコネクタが開発ホストマシンにつながります。

おそらく初めての場合は開発ホストマシンにケーブルを使用するためのドライバーをインストールする必要があります。

![](https://user-images.githubusercontent.com/7563926/186284357-3a3866c6-a19e-4a22-88bc-f24e5d7a1c4e.jpg)

以下の記事の序盤に詳しく説明されています。

https://toki-blog.com/pi-serial

## Nervesが各ターゲットに対してどのような機能をサポートしているか確認

各ターゲットでデフォルトの機能が異なります。
言い換えると、Raspberry Pi Zero W (`rpi0`)とRaspberry Pi 3 (`rpi3`)とでは初期設定が異なります。

`nerves_system_<ターゲット名>`プロジェクトのドキュメントを参照してください。
例えば、ターゲットがRaspberry Pi Zero(`rpi0`）の場合、https://hexdocs.pm/nerves_system_rpi0 にアクセスしてみてください。

そしてそのNerveシステムがIExターミナル機能をどのようにサポートしているかを調べます。

本記事を書いている時点で、[nerves_system_rpi0] (Raspberry Pi Zero用のNervesシステム)のドキュメントには、（初期設定で）`ttyAMA0`という名称のUARTポートがIExターミナルに使用できると書かれています。

![](https://user-images.githubusercontent.com/7563926/181918220-00733048-8706-4b40-957d-b621d308fc2f.png)

ちなみにこれは`nerves_system_rpi0`のソースコードの[ここ](https://github.com/nerves-project/nerves_system_rpi0/blob/ddb128989cf9bb28dd78f4467992d00b89828f02/rootfs_overlay/etc/erlinit.config#L12)で設定されています。

ソフトウエア（Linux）の`/dev/ttyAMA0`というデバイスファイルは、ハードウエア（Raspberry Pi Zero）上では`UART0`という名称になっており、それがGPIOの8番ピンと10番ピンに対応するそうです。

![](https://user-images.githubusercontent.com/7563926/181919087-03649fb1-b7c5-4601-bbb4-994fb07ea39e.png)

Image credit: https://pinout.xyz

ターゲットによっては初期設定がHDMIディスプレイをUSBキーボードを使用する前提となっています。
そのようなターゲット上でUARTシリアルコンソールをメインで使用したい場合は、初期設定を上書きすることができます。
Nerves公式ドキュメントをご覧ください。

 https://hexdocs-pm.translate.goog/nerves/faq.html?_x_tr_sl=en&_x_tr_tl=ja&_x_tr_hl=en&_x_tr_pto=wapp#using-a-usb-serial-console


[raspberry pi zero]: https://www.raspberrypi.com/products/raspberry-pi-zero-w
[raspberry pi zero w]: https://www.raspberrypi.com/products/raspberry-pi-zero-w
[nerves_system_rpi0]: https://hexdocs.pm/nerves_system_rpi0

## 配線

| Raspberry Pi             | USB-to-TTL Serial Cable |
| ------------------------ | ----------------------- |
| `TX0` (pin 8 / GPIO 14)  | `RX`                    |
| `RX0` (pin 10 / GPIO 15) | `TX`                    |
| `GND`                    | `GND`                   |

4本バラ線が出ていると思いますが、ここでの目的はシリアルデータ通信であるため、電力線は必要ありません。

https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/connect-the-lead

## 端末エミュレータをインストール

USB-to-TTLシリアル ケーブルは、テキスト出力を標準のシリアルUSBポートに変換します。
シリアルコンソールをサポートするオープンソースの端末エミュレータプログラムがいくつかあります。
他にもおすすめのものがありましたら、お便りください。

- [picocom](https://github.com/npat-efault/picocom)
- [bootterm](https://github.com/wtarreau/bootterm)
- [tio](https://github.com/tio/tio)
- [screen](https://en.wikipedia.org/wiki/GNU_Screen)

## 端末エミュレータを実行

```bash
picocom /dev/tty.usb* -b 115200
```

`usb*`は自動的にホストマシン上のUSBポート名に展開されます。

`iex(1)>`プロンプトが表示されると思います。そうでない場合は、Enterを数回押してみてください。

## さいごに

せっかく新しいことを学んだので、世界の初心者Nervesアルケミストたちと共有したく思い、ついでに[autoracex](https://autoracex.connpass.com/)でモクモクとNerves公式ドキュメントのアップデートに取り組みました。

[日本語版](https://hexdocs-pm.translate.goog/nerves/connecting-to-nerves-target.html?_x_tr_sl=en&_x_tr_tl=ja&_x_tr_hl=en&_x_tr_pto=wapp) | [英語版](https://hexdocs.pm/nerves/connecting-to-nerves-target.html)

https://autoracex.connpass.com

https://github.com/nerves-project/nerves/pull/775

https://github.com/nerves-project/nerves/pull/776

@MickeyOohさんが立ち上げ中のログにログを表示させる方法についてまとめてくださってます。

https://qiita.com/MickeyOoh/items/581a7dddc811c4ceba0f

Elixirを楽しみましょう！

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf#_reference-cd6d9a3b524df507752a

# <u><b>Elixirコミュニティに初めて接する方は下記がオススメです</b></u>

**Elixirコミュニティ の歩き方 －国内オンライン編－**<br>
https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

[![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/155423/f891b7ad-d2c4-3303-915b-f831069e28a4.png)](https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian)

**日本には28箇所のElixirコミュニティがあります**<br>
![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/155423/7fdc5db7-dfad-9d10-28f8-1e0b8830a587.png)

## 日程からイベントを探すならElixirイベントカレンダー:calendar:

https://elixir-jp-calendar.fly.dev

[![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/109744/985acaa4-50c9-da42-ae32-50fbf9119e61.png)](https://elixir-jp-calendar.fly.dev/)
