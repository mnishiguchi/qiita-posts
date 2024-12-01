---
title: 'Nerves: PropertyTable で効率的な状態管理を実現'
tags:
  - Elixir
  - Nerves
private: false
updated_at: '2024-12-14T20:12:37+09:00'
id: 98d3b0c7f06584333059
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Nerves](https://www.nerves-project.org/) を使った開発を進めると、状態管理やイベント通知を効率的に行いたいと感じる場面が多々あります。そこで便利なのが [`PropertyTable`](https://github.com/nerves-project/property_table) です。

このライブラリは、Nerves プロジェクトのエコシステムに属し、柔軟なキーバリュー形式のデータ管理と変更イベント通知をサポートします。

この記事では、`PropertyTable` の基本的な使い方をご紹介させていただきます。

## `PropertyTable`  の特徴

`PropertyTable` は、Nerves エコシステムの一部として設計されたメモリ内キー–バリューストアで、以下の特徴を持っています。

- **階層的なキー管理**: デフォルトでは文字列リスト形式のキーを使用し、階層的で直感的なデータ管理が可能です。
- **サブスクリプション機能**: 特定のパターンに基づいた変更イベントを通知し、リアルタイムの変更追跡を実現します。
- **ETS による高速なデータ操作**: データは ETS に保存され、高速かつ効率的な読み取りと書き込みが可能です。
- **柔軟な拡張性**: カスタムマッチャーを実装することで、ユニークなユースケースにも対応できます。

具体的には、[`VintageNet`](https://hexdocs.pm/vintage_net/readme.html) や [`NervesUEvent`](https://hexdocs.pm/nerves_uevent/readme.html) などの Nerves ライブラリで使用されており、ネットワーク状態の変化や IP アドレスの更新を監視する際に活用されています。また、柔軟なアラーム管理を実現する [`Alarmist`](https://hex.pm/packages/alarmist/0.2.0) にも採用されています。

https://qiita.com/torifukukaiou/items/45cfc7bdf73f3f232299

https://qiita.com/mnishiguchi/items/c46cccc00b0dd91d3529

https://qiita.com/mnishiguchi/items/0abed6a86fc35400c3c6

## PropertyTable の使い方

基本的に[PropertyTable GitHub README](https://github.com/nerves-project/property_table#readme) の内容そのままです。

`PropertyTable` のデフォルトのプロパティ形式は `String` リストですが、これは設定可能です。
この形式を使うことで、階層的なキーと値のストアが実現可能です。

例えば、以下のような `AwesomeNetworkTable` を設定してネットワークインターフェイスのステータスを管理する場合を考えてみます。

```sh
AwesomeNetworkTable
├── available_interfaces
│   └── [eth0, eth1]
└── interface
    ├── eth0
    │   ├── config
    │   │   └── %{ipv4: %{method: :dhcp}}
    │   └── connection
    │       └── :internet
    └── eth1
        ├── config
        │   └── %{ipv4: %{method: :static}}
        └── connection
            └── :disconnected
└── connection
    └── :internet
```

この例では、`AwesomeNetworkTable` が PropertyTable の名前に相当します。例えば、"eth1" の接続ステータスは `["interface", "eth1", "connection"]` というプロパティで表され、その値は `:disconnected` となります。

このテーブルを管理するライブラリ（プロデューサー）は、以下のように `child_spec` を監視ツリーに追加することで PropertyTable を作成します。

```elixir
defmodule AwesomeSupervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {PropertyTable, name: AwesomeNetworkTable} #<-- これ
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

IEx プロンプトからこの例を実行する場合は、`PropertyTable.start_link/1` を呼び出して手動で PropertyTable を開始します。

```elixir
# PropertyTable をインストール
Mix.install([{:property_table, "0.2.6"}])

# PropertyTable サーバーを起動
{:ok, _table} = PropertyTable.start_link(name: AwesomeNetworkTable)
```

### データの操作

プロパティを挿入するには以下のようにします:

```elixir
PropertyTable.put(AwesomeNetworkTable, ["available_interfaces"], ["eth0", "eth1"])
PropertyTable.put(AwesomeNetworkTable, ["connection"], :internet)
PropertyTable.put(AwesomeNetworkTable, ["interface", "eth0", "config"], %{ipv4: %{method: :dhcp}})
PropertyTable.put(AwesomeNetworkTable, ["interface", "eth0", "connection"], :internet)
```

1 つのプロパティを取得する場合:

```elixir
PropertyTable.get(AwesomeNetworkTable, ["interface", "eth0", "config"])
```

プロパティが階層的な形式を持つため、特定のパターンに一致する複数のプロパティを取得することもできます:

```elixir
PropertyTable.match(AwesomeNetworkTable, ["interface"])
```

### サブスクリプションとイベント

プロパティの変更をサブスクライブすることで、変更が発生するたびに通知メッセージを受け取ることができます。例えば、`"interface"` で始まるプロパティの変更を監視するには次のようにします:

```elixir
PropertyTable.subscribe(AwesomeNetworkTable, ["interface"])
```

その後、次のような変更を加えると:

```elixir
PropertyTable.put(AwesomeNetworkTable, ["interface", "eth0", "connection"], :disconnected)
flush
```

サブスクリプションを設定したプロセスに以下のような `%PropertyTable.Event{}` メッセージが送信されます:

```elixir
%PropertyTable.Event{
  table: AwesomeNetworkTable,
  property: ["interface", "eth0", "connection"],
  value: :disconnected,
  timestamp: 200,
  previous_value: :internet,
  previous_timestamp: 100
}
```

このイベントのタイムスタンプは `System.monotonic_time/0` から取得されます。この例では、タイムスタンプの差分を計算することで、"eth0" がインターネットに接続されていた時間を測定することができます。

## 最近のアップデート (v0.2.6)

最新のリリース v0.2.6 では、以下のような改善が行われました。

### 新機能

- **`:event_transformer`**\*\* オプション\*\*: `PropertyTable.Event.t()` をカスタムデータ構造に変換する機能が追加されました。これにより、`PropertyTable` の内部を抽象化して利用できます。

### 修正点

- イベントの `:previous_timestamp` フィールドが `nil` になる問題を修正。アプリ再起動後の状態が区別しやすくなりました。
- 初期化時のプロパティタイムスタンプが統一されました。

これらの改善は、ライブラリ利用者が直面する問題を解決するために導入されました。具体的には、アラーム ID とその説明間の競合状態を修正し、同一タイプの異なるデバイス (例: `eth1` と `wlan0`) を区別するためのタプルベースのアラーム ID サポートを追加しています。

詳しくは、[公式 Changelog](https://github.com/nerves-project/property_table/releases)をご覧ください。

## おわりに

`PropertyTable` は、Nerves ベースのプロジェクトで状態管理やイベント通知を効率化する強力なツールです。その柔軟性とパフォーマンスにより、ネットワーク状態の追跡や設定の永続化など、多岐にわたるユースケースに対応します。

興味がある方は、`PropertyTable` を活用して効率的な Nerves プロジェクト開発を体験してみてください。

何か氣づいた点があれば、コメントで共有していただけると嬉しいです。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
