---
title: 'Nerves: Alarmist パッケージのご紹介'
tags:
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-12-14T14:15:10+09:00'
id: 0abed6a86fc35400c3c6
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

Nerves プロジェクトでの監視や障害検出は、開発者にとって避けて通れない課題です。しかし、エラーを持続的に管理し、適切に通知するシステムを構築するのは簡単ではありません。そこで登場するのが、Erlang の [`:alarm_handler`](https://www.erlang.org/doc/man/alarm_handler.html) を拡張した `Alarmist` パッケージです。このツールは、アラームの管理、サブスクリプション機能、さらには複数アラームの合成をサポートし、監視タスクを大幅に簡略化してくれます。

この記事では、公式 [README](https://github.com/smartrent/alarmist) に基づき、`Alarmist` の基本機能とその使い方を分かりやすくご紹介します。

## Alarmist概要

`Alarmist`は、Erlangの[Alarm Handler](https://www.erlang.org/doc/man/alarm_handler)を拡張して、アラームの管理、購読、そして合成アラームの作成を可能にします。アラームをセットまたはクリアするコードは、`:alarm_handler`に依存するだけで済みます。`Alarmist`は、アラームを処理する側のために設計されています。

## アラームとは

アラームはイベントとは異なります。イベントが任意の情報を伝えるのに対し、アラームはブール値の状態を伝えます。アラームは`set`または`clear`のいずれかであり、コードは常にアラームの状態を知ることができる必要があります。一方でイベントは、受け取るか受け取らないかです。イベントを逃した場合でも取得する方法があるかもしれませんが、アラームでは状態が常にアクセス可能であることが期待されます。

ErlangのAlarm Handlerは、アラームをセットするコードに`AlarmDescription`という補足情報を含めることを可能にします。これは純粋に情報提供のためのものです。アラームが複数回セットされる場合、最新の説明のみが利用可能です。そのため、アラームの区別には役立ちません。例えば、ネットワーク切断のアラームには、`AlarmDescription`ではなく、ネットワークインターフェース名（例: `eth0`）を`AlarmId`に組み込むべきです。

## アラームを使うべき場合

アラームはフォルト管理のツールボックスの1つです。ローカルではない方法で解消する必要がある永続的な状態に名前を与えるために使用されます。

ここでの「永続的」とは、報告されるまでアラームが存在し続けることを意味します。それは一時的ではありません。例えば、スーパーバイズされたGenServerがクラッシュすることは一時的なフォルトです。なぜなら、そのスーパーバイザが再起動するからです。一方、リモートサーバーが到達不能になるような問題は永続的です。それは数秒後、数時間後、またはもっと後に解決するかもしれません。

「ローカルではない方法」とは、アラームをセットするコードが、他のライブラリや人など、どこか別の場所から支援を得たり支援を提供したりするためにアラームをセットすることを指します。例えば、ネットワーク接続を監視するコードが、インターネットが到達不能である場合にアラームをセットすることで、UIコードが近くの人に問題を伝えることができます。

## アラームの命名

ErlangのAlarm Handlerでは、`AlarmId`に任意のErlangタームを使用できます。この柔軟性は便利ですが、命名規則を持つことも有用です。

Elixirコードの場合、モジュールのようにアラームを命名するのが良いでしょう。`AlarmDescription`データ用のヘルパー関数がある場合、その関数をアラームと同じ名前の`defmodule`に配置します。これは任意なので、ヘルパー関数がない場合に空のモジュールを作成する必要はありません。

ライブラリの場合、アラームは公開APIの一部です。Hexドキュメントにアラームの専用セクションはないため、最適と思われる場所に追加してください。重要なのは、アラーム名、セットとクリアのタイミング、そして`AlarmDescription`データの型と内容を文書化することです。

Erlangコードでは、Erlangのモジュール命名規則を使用してください。

**2要素のタプルを`AlarmId`として使用し、汎用アラームを作成することは、`Alarmist`では現在サポートされていませんが、将来的に追加される可能性があります。（例: `{NetworkDown, "eth0"}`）**

## 合成アラーム

`Alarmist`の主要な機能の1つは、他のアラームの状態に基づいてセットまたはクリアされる新しいアラームを作成するサポートです。これは、複雑なアラーム処理コードを簡略化します。なぜなら、リメディエーション（問題解消）をすぐにトリガーしたくない場合や、特定のアラームの組み合わせがセットされた場合にのみ有用な場合がよくあるからです。さらに、合成アラームを作成することで、複雑な条件が満たされたかどうかを判断する際に、アラーム処理コードを掘り下げる必要がなくなり、条件が満たされたときの可視性が向上します。

以下のセクションでは、合成アラームで利用可能な演算子を説明します。

### Identity

`AlarmId`をそのまま指定すると、元のアラーム状態をミラーリングする新しいアラームが作成されます。この機能は、プロジェクト間でアラームの命名を切り離すのに役立ちます。

```elixir
defmodule IdenticalAlarm do
  use Alarmist.Definition

  defalarm do
    SomeOtherAlarmName
  end
end
```

### Debounce

`debounce/2`関数は、アラームがセットされるまでの最小時間を指定します。これにより、アラームが自然に解消する可能性がある場合、リメディエーションを遅らせることができます。

```elixir
defmodule RealProblemAlarm do
  use Alarmist.Definition

  defalarm do
    debounce(FlakyAlarm, 5_000)
  end
end
```

### Hold

`hold/2`関数は、新しいアラームがセットされる最小時間を指定します。例えば、アラームがUIにインジケータを表示する場合、このインジケータを一定期間保持する必要がある場合に便利です。

```elixir
defmodule LongerAlarm do
  use Alarmist.Definition

  defalarm do
    hold(FlakyAlarm, 3_000)
  end
end
```

### Intensity

`intensity/3`関数は、特定のアラームが短期間で何回もセット/クリアされる場合にアラームをセットします。

```elixir
defmodule IntensityThresholdAlarm do
  use Alarmist.Definition

  defalarm do
    intensity(FlakyAlarm, 5, 3_000)
  end
end
```

### Boolean Logic

標準的なElixirのブール演算子（例: `and`, `or`, `not`）を使用して、複数のアラームを組み合わせることができます。

```elixir
defmodule IntensityThresholdAlarm do
  use Alarmist.Definition

  defalarm do
    (Alarm1 or Alarm2) and intensity(FlakyAlarm, 5, 10_000)
  end
end
```

## 例

次の例では、WiFiが不安定であることを示すアラームを、WiFiが切断されていることを示すアラームに基づいて定義する方法を説明します。これは、コストの高いバックアップ用セルラー接続を持つ組み込みデバイスの実際の例です。WiFiは時々不安定になることがあるため、切断直後にセルラー接続をオンにするのは、単なる一時的な問題の場合には不適切です。

以下のコードは、不安定なWiFiを検知する合成アラーム`Demo.WiFiUnstable`を定義しています。タイムアウト時間は短く設定されており、IExプロンプトで簡単にコピー＆ペーストして実行できるようになっています。

```elixir
defmodule Demo.WiFiUnstable do
  @moduledoc """
  WiFiが頻繁に切断される場合のアラーム
  """
  use Alarmist.Definition

  # WiFiが少なくとも15秒間切断された場合、または60秒間に2回以上切断された場合にアラームをセット
  defalarm do
    debounce(Demo.WiFiDown, :timer.seconds(15)) or
      intensity(Demo.WiFiDown, 2, :timer.seconds(60))
  end
end

defmodule Demo do
  @moduledoc """
  アラームをセットおよびクリアするためのヘルパー
  """
  def wifi_down() do
    :alarm_handler.set_alarm({Demo.WiFiDown, nil})
  end

  def wifi_up() do
    :alarm_handler.clear_alarm(Demo.WiFiDown)
  end

  def wifi_flap() do
    wifi_down()
    wifi_up()
    wifi_down()
    wifi_up()
  end
end
```

ここで、アラームロジックとヘルパーが定義されたので、合成アラームを登録する必要があります。

```elixir
  # ... 通常は Application.start など、初期化時に実行されるコード内で ...
  Alarmist.add_synthetic_alarm(Demo.WiFiUnstable)
```

次に、通知を受信するために購読を行います。

```elixir
  # ... 通常はリメディエーションコードを含むGenServer内で ...
  Alarmist.subscribe(Demo.WiFiUnstable)
```

最後に、アラームをセットおよびクリアする動作を試します。

```elixir
iex> Demo.wifi_flap
:ok
iex> flush
%Alarmist.Event{
  id: Demo.WiFiUnstable,
  state: :set,
  description: nil,
  timestamp: -576460712978320952,
  previous_state: :unknown,
  previous_timestamp: -576460751417398083
}
:ok
# 約60秒待つ
iex> flush
%Alarmist.Event{
  id: Demo.WiFiUnstable,
  state: :clear,
  timestamp: -576460652977733801,
  previous_state: :set,
  previous_timestamp: -576460712978320952
}
```

## おわりに

`Alarmist` は、Nerves ユーザーにとってシステム監視やエラーハンドリングを一段と効率化できる便利なツールです。本記事がその可能性に触れるきっかけとなれば幸いです。

柔軟かつ強力なエラーハンドリングを実現する `Alarmist` を活用して、Nerves プロジェクトでの監視や通知をさらに効率化してみませんか？詳細は以下のリソースをご覧ください。

- [Alarmist パッケージ (Hex)](https://hex.pm/packages/alarmist)
- [Alarmist のソースコード (GitHub)](https://github.com/smartrent/alarmist)

この記事を読んで感じたことや氣づいた点があれば、ぜひコメントで共有していただけると嬉しいです！

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


