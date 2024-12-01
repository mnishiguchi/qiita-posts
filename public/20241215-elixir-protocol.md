---
title: 'Elixir Protocol: ポリモーフィズムを担当する強力な機能'
tags:
  - Elixir
  - DesignPatterns
  - Phoenix
  - ポリモーフィズム
  - Nerves
private: false
updated_at: '2024-12-15T19:03:14+09:00'
id: b141a146b982e2378ae6
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

[Protocol] は、Elixir の機能の中でも特に注目すべき強力なツールです。複数のデータ型に共通のインターフェースを提供することで、コードを簡潔かつ柔軟にします。

この記事では、[Protocol] の基本的な概念を解説します。また、実際のプロジェクトで活用されている例を紹介し、それぞれの用途や実装のポイントに触れます。

## Protocol とは

[Protocol] は、異なるデータ型に共通のインターフェースを提供する機能です。これにより、コードをシンプルに保ちながら、動的な操作が可能になります。

[Protocol] の大きな特徴の一つはポリモーフィズムを実現することです。これにより、複数のデータ型を統一的に操作できるようになります。また、担当するデータ型を自由に拡張でき、新しい型を容易にサポートできます。さらに、データ構造ごとにカスタマイズ可能な操作を定義することで、特定の用途に最適化されたコードを書くことが可能です。

Elixir では、コードの構造化や再利用性を高めるために、**Protocol**と**Behaviour**という 2 つの重要なツールが用意されています。どちらも共通のインターフェースを提供する目的を持っていますが、そのアプローチや用途は大きく異なります。

| **特徴** | **Protocol**                 | **Behaviour**                                |
| -------- | ---------------------------- | -------------------------------------------- |
| **対象** | データ型 (構造体やマップ)    | モジュール                                   |
| **用途** | 型による操作の違いを実現     | 複数のモジュールに共通インターフェースを定義 |
| **機能** | データ型に基づいた操作を実現 | 必須な関数の実装を確認                       |

<iframe width="560" height="315" src="https://www.youtube.com/embed/agkXUp0hCW8?si=ys0tvI_GjHNChqpS" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

https://x.com/carlogilmar/status/1790961230695305258/photo/1

| 概念                  | 複雑さのレベル              | 表現力                               |
|-----------------------|-----------------------------|--------------------------------------|
| パターンマッチング    | 🟢 非常にシンプル           | 🌱 表現力が限定的                    |
| 無名関数              | 🟡 やや複雑                 | 🌿 より柔軟                          |
| ビヘイビア            | 🔴 より複雑                 | 🌳 表現力が高い                      |
| プロトコル            | 🔥 さらに複雑               | 🌟 表現力が非常に高い                |
| メッセージパッシング  | 🔥🔥 最も複雑               | 🌟 非常に表現力が高い                |

## 実際の使用例

[Protocol] は、現実のプロジェクトで広く活用されています。以下では、いくつかの代表的な例を詳しく説明します。

### Plug.Exception

Plug をベースにしたアプリケーションでのエラー処理を標準化するために使用されます。このプロトコルは、エラーごとに適切な HTTP ステータスコードをマッピングする重要な役割を果たします。特に Web アプリケーションでエラー応答を統一したい場合に有用です。

https://hexdocs.pm/plug/Plug.Exception.html

https://github.com/phoenixframework/phoenix_ecto/blob/26f8104791789523e78da3d9b1b381cf38f37b65/lib/phoenix_ecto/plug.ex

https://zenn.dev/koga1020/articles/aa52a00f309d4d

### Jason.Encoder

さまざまなデータ構造を JSON 形式に変換するためのプロトコルです。ユーザーがカスタムエンコーダを実装することで、特定のデータ型に対応した柔軟なエンコード処理を実現できます。例えば、データベースのレコードをシンプルな JSON オブジェクトに変換する用途で使われることが多いです。

https://hexdocs.pm/jason/

https://github.com/michalmuskala/jason/blob/master/lib/encoder.ex

