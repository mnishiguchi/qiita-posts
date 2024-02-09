---
title: ElixirとNervesでRaspberry Piを氣樂に試す
tags:
  - Linux
  - RaspberryPi
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-02-09T10:55:12+09:00'
id: d2df8cac1f973204b843
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir]と[Nerves]で[Raspberry Pi]を氣樂にやってみましょう！

とりあえず[Raspberry Pi]を買ってみたものの、何から始めていいのか分からず戸惑ってしまう方もいらっしゃると思います。僕もそうでした。

[Raspberry Pi]は汎用コンピュータなので、いろんな方々が多様な形で楽しんでいます。選択肢が多いだけに決断ができないと何も始まりません。

僕はたまたま [Elixir]プログラミングが大好きだったので、迷わず [Elixir]と[Nerves]で[Raspberry Pi]を樂しむことにしました。

[Elixir]と[Nerves]で[Raspberry Pi]と聞くと一般に世の中に出回っている[Raspberry Pi]関連の情報にはあまり登場しないので、一見怖そうに見えるかもしれません。

しかしながら、[Nerves]は、[オープンソース]の[自由ソフトウェア]プロジェクトであり、Nerves コアチームのメンバーが実際に本番環境で使用しているので、その知見に基づいたおススメの設定や開発環境が漏れなく手に入るという点で大変コスパが良いと言えます。初見のプログラマーや組み込み技術者でも最低限の設定やコーディングで高度な[組み込みシステム]の構築ができてしまいます。

また、[組み込みシステム]の構築だけに特化されているので、そこに集中して取り組めます。

特に[Elixir]プログラミング言語をやったことがある人はすぐにでも取り掛かれるでしょうし、まだ[Elixir]を試したことがない方にとっても、[Elixir]や[Erlang 仮想マシン (BEAM)][Erlang VM]について知る良い機会になると信じています。

https://hexdocs.pm/nerves/getting-started.html

