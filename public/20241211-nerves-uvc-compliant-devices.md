---
title: 'カスタム Nerves: USB カメラの UVC 準拠を確認する方法'
tags:
  - Linux
  - Elixir
  - IoT
  - Nerves
  - USBカメラ
private: false
updated_at: '2024-12-11T09:29:49+09:00'
id: ebef421efbd8d0d54fd3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

USB カメラを使用する際、その多くが **UVC (USB Video Class)** に準拠しているかを確認することが重要です。これにより、専用ドライバを必要とせず、さまざまなオペレーティングシステムで利用できるようになります。

以前の記事「[カスタム Nerves: デバイスドライバを特定する方法](https://qiita.com/mnishiguchi/items/0d26a09ecd3e3f02f411)」では、USB カメラを含むデバイスのドライバを見つける方法について解説しました。その中で、UVC 準拠の確認が必要な場面がありました。

UVC 準拠デバイス一覧というものがありますが、すべてのデバイスが掲載されているわけではないようです。実際、多くの現代の USB ウェブカメラは、リストに記載されていなくても UVC 準拠であると言われています。

本記事では、USB カメラが UVC 準拠かどうかを確認する具体的な方法を紹介します。特に、[UVC 準拠デバイス一覧](https://www.ideasonboard.org/uvc/) に記載がない場合でも役立つ手順を解説します。

## 一部の UVC 準拠デバイスがリストに載っていない理由

UVC 準拠デバイス一覧にはすべてのデバイスが記載されているわけではありません。次のような理由が挙げられます。

1. **リストの不完全性**\
   デバイス一覧は手動で管理されており、新しいモデルやニッチなブランドの製品はまだ追加されていないことがあります。

2. **デフォルトの準拠性**\
   ほとんどの現代の USB カメラはプラグアンドプレイ機能を保証するために UVC 規格に準拠しています。

3. **リブランドされたデバイス**\
   一部のカメラはリブランド製品として販売されており、異なるベンダー ID や製品 ID を使用しているが、実際には UVC 準拠のモデルです。

4. **未報告のデバイス**\
   メーカーが自社の UVC 準拠デバイスをリストに報告していない場合があります。

これらの理由から、リストに載っていなくても UVC 準拠である可能性があります。


## UVC 準拠を確認する手順

USB カメラが UVC に準拠しているかを調べるための具体的な方法を紹介します。

### 1. `lsusb` コマンドで確認

`lsusb` コマンドを使用してシステムがデバイスを検出しているかを確認します。

```bash
lsusb
```

USB カメラの出力例

```
Bus 001 Device 003: ID 056e:701a Elecom Co., Ltd ELECOM 2MP Webcam
```

### 2. `uvcvideo` ドライバの確認

以下のコマンドを実行して`uvcvideo` ドライバがロードされているか確認します。

```bash
lsmod | grep uvcvideo
```

`uvcvideo` が表示されない場合は以下のコマンドで手動でロードします。

```bash
sudo modprobe uvcvideo
```

### 3. カメラの動作テスト

`v4l2-ctl` や `ffmpeg` を使用してカメラが動作するか確認します。

- 利用可能なビデオデバイスを一覧表示

  ```bash
  v4l2-ctl --list-devices
  ```

- ビデオストリームをテスト

  ```bash
  ffplay /dev/video0
  ```

### 4. UVC 準拠デバイスリストで検索

[UVC 準拠デバイス一覧](https://www.ideasonboard.org/uvc/#devices) を開きます。

まず、**Vendor ID (VID)** と **Product ID (PID)** を確認します。例として、`lsusb` コマンドを実行すると次のような出力が得られます。

```
Bus 001 Device 003: ID 056e:701a Elecom Co., Ltd ELECOM 2MP Webcam
```

この出力の中で、`ID` の後に続く `056e` が Vendor ID、`701a` が Product ID です。

次に、これらの ID を使用してデバイスを特定します。ブラウザの検索機能 (`Ctrl+F` または `Cmd+F`) を使用して、UVC 準拠デバイスリストにデバイスが掲載されているかを確認します。

### 5. 対応フォーマットの確認

`v4l2-ctl` を使用して対応しているビデオフォーマットと機能を確認します。

```bash
v4l2-ctl --list-formats-ext
```

サポートされているフォーマットとはカメラが対応している解像度やフレームレートの情報を指します。例として以下のような出力が考えられます。

```
[0]: 'YUYV 4:2:2' (640x480, 30.000 fps)
[1]: 'MJPEG' (1280x720, 25.000 fps)
```

これらのフォーマット情報が表示される場合、そのカメラは UVC 準拠である可能性が高いです。


## UVC 非準拠デバイスの場合

UVC に準拠していないデバイスでも利用できる場合があります。以下の方法を試してみてください。

1. **専用ドライバ**\
   メーカーのウェブサイトやサポートページで Linux 用のドライバを確認します。

2. **コミュニティのフィードバック**\
   [Linux UVC メーリングリスト](https://www.ideasonboard.org/uvc/#mailinglist)、Reddit、または Stack Overflow のフォーラムで情報を探します。

3. **リバースエンジニアリング**\
   上級ユーザーはカスタムドライバやカーネルパッチを検討できますが、このプロセスは複雑です。


## まとめ

**UVC 準拠デバイス一覧** は参考になりますが、完全ではありません。多くの USB ウェブカメラはリストに掲載されていなくても UVC 準拠です。`lsusb`、`v4l2-ctl`、`ffmpeg` を使って動作を確認してみてください。

非準拠の場合は、メーカーの専用ドライバを調べたり、フォーラムで情報を集めたり、リバースエンジニアリングを検討することが有効です。

詳しくは、[UVC Linux Device Drivers ページ](https://www.ideasonboard.org/uvc/) をご覧ください。

何か氣づいた点や改善提案があれば、コメントで共有していただけると嬉しいです。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


