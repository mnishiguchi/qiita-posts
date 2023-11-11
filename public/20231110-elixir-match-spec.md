---
title: Elixir Erlang match_spec の文法
tags:
  - Erlang
  - Elixir
  - Phoenix
  - OTP
  - ets
private: false
updated_at: '2023-11-11T13:44:08+09:00'
id: b597f70a186220bf6ec7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir] や [Erlang] には Match Specifications ([match_spec]) という便利な機能が備わっています。独特な文法をしているので頭の整理をします。

[Erlang Term Storage (ETS)][ETS Elixir School] を使うときに、[:ets.insert/2]、[:ets.lookup/2]、[:ets.tab2list/1] などがよく利用されると思います。

[match_spec] を使用すると、[:ets.select/2]、[:ets.select_delete/2] などの強力な絞り込み機能を利用できます。

## Match Specifications

- [パターン照合]して何かを一致させようとするプログラム
- [:ets.select/2] などで [ETS テーブル][ETS Elixir School]内のオブジェクトを検索したりするために使用可能
- 関数を呼び出すより効率的だが、表現力は限られている

https://www.erlang.org/doc/apps/erts/match_spec.html

https://qiita.com/mnishiguchi/items/b478cc6a1607bf66187f

<!-- begin hyperlinks -->

[match_spec]: https://www.erlang.org/doc/apps/erts/match_spec.html
[ETS Elixir School]: https://elixirschool.com/ja/lessons/storage/ets
[ETS]: https://elixirschool.com/ja/lessons/storage/ets
[:ets]: https://www.erlang.org/doc/man/ets.html
[:ets.insert/2]: https://www.erlang.org/doc/man/ets#insert-2
[:ets.tab2list/1]: https://www.erlang.org/doc/man/ets#tab2list-1
[:ets.lookup/2]: https://www.erlang.org/doc/man/ets#lookup-2
[:ets.select/2]: https://www.erlang.org/doc/man/ets#select-2
[:ets.select_delete/2]: https://www.erlang.org/doc/man/ets#select_delete-2
[パターン照合]: https://ja.wikipedia.org/wiki/パターンマッチング
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[Docker]: https://docs.docker.jp/get-started/overview.html
[Map]: https://hexdocs.pm/elixir/Map.html
[Tuple]: https://hexdocs.pm/elixir/Tuple.html
[タプル]: https://hexdocs.pm/elixir/Tuple.html

<!-- end hyperlinks -->

## Match 式（Match Expression）の大まかな構成

Match 式は三つの要素（Match Head, Match Conditions, Match Body）を持つ[タプル]のリストです。

```elixir:型
@type match_expression ::
  [{match_head, match_conditions, match_body}, ...]
```

通常はリスト要素の[タプル]は一つだけだと思います。[タプル]が複数の Match 式はまだ見たことがありません。

### Match 対象（Match Target Term）

match 対象は [ETS] テーブルの行のタプル（`{ key, value1, value2, ...}`）です。

### 変数（Match Variable）

変数は `:"$整数"` の形で表現されます。整数の部分は 0 ～ 100,000,000 (1e+8) の整数です。これらの規則に沿わない場合は未定義となります。

Match Head に限り、何にでもマッチする特殊変数 `:_` が使用できます。

### Match 式のタプルの第1要素（Match Head）

[パターン照合]のパターンを定義する部分になります。テーブルの各行と照合し、`$整数` 変数に束縛します。

```elixir:型
@type match_head ::
  {term | :"$整数" | :_, ...}
```

第一要素がキーで第二要素が値と見るとわかりやすいです。

```elixir:例
{:"$1", :"$2"}

{:_, 123}

{:"$1", %{name: :"$2", group: "fukuokaex"}}
```

### Match 式のタプルの第2要素（Match Conditions）

パターンに一致した行に対する絞り込み条件を定義する部分（ガード節）になります。各絞り込み条件は評価の後 `true` を返すことを期待します。

Match Head で束縛された `:"$整数"` 変数をここで使用することができます。

```elixir:型
@type match_conditions ::
  [match_condition, ...] | []

@type match_condition ::
  {guard_function}
  | {guard_function, condition_expression, ...}
```

```elixir:例
[]

[{:"/=", :"$123", :hoge}]

[
  {:andalso, {:is_integer, :"$123"},
  {:andalso, {:>=, :"$123", 2}, {:"=<", :"$123", 5}}}
]
```

### Match 式のタプルの第3要素（Match Body）

結果を格納するデータ構造を指定する部分です。

```elixir:型
@type match_body ::
  [condition_expression, ...]
```

```elixir:例
[:"$_"]

[:"$$"]

[:"$1"]
```

## Match 式の基本的な例

練習用の ETS テーブルを作ります。

```elixir:ETSの例（値がシンプルな場合）
:ets.new(MyEts1, [:set, :named_table])
:ets.insert(MyEts1, [hoge: 1, fuga: 2, piyo: 3, foo: "3", bar: "4", baz: "5"])
:ets.tab2list(MyEts1)
```