### Phoenix.Param

Phoenix フレームワークにおけるパラメータの変換をカスタマイズするためのプロトコルです。これにより、特定の型のパラメータを効率的に抽出でき、URL の設計やルーティングを柔軟に構成できます。

https://hexdocs.pm/phoenix/Phoenix.Param.html

### Timex.Protocol

DateTime や NaiveDateTime、Time といった時間構造体を統一して操作するためのプロトコルです。これにより、日時の計算や比較が簡単に行えるようになり、時間データを扱うアプリケーションでの作業効率が向上します。公式ドキュメントにはサンプルコードが豊富に記載されています。

https://hexdocs.pm/timex/

https://github.com/bitwalker/timex/blob/main/lib/datetime/datetime.ex

### Bamboo.Formatter

**Bamboo.Formatter**は、メール送信時に使用される送信者や受信者のメールアドレスを正しいフォーマットに整えるためのプロトコルです。これにより、メールアドレスが不正な形式で送信されることを防ぎます。メール関連の処理を行う際には必須の機能と言えます。

https://hexdocs.pm/bamboo/

## 実践例：複数センサーモデルを統一的に操作する仕組み

私が取り組んだ [bmp3xx project] では、複数のセンサーモデル（例： bmp180, bmp280, bme680）を統一的に操作する仕組みを構築することが主要な課題でした。

### 実装のポイントと重要点

このプロジェクトの成功には以下の要素が重要でした。

まず、共通のインターフェースを定義するために`Bmp3xx.Sensor` Protocol を作成しました。この Protocol では、センサーからのデータ読み取りやキャリブレーションといった操作を統一的に扱うことができます。

次に、各センサーごとに Protocol の実装を行い、共通のロジックを一箇所に中央化しました。これにより、新しいセンサーモデルを追加する際にも既存コードをほぼ変更せずに対応が可能となります。

### プロジェクト構成

以下のようにプロジェクトは構成されています。

```
lib/
├── bmp3xx.ex          # ライブラリのエントリーポイント
└── bmp3xx/
    ├── bmp280.ex      # 各センサーの実装
    ├── bmp380.ex
    └── sensor.ex      # Protocol定義
```

### 実装例

以下は、`Bmp3xx.Sensor` Protocol とその実装例です。

```elixir
defprotocol Bmp3xx.Sensor do
  @doc "Reads data from the sensor"
  def read(sensor)

  @doc "Performs sensor calibration"
  def calibrate(sensor)
end

defimpl Bmp3xx.Sensor, for: Bmp3xx.Bmp280 do
  def read(sensor), do: Bmp3xx.Bmp280.Comm.read_data(sensor)
  def calibrate(sensor), do: Bmp3xx.Bmp280.Calibration.run(sensor)
end
```

この実装により、例えば`Bmp3xx.Bmp280`センサーからデータを取得する場合でも、Protocol に従って統一されたインターフェースを利用できます。さらに、異なるセンサーモデルを追加する際も、`Bmp3xx.Sensor`を実装するだけで容易に拡張可能です。

https://github.com/elixir-sensors/bmp3xx

## おわりに

[Protocol] は、コードの構成を整理し、読みやすく、メンテナンス性の高いコードを書くための非常に強力なツールです。特に、異なるデータ型を統一的に扱う必要がある場面で、その真価を発揮します。

この機能を活用することで、プロジェクト全体の柔軟性を高めると同時に、効率的かつ洗練されたデータ操作が可能になります。まさに、開発者にとって頼れる「道具箱」のような存在と言えるでしょう。

ここで、アントニオ猪木さんの有名な言葉を引用したいと思います。

> 踏み出せば、その一足が道となる。

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

プロジェクトに新たな価値を生み出す第一歩として、[Protocol] を取り入れてみてはいかがでしょうか？この一歩が、未来の道を切り開く大きな力になるはずです。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[Protocol]: https://hexdocs.pm/elixir/protocols.html
[bmp3xx project]: https://github.com/elixir-sensors/bmp3xx
