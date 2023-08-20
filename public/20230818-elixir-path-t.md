---
title: Elixir File関連の関数に渡すPath.t型
tags:
  - Elixir
  - path
  - File
  - 型
private: false
updated_at: '2023-08-19T12:11:07+09:00'
id: 90c36bd7ad4601f6b8c8
organization_url_name: fukuokaex
slide: false
---

[Elixir]の[File]関連の関数の多くは[Path.t]型の値を引数にとります。しかしながら、サンプルコード見ると全て`"mix.exs"`のようになんの変哲もない普通の文字列でパスが表現されています。[Path.t]型とは一体何なのか気になります。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

## 結論

- [Path.t]は、[IO.chardata]でした。
- [IO.chardata]は、[String.t]もしくは[maybe_improper_list]とのことです。

## File関連の関数

File関連の関数は[File]モジュールにあります。例として、[File.exists?/2]を用いて、ファイルの存在の有無を確認することができます。ファイルへのパスはこのように文字列で渡すことがほとんどだと思います。

```elixir
File.exists?("mix.exs")
```

[File.exists?/2]型はこのようになっています。

```elixir
@spec exists?(Path.t(), [exists_option]) :: boolean() when exists_option: :raw
```

引数が文字列を表す[String.t]や`binary`ではなく[Path.t]となっています。

## Path.t型

ドキュメントのリンクをポチポチ押して確認すると[Path.t]が[IO.chardata]であることがわかります。さらに、[IO.chardata]は`String.t() | maybe_improper_list(char() | chardata(), String.t() | [])`となっています。ざっくりとリストも渡せるということがわかりました。試してみます。

```elixir
File.exists?("mix.exs")
File.exists?(["mix.exs"])
File.exists?(["mix", ".exs"])
File.exists?([?m, ?i, ?x, ?., ?e, ?x, ?s])
```

文字列や文字のリストにしても問題なくイゴきます。

## ちゃんとしたリスト

[Elixir]の[List]は連結リストですので、`[1, 2, 3]`というリストは`[1 | [2 | [3]]]`のように頭部と尾部で成り立つリストが連結された構造をしています。

```elixir
[1, 2, 3] = [1 | [2 | [3 | []]]]
```

[文字リスト]もいろんな形で表現できます。

```elixir
~c"mix.exs" = 'mix.exs'
~c"mix.exs" = [109, 105, 120, 46, 101, 120, 115]
~c"mix.exs" = [?m | [?i | [?x | [?. | [?e | [ ?x | [?s]]]]]]]
```

## ちゃんとしていないリスト

通常[List]はちゃんとした連結リストじゃないとダメなのですが、文字列連結の場合は変な構造のリストでも許されるようです。

[List]がちゃんとしたものかどうかの判定は[List.improper?/1]でできます。正直言うと何がちゃんとしているのかよくわかりませんが、適当に[List]に文字や文字列を放り込むだけで連結された文字列のように扱ってくれるようです。

```elixir
true = List.improper?(["mix" | ".exs"])
false = List.improper?(["mix" , ".exs"])
```

```elixir
File.exists?(["mix" | ".exs"])
File.exists?(["mix", ".exs"])
```

余談ですが、文字列を何度も何度も生成すると効率が悪いので[List]をビルダーとして活用するパターンが性能向上に有効との噂もあります。どの程度効果があるのかは知りません。

https://nathanmlong.com/2021/05/what-is-an-iolist/

https://bignerdranch.com/blog/elixir-and-io-lists-part-2-io-lists-in-phoenix/

https://www.youtube.com/watch?v=Y83p_VsvRFA&t=1104s

https://qiita.com/mnishiguchi/items/1f9288139fdb8828134d

[Elixir]: https://elixir-lang.org/
[List]: https://hexdocs.pm/elixir/List.html
[File]: https://hexdocs.pm/elixir/File.html
[File.exists?/2]: https://hexdocs.pm/elixir/File.html#exists?/2
[Path.t]: https://hexdocs.pm/elixir/Path.html#t:t/0
[IO.chardata]: https://hexdocs.pm/elixir/IO.html#t:chardata/0
[List.improper?/1]: https://hexdocs.pm/elixir/List.html#improper?/1
[maybe_improper_list]: https://hexdocs.pm/elixir/typespecs.html#built-in-types
[String.t]: https://hexdocs.pm/elixir/String.html#t:t/0
[文字リスト]: https://elixirschool.com/ja/lessons/basics/strings#%E6%96%87%E5%AD%97%E3%83%AA%E3%82%B9%E3%83%88-1
