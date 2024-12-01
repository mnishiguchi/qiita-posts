---
title: NervesUEvent で Linux カーネルイベントを Elixir に活かす
tags:
  - Linux
  - Elixir
  - Nerves
private: false
updated_at: '2024-12-14T20:09:00+09:00'
id: c46cccc00b0dd91d3529
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

Nerves プロジェクトでハードウェアデバイスを扱う場合、Linux カーネルとの連携が欠かせません。特に、デバイスドライバのロードやシステムのイベント管理は、エンジニアにとって重要な課題です。  
そんな課題をシンプルに解決してくれるのが [NervesUEvent] パッケージです。

この記事では、公式 [README](https://hexdocs.pm/nerves_uevent/readme.html) の内容を元に、[NervesUEvent] の特徴や使い方を紹介します。
特に、`modprobe` コマンドを使ったデバイスドライバの自動ロードや、デバイスの状態監視方法について解説します。

## NervesUEvent とは？

[NervesUEvent]は、Linux の`udevd`の簡易版ともいえる存在です。
`udevd`のようにカーネルからの UEvent を受け取りますが、必要な場合にのみ`modprobe`を実行し、システム内のハードウェアを追跡する点で異なります。
Nerves プロジェクトの多くでは、`udevd`ではなく[NervesUEvent]で十分なケースがほとんどです。

:::note warn
ほぼすべての Nerves システムでは、カーネルモジュールが正しくロードされないと重要な機能が動作しません。例えば、WiFi デバイスドライバはほとんどがカーネルモジュールです。もし[NervesUEvent]や`udevd`などの自動ロード機能を使わない場合は、アプリケーション内で手動で`modprobe`を呼び出す必要があります。
:::

## 設定方法

[NervesUEvent]はシステム起動時に自動的に動作を開始します。設定は`config.exs`を通じて行います。以下のオプションを利用可能です：

| オプション          | 説明                                               |
| ------------------- | -------------------------------------------------- |
| `:autoload_modules` | 必要に応じて`modprobe`を実行（デフォルトは`true`） |

以下に設定例を示します：

```elixir
config :nerves_uevent, autoload_modules: false
```

## 使い方

[NervesUEvent]は現在、非常に低レベルで Linux システムの構造を反映しています。以下に基本的な使い方を説明します。

### **デバイス情報の取得**

例えば、MMC デバイスが Linux 上で`/sys/devices/platform/soc/2100000.bus/2194000.mmc`に登録されている場合、この情報を取得するには以下のように記述します：

```elixir
iex> NervesUEvent.get(["devices", "platform", "soc", "2100000.bus", "2190000.mmc"])
%{
  "driver" => "sdhci-esdhc-imx",
  "modalias" => "of:NmmcT(null)Cfsl,imx6ull-usdhcCfsl,imx6sx-usdhc",
  "of_alias_0" => "mmc1",
  "of_compatible_0" => "fsl,imx6ull-usdhc",
  "of_compatible_1" => "fsl,imx6sx-usdhc",
  "of_compatible_n" => "2",
  "of_fullname" => "/soc/bus@2100000/mmc@2190000",
  "of_name" => "mmc",
  "subsystem" => "platform"
}
```

このように、デバイスツリーから得られる情報を反映しています。特に`"modalias"`キーに注目してください。このキーを基に[NervesUEvent]は対応するカーネルドライバをロードします。

### **イベントの監視**

デバイスの変更イベントを監視する場合、監視を利用します。例えば、MicroSD カードが挿入されたときのイベントを監視するには以下のように記述します：

```elixir
iex> NervesUEvent.subscribe(["devices", "platform", "soc", "2100000.bus", "2190000.mmc"])
```

監視対象が分からない場合、全体を監視して確認することも可能です：

```elixir
iex> NervesUEvent.subscribe([])
```

カードを物理的に挿入すると、[NervesUEvent]はプロセスのメールボックスにイベントを送信します。以下はその一例です：

```elixir
iex> flush
%PropertyTable.Event{
  table: NervesUEvent,
  timestamp: 2558213871126,
  property: ["devices", "platform", "soc", "2100000.bus", "2190000.mmc", "mmc_host", "mmc0", "mmc0:1234"],
  value: %{
    "mmc_name" => "SA04G",
    "mmc_type" => "SD",
    "modalias" => "mmc:block",
    "subsystem" => "mmc"
  },
  previous_timestamp: nil,
  previous_value: nil
}
```

`PropertyTable.Event`構造体には、以下のフィールドが含まれます。

| フィールド   | 説明                                         |
| ------------ | -------------------------------------------- |
| `:table`     | イベントを発生させたテーブル                 |
| `:timestamp` | システムのモノトニック時刻でのタイムスタンプ |
| `:property`  | デバイスパスの詳細                           |
| `:value`     | デバイスに関連する情報                       |

## おわりに

[NervesUEvent] は、Nerves プロジェクトにおけるデバイス管理を簡素化する強力なツールです。イベントの監視やカーネルモジュールの自動ロードを活用することで、IoT デバイスの制御を効率化できます。
[NervesUEvent] を活用して、Nerves プロジェクトでのハードウェア統合をさらにシンプルにしてみませんか？詳細は以下のリンクをご覧ください。

- [NervesUEvent パッケージ (Hex)](https://hex.pm/packages/nerves_uevent)
- [NervesUEvent ソースコード (GitHub)](https://github.com/nerves-project/nerves_uevent)

この記事を読んで氣づいた点や感想があれば、ぜひコメントで教えてください！

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[NervesUEvent]: https://hex.pm/packages/nerves_uevent
