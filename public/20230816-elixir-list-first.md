---
title: Elixirでリストの最初の要素を取得
tags:
  - array
  - Elixir
  - リスト
  - LinkedList
  - 最初
private: false
updated_at: '2023-08-17T09:08:44+09:00'
id: baabb4ec0636db9f27a6
organization_url_name: fukuokaex
slide: false
---

[Elixir]でListの最初の要素を取得する方法についていくつか考えてみました。一見初歩中の初歩のように見えますが、実は複数のやり方があり、その使い分けがエンジニアとしての腕の見せどころにもなりえます。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

[Elixir]: https://elixir-lang.org/
[List]: https://hexdocs.pm/elixir/List.html

## ElixirのList

[List]は値の集合です。複数の異なるタイプを含むことができます。一意でない値を含むこともできます。

ひとつ注意点は、[Elixir]のListは[連結リスト]として実装されていることです。今回の実験では特に問題がないですが、他の主要プログラミング言語の配列とは異なるので思い込みは禁物です。

https://elixirschool.com/ja/lessons/basics/collections

https://qiita.com/search?q=Elixir+List

[連結リスト]: https://ja.wikipedia.org/wiki/連結リスト

## 実験の準備

### 実験用List

要素数の異なるパターンのリストを用意します。

```elixir
lists = [
  [],
  [nil],
  [1],
  [1, 2],
  [1, 2, 3],
]
```

### 実験を実行する関数

- 前項で作成したリストを何度も使用するので、共通部分を切り出し関数化します。
- 万一、例外が発生した場合にもテストを止めず、エラー内容を値として処理します。

```elixir:実験用関数
test_fun = fn do_test ->
  for list <- lists do
    try do
      do_test.(list)
    rescue
      e -> inspect(e)
    end
  end
end
```

## Kernel.hd/1 (hd/1)

[hd/1]は[List]が空の時にはエラーになります。

```elixir:実験1
test_fun.(fn list ->
  hd(list)
end)
```

```elixir:結果1
["%ArgumentError{message: \"errors were found at the given arguments:\\n\\n  * 1st argument: not a nonempty list\\n\"}",
 nil,
 1,
 1,
 1]
```

https://hexdocs.pm/elixir/Kernel.html#hd/1

[hd/1]: https://hexdocs.pm/elixir/Kernel.html#hd/1

## List.first/1

[List.first/2]のユニークなところは、空リストの最初の要素は`nil`と解釈する点です。この特性が便利な場面があります。

```elixir:実験2
test_fun.(fn list ->
  List.first(list)
end)
```

```elixir:結果2
[nil,
 nil,
 1,
 1,
 1]
```

https://hexdocs.pm/elixir/List.html#first/2

[List.first/2]: https://hexdocs.pm/elixir/List.html#first/2

## Enum.fetch/2

[Enum.fetch/2]は空リストの最初の要素を探すことを異常とみなしますが、プログラマーが例外処理しやすいように`{:ok, any} | :error`を出力してくれます。

```elixir:実験3
test_fun.(fn list ->
  Enum.fetch(list, 0)
end)
```

```elixir:結果3
[:error,
 {:ok, nil},
 {:ok, 1},
 {:ok, 1},
 {:ok, 1}]
```

https://hexdocs.pm/elixir/Enum.html#fetch/2

[Enum.fetch/2]: https://hexdocs.pm/elixir/Enum.html#fetch/2

## Enum.fetch!/2

[Enum.fetch!/2]は空リストの最初の要素を探すことを異常とみなし、エラーを起こします。[hd/1]の時と結果が同じです。エラーメッセージは[hd/1]の方が具体的でわかりやすような気がしますが、こっちのエラーの方がスッキリ簡潔です。ここは好みが別れるところかもしれません。

```elixir:実験4
test_fun.(fn list ->
  Enum.fetch!(list, 0)
end)
```

```elixir:結果4
["%Enum.OutOfBoundsError{message: \"out of bounds error\"}",
 nil
 1,
 1,
 1]
```

https://hexdocs.pm/elixir/Enum.html#fetch!/2

[Enum.fetch!/2]: https://hexdocs.pm/elixir/Enum.html#fetch!/2

## [first | _rest]でパターンマッチ

このパターンは最初の要素と残り全部の2つに分割されます。[List]が空の時はエラーになります。要素が一個の時は大丈夫のようです。

```elixir:実験5
test_fun.(fn list ->
  [first | _rest] = list
  first
end)
```

```elixir:結果5
["%MatchError{term: []}",
 nil,
 1,
 1,
 1]
```

https://elixirschool.com/ja/lessons/basics/pattern_matching

## [first, _, _]でパターンマッチ

このパターンの場合は、要素数がピッタリ一致する場合のみヨシとされます。

```elixir:実験6
test_fun.(fn list ->
  [first, _, _] = list
  first
end)
```

```elixir:結果6
["%MatchError{term: []}",
 "%MatchError{term: [nil]}",
 "%MatchError{term: [1]}",
 "%MatchError{term: [1, 2]}",
 1]
```

## ElixirのEnum技

[List]等の集合を操作する時に使う[Enum]には無数の興味深い関数やテクニックがありますが、ここではいくつか特に**イー**やつをご紹介させて頂こうと思います。

https://qiita.com/torifukukaiou/items/e07ed758d1259d14a2b7

https://qiita.com/torifukukaiou/items/3b65e5c04fa8c55f526e

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

[Enum]: https://hexdocs.pm/elixir/Enum.html