さらに最近は、[Nerves Livebook](https://github.com/nerves-livebook/nerves_livebook)という予めビルドされたファームウェアが公開されているので、それをダウンロードして[microSD カード]に焼くだけで簡単に氣樂に[Nerves]を樂しめるようになりました。[Livebook] のノートブック上でコードを実際に実行しながら進められるので、ブラウザーで快適に 楽しく[Nerves] を学べます。

## Nerves（なあぶす）とは

- [Elixir]と[Erlang 仮想マシン (BEAM)][Erlang VM]を活用して高度な[組み込みシステム]を構築する新しい手法を定義
- デスクトップやサーバーシステムではなく、[組み込みシステム]向けに特化
- 基盤（platform）、枠組（framework）、道具（tooling） の 3 要素で成り立っている

| 構成要素 | 説明                                                                                      |
| -------- | ----------------------------------------------------------------------------------------- |
| 基盤     | [Erlang 仮想マシン (BEAM)][Erlang VM]を直接起動する、最小限の [Linux]                     |
| 枠組     | 開発を効率よく行うための便利な関数を備えた [Elixir] モジュール                            |
| 道具     | ビルドの管理、[ファームウェア] の更新、デバイスの構成などを行うためのコマンドラインツール |

https://www2.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

Qiita でも検索してみてください。

https://qiita.com/search?q=nerves

本や動画もあります。

https://www.kinokuniya.co.jp/f/dsg-08-EK-1648153

https://nerves-project.org/learn/

是非お気軽に [Nerves JP コミュニティー](https://nerves-jp.connpass.com)にお立ち寄りください!

https://nerves-jp.connpass.com

英語が大丈夫な方には英語のコミュニティもあります。

- [Elixir Discord #nerves channel](https://discord.gg/elixir)
- [Nerves Forum](https://elixirforum.com/c/elixir-framework-forums/nerves-forum/74)
- [Nerves Meetup](https://www.meetup.com/nerves)
- [Nerves Newsletter](https://underjord.io/nerves-newsletter.html)

## Nerves Livebook とは

[Nerves Livebook]を使用すると、何も構築せずに実際のハードウェアで [Nerves] プロジェクトを試すことができます。
[Livebook] のノートブック上でコードを実際に実行しながら進められるので、ブラウザーで快適に 楽しく[Nerves] を学べます。例えば、ブラウザ上でターゲットデバイスの Wi-Fi の設定ができます。

- [WiFi 設定についてのノートブック](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fnerves-livebook%2Fnerves_livebook%2Fblob%2Fe33efa88c907204e299431815a13cdfd0fcbd6c0%2Fpriv%2Fsamples%2Fnetworking%2Fconfigure_wifi.livemd)
- [ネットワーク インターフェイス についてのノートブック](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fnerves-livebook%2Fnerves_livebook%2Fblob%2Fe33efa88c907204e299431815a13cdfd0fcbd6c0%2Fpriv%2Fsamples%2Fnetworking%2Fvintage_net.livemd)
- [ピン配置 についてのノートブック](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fcavocado%2Fpinout%2Fblob%2Fmain%2Fnotebooks%2Fbasics.livemd)

https://qiita.com/search?q=elixir+nerves+livebook

https://qiita.com/torifukukaiou/items/2f7c9f460fde510356e8

https://qiita.com/torifukukaiou/items/dfe1577004f36b8b77d7

https://qiita.com/ohisama@github/items/3abb3fda6397a560085b

https://qiita.com/torifukukaiou/items/66e21a5a497ef5dbf4b2

https://qiita.com/torifukukaiou/items/809bac6d3445403aec5f

## 用語

| 用語                                      | 定義                                                                                                                                               |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 母艦マシン（host）                        | ソースコードの編集、[ファームウェア] のコンパイル、組立を行うコンピュータ                                                                          |
| ターゲット（target）                      | [ファームウェア] を構築する対象の機種 (例、Raspberry Pi Zero W、Raspberry Pi 4、Beaglebone Black など)                                             |
| ツールチェーン（toolchain）               | コンパイラ、リンカー、binutils、C ランタイムなど、ターゲットのコードを構築するために必要なツール                                                   |
| システム（system）                        | 特定のターゲット向けにカスタマイズおよび[クロスコンパイル][クロスコンパイラ]された、無駄のない [Buildroot] ベースの [Linux ディストリビューション] |
| ファームウェアバンドル（firmware bundle） | [ファームウェア] を焼くために必要なものすべてを含む単一のファイル                                                                                  |
| ファームウェアイメージ（firmware image）  | ファームウェアバンドル から構築される。[パーティションテーブル]、パーティション、[ブートローダ]などがここに含まれる。                              |

## 最小要件

- 母艦マシン
  - macOS、[Linux]、または Windows
- [Linux] を実行できるハードウェア (ターゲット)
  - [Nerves コアチームが公式にサポートしているターゲットの一覧][Nerves Target]
- [microSD カード]
  - ターゲットデバイスに挿入する[ファームウェア]記憶媒体
- [SD カードリーダー]
  - [ファームウェア]を[microSD カード]に焼く（burn）時に使用
  - 母艦マシン に SD カードスロットがついている場合は不要
- 電源供給ケーブル
  - ターゲットデバイスに電源を供給
  - ない場合は [USB ケーブル]で代用可能
- [USB ケーブル]（任意）
  - ターゲットデバイスに電源を供給
  - [Raspberry Pi Zero]、[Raspberry Pi 4]、[Beaglebone]を使用する場合は、ネットワーク接続にも使用可能
- [LAN ケーブル]（任意）
  - ターゲットデバイスにネットワーク接続
- [USB to TTL シリアルケーブル]（任意）
  - 直接ターゲットデバイスとシリアル通信するのに使用

:::note info
[USB ケーブル]には見た目では分かりにくいですが、色んな種類（充電用、データ転送用など）があります。うまくいかない場合は、ケーブルを取り替えるだけで解決する場合があります。

コネクタの形状も多数存在します。お使いのデバイスのコネクタに合うものを入手してください。
:::

## 母艦マシン

[Nerves] は、主に、macOS および様々な [Linux ディストリビューション] で使用されています。
Windows ユーザーの場合、[仮想機械]で [Linux] を実行したり、[Linux 用 Windows サブシステム]を使用したりして環境構築します。

## Nerves Livebook の準備

有志の方々が [Nerves Livebook] のセットアップ方法ついてのビデオやコラムを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

### fwup をインストール

[fwup] は、ファームウェアイメージを[microSD カード]に焼いたりするのに使うコマンドラインユーティリティです。

母艦マシン の OS によりインストール方法が異なるので、[ドキュメント](https://github.com/fwup-home/fwup#installing)をご参照ください。

https://github.com/fwup-home/fwup#installing

### ファームウェアイメージをダウンロード

まずは[Nerves Livebook Releases](https://github.com/nerves-livebook/nerves_livebook/releases)ページで、お手持ちのターゲットデバイスに対応するファームウェアイメージ（`.fw`ファイル）をダウンロードします。例として、ターゲットが[Raspberry Pi 4]の場合には`nerves_livebook_rpi4.fw`をダウンロードします。

https://github.com/nerves-livebook/nerves_livebook/releases

## ファームウェアを microSD カードに焼く

ターゲットデバイス向けのファームウェアはデバイスに差し込まれた[microSD カード]から起動します。今からその[microSD カード]を準備します。

先ほどダウンロードしたファームウェアイメージの存在するディレクトリに移動し、[fwup] を使用してファームウェアを[microSD カード]に焼きます。

```bash:母艦マシンのターミナル
fwup nerves_livebook_rpi4.fw
```

```bash:出力の例
Use 15.84 GB memory card found at /dev/rdisk2? [y/N] y
Depending on your OS, you'll likely be asked to authenticate this action. Go ahead and do so.

|====================================| 100% (31.81 / 31.81) MB
Success!
Elapsed time: 3.595 s
```

:::note warn
[fwup]を実行すると[microSD カード]がフォーマットされ、[microSD カード]上のすべてのデータが失われますのでご注意ください。
:::

:::note info
[環境変数`NERVES_WIFI_SSID`、`NERVES_WIFI_SSID`](https://github.com/nerves-livebook/nerves_livebook?tab=readme-ov-file#firmware-provisioning-options)をセットすることにより、前もって WiFi 認証情報も一緒に [microSD カード]に書き込んでおくことができます。
:::

## ターゲットデバイスへの接続方法

[ターゲットデバイス][Nerves Target]への接続方法は複数考えられます。

- [LAN ケーブル] ([イーサネット])
- [USB ケーブル] ([USB ガジェットモード])
- [USB to TTL シリアルケーブル] ([UART])
- Wi-Fi ([無線 LAN])

https://youtu.be/qoSNsmOp2zU?si=khX9H6z2KCQZQoJa

お使いの[ターゲットデバイス][Nerves Target]によりサポートされている接続方法が異なります。

|                           | Nerves System                                  | Gadget Mode | UART | Ethernet | Wi-Fi                                    |
| ------------------------- | ---------------------------------------------- | ----------- | ---- | -------- | ---------------------------------------- |
| [Raspberry Pi Zero]       | [rpi0][nerves_system_rpi0]                     | ✓           | ✓    | x        | x                                        |
| [Raspberry Pi Zero W]     | [rpi0][nerves_system_rpi0]                     | ✓           | ✓    | x        | ✓                                        |
| [Raspberry Pi Zero 2 W]   | [rpi3a][nerves_system_rpi3a]                   | ✓           | ✓    | x        | ✓                                        |
| [Raspberry Pi 3 Model B]  | [rpi3][nerves_system_rpi3]                     | x           | ✓    | ✓        | ✓                                        |
| [Raspberry Pi 4 Model B]  | [rpi4][nerves_system_rpi4]                     | ✓           | ✓    | ✓        | ✓                                        |
| [BeagleBone-based boards] | [bbb][nerves_system_bbb]                       | ✓           | ✓    | ✓        | ✓ (機種により [USB WiFi ドングル]が必要) |
| [MangoPi MQ Pro]          | [mangopi_mq_pro][nerves_system_mangopi_mq_pro] | ✓           | ✓    | x        | ✓                                        |

[Raspberry Pi Zero]: https://www.raspberrypi.com/products/raspberry-pi-zero/
[Raspberry Pi Zero W]: https://www.raspberrypi.com/products/raspberry-pi-zero-w/
[Raspberry Pi Zero 2 W]: https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/
[Raspberry Pi 3 Model B]: https://www.raspberrypi.com/products/raspberry-pi-3-model-b/
[Raspberry Pi 4 Model B]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[BeagleBone-based boards]: https://www.beagleboard.org/boards
[MangoPi MQ Pro]: https://mangopi.org/mangopi_mqpro
[nerves_system_rpi0]: https://github.com/nerves-project/nerves_system_rpi0
[nerves_system_rpi3]: https://github.com/nerves-project/nerves_system_rpi3
[nerves_system_rpi3a]: https://github.com/nerves-project/nerves_system_rpi3a
[nerves_system_rpi4]: https://github.com/nerves-project/nerves_system_rpi4
[nerves_system_bbb]: https://github.com/nerves-project/nerves_system_bbb
[nerves_system_mangopi_mq_pro]: https://github.com/nerves-project/nerves_system_mangopi_mq_pro

:::note info
Wi-Fi での接続がうまくいかない事態に備え、他の通信方法ができるよう準備しておくと良いです。
:::

:::note info
[USB ガジェットモード]に対応しているデバイスをご使用の場合は、[USB ケーブル]を電源供給とネットワークの両方に利用できます。[USB On-The-Go] (OTG)ポートに接続するよう注意してください。
:::

## ファームウェアを起動

[microSD カード]をターゲットデバイスに挿入します。そしてデバイスの電源を入れます。

:::note info
ノートブックを保存するためのデータファイルシステムを初期化するため、最初の起動はその後の起動よりも時間がかかることがあります。 特に大きな [microSD カード]で顕著です。
:::

:::note info
サポートされているほとんどのデバイスには LED が付いています。 [Nerves Livebook] では、ネットワークが切断されると点滅し、ネットワーク インターフェイス経由で接続できる場合は点灯に変わります。
:::

## ブラウザで Nerves Livebook にアクセス

デバイスの準備ができたら、ブラウザで `http://nerves.local` にアクセスします。 パスワードは`nerves`です。

![](https://github.com/nerves-livebook/nerves_livebook/blob/main/assets/livebook.jpg?raw=true)

同一のネットワーク上で複数の Nerves デバイスをご使用の場合は`http://nerves.local`の代わりに、`http://nerves-<シリアル番号の下四桁local`をお試しください。シリアル番号は、以下コマンドで入手できます。

```bash:NervesのIEx
cmd("boardid")
```

```bash:NervesのIEx
Nerves.Runtime.KV.get("nerves_serial_number")
```

:::note info
ファームウェアを[microSD カード]に焼く時点で[環境変数`NERVES_SERIAL_NUMBER`](https://github.com/nerves-livebook/nerves_livebook?tab=readme-ov-file#firmware-provisioning-options)に任意のシリアルナンバーを指定することもできます。
:::

:tada::tada::tada:

後は、[Nerves Livebook]を樂しむだけです。

例えば、[ノートブック上でWi-Fiの設定](https://livebook.dev/run/?url=https%3A%2F%2Fgithub.com%2Fnerves-livebook%2Fnerves_livebook%2Fblob%2Fe33efa88c907204e299431815a13cdfd0fcbd6c0%2Fpriv%2Fsamples%2Fnetworking%2Fconfigure_wifi.livemd)をしてみてはいかがでしょうか。

https://qiita.com/mnishiguchi/items/9d7ed9f674423be26598

戸惑うことがあっても大丈夫です。コミュニティの仲間と一緒に樂しみましょうよ。

https://nerves-jp.connpass.com

:tada::tada::tada:

## さいごに一言

本記事は [闘魂 Elixir #67](https://autoracex.connpass.com/event/309615/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[aarch64]: https://ja.wikipedia.org/wiki/AArch64
[Application.app_dir/2]: https://hexdocs.pm/elixir/Application.html#app_dir/2
[Arch Linux]: https://ja.wikipedia.org/wiki/Arch_Linux
[asdf installation]: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
[asdf]: https://asdf-vm.com/
[asdf plugins]: https://asdf-vm.com/manage/plugins.html
[bash]: https://ja.wikipedia.org/wiki/Bash
[Buildroot]: https://buildroot.org/
[Debian]: https://ja.wikipedia.org/wiki/Debian
[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(プログラミング言語)
[Erlang VM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[Erlang]: https://ja.wikipedia.org/wiki/Erlang
[Erlang]: https://www.erlang.org/
[Erlang versions]: https://github.com/erlang/otp/tags
[fwup]: https://github.com/fwup-home/fwup
[hex]: https://hex.pm/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[Linux]: https://ja.wikipedia.org/wiki/Linux
[Linux ディストリビューション]: https://ja.wikipedia.org/wiki/Linux%E3%83%87%E3%82%A3%E3%82%B9%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3
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
[nerves systems compatibility]: https://hexdocs.pm/nerves/systems.html#compatibility
[Phoenix]: https://www.phoenixframework.org/
[Raspberry Pi]: https://www.raspberrypi.com/
[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[Raspberry Pi 5]: https://www.raspberrypi.com/products/raspberry-pi-5/
[rebar]: https://github.com/erlang/rebar3
[microSD カード]: https://ja.wikipedia.org/wiki/SD%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%BC%E3%82%AB%E3%83%BC%E3%83%89
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
[組み込みシステム]: https://ja.wikipedia.org/wiki/%E7%B5%84%E3%81%BF%E8%BE%BC%E3%81%BF%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0
[クロスコンパイラ]: https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%82%B9%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9
[Buildroot]: https://buildroot.org/
[LFE]: https://en.wikipedia.org/wiki/LFE_(programming_language)
[BeagleBone]: https://www.beagleboard.org/boards/beaglebone-black
[パーティションテーブル]: https://wiki.archlinux.jp/index.php/%E3%83%91%E3%83%BC%E3%83%86%E3%82%A3%E3%82%B7%E3%83%A7%E3%83%8B%E3%83%B3%E3%82%B0#.E3.83.91.E3.83.BC.E3.83.86.E3.82.A3.E3.82.B7.E3.83.A7.E3.83.B3.E3.83.86.E3.83.BC.E3.83.96.E3.83.AB
[ブートローダ]: https://wiki.archlinux.jp/index.php/Arch_%E3%83%96%E3%83%BC%E3%83%88%E3%83%97%E3%83%AD%E3%82%BB%E3%82%B9
[ファームウェア]: https://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A1%E3%83%BC%E3%83%A0%E3%82%A6%E3%82%A7%E3%82%A2
[オープンソース]: https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E3%82%BD%E3%83%BC%E3%82%B9
[自由ソフトウェア]: https://ja.wikipedia.org/wiki/%E8%87%AA%E7%94%B1%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2
[Linux 用 Windows サブシステム]: https://learn.microsoft.com/ja-jp/windows/wsl/about
[Chocolatey]: https://chocolatey.org/
[PowerShell]: https://learn.microsoft.com/en-us/powershell/
[Ubuntu]: https://ubuntu.com/
[Z shell]: https://en.wikipedia.org/wiki/Z_shell
[nerves_bootstrap]: https://github.com/nerves-project/nerves_bootstrap
[hex]: https://github.com/hexpm/hex
[rebar]: https://github.com/erlang/rebar3
[rebar3]: https://github.com/erlang/rebar3
[Raspberry Pi Zero]: https://www.raspberrypi.com/products/raspberry-pi-zero/
[USB On-The-Go]: https://ja.wikipedia.org/wiki/USB_On-The-Go
[Ethernet]: https://ja.wikipedia.org/wiki/Ethernet
[イーサネット]: https://ja.wikipedia.org/wiki/Ethernet
[UART]: https://ja.wikipedia.org/wiki/UART
[USB]: https://ja.wikipedia.org/wiki/%E3%83%A6%E3%83%8B%E3%83%90%E3%83%BC%E3%82%B5%E3%83%AB%E3%83%BB%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%83%BB%E3%83%90%E3%82%B9
[USB ケーブル]: https://search.brave.com/images?q=USB+cable+for+Raspberry+Pi&source=web
[LAN ケーブル]: https://search.brave.com/images?q=LAN%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB&source=web
[USB to TTL シリアルケーブル]: https://search.brave.com/images?q=USB%20to%20TTL%20%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%AB%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB
[SD カードリーダー]: https://search.brave.com/images?q=SD+%E3%82%AB%E3%83%BC%E3%83%89%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC
[Gadget Mode]: http://www.linux-usb.org/gadget/
[USB ガジェットモード]: http://www.linux-usb.org/gadget/
[無線 LAN]: https://ja.wikipedia.org/wiki/%E7%84%A1%E7%B7%9ALAN
[USB WiFi ドングル]: https://search.brave.com/images?q=+USB+WiFi+%E3%83%89%E3%83%B3%E3%82%B0%E3%83%AB&source=web

<!-- end links -->