簡単な絞り込みの例です。

```elixir:キーが:hogeでない行を抽出
:ets.select(MyEts1, [{
  # テーブルの行にマッチして束縛
  {:"$123", :_}, # キーを変数`:"$123"`に束縛。値は無視。
  # 絞り込み条件
  [
    {:"/=", :"$123", :hoge}
  ],
  # 結果のデータ構造
  [:"$_"] # テーブルの行を返すおまじない。
}])
# 結果: [piyo: 3, fuga: 2, baz: "5", bar: "4", foo: "3"]
```

```elixir:値が整数で、2以上5以下の行を抽出
:ets.select(MyEts1, [{
  # テーブルの行にマッチして束縛
  {:_, :"$123"}, # キーは無視。値を変数:"$123"に束縛。
  # 絞り込み条件
  [
    {:andalso, {:is_integer, :"$123"},
    {:andalso, {:>=, :"$123", 2}, {:"=<", :"$123", 5}}}
  ],
  # 結果のデータ構造
  [:"$_"] # テーブルの行を返すおまじない。
}])
# 結果: [piyo: 3, fuga: 2]
```

```elixir:指定された値にマッチする行を抽出
:ets.select(MyEts1, [{
  # テーブルの行にマッチして束縛
  {:_, "3"}, # キーは無視。値を"3"と指定。
  # 絞り込み条件
  [],
  # 結果のデータ構造
  [:"$_"] # テーブルの行を返すおまじない。
}])
# 結果: [foo: "3"]
```

## Match 式の戻り値の例

練習用の ETS テーブルをもう一つ作ります。今度は値を [Map] にします。

```elixir:ETSの例（値が複雑な場合）
:ets.new(MyEts2, [:set, :named_table])
:ets.insert(MyEts2, [
  {1, %{ name: "hoge", group: :sakura}},
  {2, %{ name: "fuga", group: :sumire}},
  {3, %{ name: "piyo", group: :sakura}}
])
:ets.tab2list(MyEts2)
```

```elixir:テーブルの行
:ets.select(MyEts2, [{
  {:_, %{ group: :sakura}},
  [],
  [:"$_"]
}])
# 結果:
# [
#   {3, %{group: :sakura, name: "piyo"}},
#   {1, %{group: :sakura, name: "hoge"}}
# ]
```

```elixir:束縛された変数すべて
:ets.select(MyEts2, [{
  {:"$1", %{ name: :"$2", group: :sakura}},
  [],
  [:"$$"]
}])
# 結果:
# [
#   [3, "piyo"],
#   [1, "hoge"]
# ]
```

```elixir:任意の値
:ets.select(MyEts2, [{
  {:_, %{ name: :"$1", group: :sakura}},
  [],
  [:"$1"]
}])
# 結果: ["piyo", "hoge"]
```

```elixir:任意のタプル
:ets.select(MyEts2, [{
  {:"$1", %{ name: :"$2", group: :sakura}},
  [],
  [{{"闘魂", :"$1", :"$2"}}]
}])
# 結果:
# [
#   {"闘魂", 3, "piyo"},
#   {"闘魂", 1, "hoge"}
# ]
```

```elixir:任意のマップ
:ets.select(MyEts2, [{
  {:"$1", %{ name: :"$2", group: :sakura}},
  [],
  [%{id: :"$1", name: :"$2", motto: "元氣があればなんでもできる"}]
}])
# 結果:
# [
#   %{id: 3, name: "piyo", motto: "元氣があればなんでもできる"},
#   %{id: 1, name: "hoge", motto: "元氣があればなんでもできる"}
# ]
```

```elixir:真偽値
:ets.select(MyEts2, [{
  {:"$1", %{ group: :"$2"}},
  [{:==, :"$2", :sakura}],
  [true]
}])
# 結果: [true, true]

:ets.select_count(MyEts2, [{
  {:"$1", %{ group: :"$2"}},
  [{:==, :"$2", :sakura}],
  [true]
}])
# 結果: 2
```

## Match 式を生成するツール

 Match 式を生成するマクロ等を提供するパッケージがいくつかあるようです。

- [fun2ms/1 (erlang)](https://www.erlang.org/doc/man/ets.html#fun2ms-1)
- [ericmj/ex2ms](https://github.com/ericmj/ex2ms)
- [evadne/etso](https://github.com/evadne/etso)
- [E-xyza/match_spec](https://github.com/E-xyza/match_spec)
- [christhekeele/matcha](https://github.com/christhekeele/matcha)

## さいごに

[match_spec] のドキュメントがわかりにくくて理解に時間がかかりました。

ひょっとすると一旦慣れて仕舞えばそんなに難しくないのかもしれません。

本記事は [autoracex #255](https://autoracex.connpass.com/event/300535/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
