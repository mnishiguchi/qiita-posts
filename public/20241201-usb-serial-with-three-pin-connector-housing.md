---
title: 'Nerves × Raspberry Pi: USB-シリアルケーブルを簡単かつ安全に接続する方法'
tags:
  - RaspberryPi
  - Elixir
  - IoT
  - USB-TTLシリアル変換
  - Nerves
private: false
updated_at: '2024-12-07T13:13:47+09:00'
id: db574d3aac1653e9ffa3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

この記事では、USB-シリアルケーブルを Raspberry Pi に接続するための、簡単かつ実用的な方法を紹介します。この方法では、ジャンパーワイヤーと 3 ピンコネクタハウジングを使用し、ケーブルを改造せずに安全に接続できます。特に初心者の方にとって取り組みやすく、配線ミスを防ぎつつ、シンプルかつ整理された接続が実現できるのが特徴です。

## 経緯

先日、東京の秋葉原で開催された [秋葉原でパーツお買い物＆そのまま Nerves 入門！](https://piyopiyoex.connpass.com/event/317734/) というイベントに参加しました。このイベントは、@myasu ([Myasu](https://connpass.com/user/myasu/)) さんと @nako_sleep_9h ([Nako](https://connpass.com/user/ko-kudo/)) さんが共同企画し、電子工作や Elixir に関心のある人たちが集まって、楽しい学びの時間を共有しました。参加者みんなで秋葉原の電子街でパーツを探し回った後、Raspberry Pi 4 で [Nerves](https://nerves-project.org/) を動かして実験を楽しむという内容でした。

https://qiita.com/nako_sleep_9h/items/8956a061b014f11cc65c

[Myasu](https://connpass.com/user/myasu/) さんは、Elixir や Nerves を活用した IoT 開発に関する著書『[Elixir ではじめる IoT 開発入門　 Nerves プラットフォームで組み込み開発にトライ！](https://nextpublishing.jp/book/17353.html)』を執筆されています。この書籍は、Elixir と Nerves を用いた組み込み開発の基礎から応用までを詳しく解説しており、初心者から上級者まで幅広い層に向けた内容となっています。特に、実践的なサンプルコードやプロジェクト例が豊富に含まれており、実際の開発現場で役立つ知識を習得することができます。また、Nerves を使ったプロジェクトのセットアップ方法やデプロイ手順など、実務で直面する課題への対応方法も詳しく紹介されています。この書籍を通じて、Elixir と Nerves を活用した IoT 開発の魅力と可能性をぜひ体感してみてください。

https://nextpublishing.jp/book/17353.html

イベント中に、私は「配線のピン番号を覚えるのが苦手で、接続ミスが多い」という悩みを [Myasu] さんに相談しました。すると、[Myasu] さんは「ジャンパーワイヤーと 3 ピンコネクタハウジングを使うと便利だよ」と、この方法を教えてくれました。このテクニックを試してみたところ、配線ミスの不安が解消され、接続が非常にスムーズになったので、この記事でその方法を紹介します。

[Elixir]: https://elixir-lang.org/
[Nerves]: https://nerves-project.org/
[Myasu]: https://connpass.com/user/myasu/
[Nako]: https://connpass.com/user/ko-kudo/

## この技の利点

- **接続の簡単さ**：3 ピンコネクタハウジングで配線を整理し、誤配線やショートのリスクを軽減します。
- **再利用性**：USB-シリアルケーブルを改造しないため、他のプロジェクトでもそのまま使えます。
- **整理されたセットアップ**：ワイヤーがきれいにまとまり、作業がしやすくなります。
- **初心者向け**：はんだ付けや特別な工具が不要で、手軽に始められます。

![DSC_0129.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/9248c832-4a80-a385-7482-fffb79988def.jpeg)

## 参考になる資料

以下の資料は、USB-シリアルケーブルの接続や Raspberry Pi の GPIO ピンに関する理解を深めるのに役立ちます：

- **[Adafruit による USB-シリアルケーブルガイド](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-5-using-a-console-cable/connect-the-lead)**  
  USB-シリアルケーブルを使用して Raspberry Pi と PC を接続し、ターミナルからアクセスする方法を詳細に解説しています。初心者でも分かりやすい手順がステップごとに示されています。

- **[Pinout.xyz](https://pinout.xyz/)**  
  Raspberry Pi の GPIO ピン配置を確認できるインタラクティブなガイドです。ピンの機能や役割が色分けされており、視覚的に理解しやすくなっています。

## 必要な部品と工具

### 3 ピンコネクタハウジング

- ジャンパーワイヤーを整理するための小型プラスチックハウジング。

https://www.monotaro.com/g/04233685/

https://akizukidenshi.com/catalog/g/g112152/

![Monotaro: 3-Pin Connector Housing](https://jp.images-monotaro.com/Monotaro3/pi/full/mono40331087-190412-02.jpg)

### USB-シリアルケーブル

- Raspberry Pi を PC に接続し、ターミナルにアクセス可能。

https://www.adafruit.com/product/954

![Adafruit USB-Serial Cable](https://cdn-shop.adafruit.com/970x728/954-02.jpg)

### ジャンパーワイヤー

- USB-シリアルケーブルのピンを Raspberry Pi の GPIO ピンに接続。

https://www.adafruit.com/product/1956

![Jumper Wires](https://cdn-shop.adafruit.com/970x728/1956-02.jpg)

### 小型ドライバー

- コネクタハウジングの組み立てに役立つ。

https://www.monotaro.com/p/6496/0246/

![Small Screwdriver](https://jp.images-monotaro.com/Monotaro3/pi/highreso/mono64960246-220516-02.jpg)

## 手順

このセクションでは、USB-シリアルケーブルを安全に Raspberry Pi に接続する方法をステップごとに解説します。電子工作に慣れていない初心者の方でも安心して取り組めるよう、手順を分かりやすく説明します。

### ジャンパーワイヤーを準備する

GND、RX、TX に対応する 3 本のジャンパーワイヤーを選びます。

ジャンパーワイヤーの一方の端からプラスチックコネクタを慎重に取り外します。 小型ドライバーやピンセットを使うと簡単です。

![DSC_0117.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/0bb3c757-742f-3caa-a89e-ce92555d5287.jpeg)

![Screenshot from 2024-12-01 10-55-41.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/2c1d1e53-495a-ee56-f762-ecd7034acdb9.png)

:::note warn
金属ピンを曲げたり傷つけないよう、慎重に作業してください。
:::

取り外したピンを整え、「GND、RX、TX」の順序で並べておきます。

:::note info
色分けを決めておくと、後の接続時に迷わず作業できます。たとえば、以下のような色分けが考えられます。

- 黒: GND（グラウンド）
- 白: RX（受信）
- 緑: TX（送信）

このルールを決めておくことで、再接続時や他のプロジェクトでもスムーズに配線が行え、トラブルシューティングも簡単になります。
:::

### コネクタハウジングを組み立てる

プラスチック製の 3 ピンコネクタハウジングを用意しジャンパーワイヤーの金属ピンを以下の順序で挿入します：

1. **1 ピン目（左端）**: GND（黒）
2. **2 ピン目（中央）**: RX（白）
3. **3 ピン目（右端）**: TX（緑）

:::note info
各ピンが「カチッ」とはまる音がするまで、しっかりと押し込みます。
:::

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/12db913b-4d1b-e94a-5e61-0c4d09f664fc.png)

### USB-シリアルケーブルに接続する

用意したジャンパーワイヤーを以下のように USB-シリアルケーブルに接続します：

- **GND（黒）** → GND ピン
- **RX（白）** → TX ピン
- **TX（緑）** → RX ピン

:::note info
RX（受信）と TX（送信）は交差する形で接続します。
:::

![DSC_0125.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/44ff4a61-1a2b-b4ae-3823-a0d7dce1c48d.jpeg)

### Raspberry Pi の GPIO に接続する

[Pinout.xyz](https://pinout.xyz/) を参照して、GPIO ピンの役割を確認します。

作成した 3 ピンコネクタを Raspberry Pi の GPIO ピンに慎重に挿し込みます。以下の順序を守ってください：

- **GND（黒）** → Ground（グラウンド）ピン
- **RX（白）** → TX（送信）ピン
- **TX（緑）** → RX（受信）ピン

:::note warn
ピン配置を間違えると正常に動作しないため、[Pinout.xyz](https://pinout.xyz/) で GPIO 配置を再確認してから作業してください。
:::

![DSC_0128 (1).jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/e86d2a38-2562-f466-7e8c-c116926eb456.jpeg)

### 動作確認

1. Raspberry Pi の電源を入れます。
2. PC でシリアルターミナルを開き、通信が正常に行われるか確認します。

## おわりに

この記事では、Raspberry Pi に USB-シリアルケーブルを接続するためのシンプルな方法を紹介しました。この方法は、初心者でも手軽に取り組めるだけでなく、配線を安全かつ再利用可能な形で整理できます。

私自身、[秋葉原でパーツお買い物＆そのまま Nerves 入門！](https://piyopiyoex.connpass.com/event/317734/) で [Myasu] さんから教えていただいたこの方法を実践し、その便利さを実感しました。この方法を活用することで、デバッグ作業や [Nerves](https://nerves-project.org/) の設定、新しいプロジェクトへの挑戦がさらにスムーズになるはずです。

この記事が、同じような課題を抱える方や、Raspberry Pi の活用をさらに広げたい方にとって参考になれば幸いです。ぜひ一度試してみてください！
