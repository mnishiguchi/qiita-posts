---
title: ElixirでErlangのioモジュールを使う
tags:
  - Erlang
  - string
  - Elixir
  - io
  - 闘魂
private: false
updated_at: '2023-12-08T12:50:07+09:00'
id: 7ebd418460c8c508acc4
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Elixir]で標準入出力を扱う際には通常Elixirの[IO]モジュールを使うことが多いと思います。

https://hexdocs.pm/elixir/IO.html#functions

[Erlang]にも[io]モジュールがあります。というかこっちが本家です。

https://www.erlang.org/doc/man/io.html

https://qiita.com/mnishiguchi/items/060bf92bcc6e62a5afe2

[Elixir]の[IO]モジュールの中で[Erlang]の[io]モジュールが利用されているのです。例えば、[Elixir]の[IO.puts/2]は[Erlang]の[io.put_chars/2]を使って実装されています。

https://github.com/elixir-lang/elixir/blob/927b10df80ee1c1c7396e68efe00d06bc3e80420/lib/elixir/lib/io.ex#L294

```elixir
IO.puts("元氣があればなんでもできる")
```

```elixir
:io.put_chars(:standard_io, [~c"元氣があればなんでもできる", ?\n])
```

## io:format/2

[Erlang]にしかないものとして[io:format/2]が興味深いです。

[io:format/2]を使うといろんな型のデータに対してフォーマットを整えて印字できます。

文字列を直接渡すことができます。[Erlang]の文字列は「整数(0〜255)のリスト」ですのでそこに注意が必要です。

`s`で文字列を整えることができます。

```elixir
# ５文字だけ印字
iex> :io.format("~5s~n", ["hello world"])
hello
:ok

# ５文字の範囲で右よせ
iex> :io.format("|~5s|~n", ["123"])
|  123|
:ok

# ５文字の範囲で左よせ
iex> :io.format("|~-5s|~n", ["123"])
|123  |
:ok
```

`s`で多バイトの文字に対応するためにはUnicode translation modifier（`t`）を指定する必要があります。

```elixir
# 何もしないと多バイトの文字が文字化け
iex> :io.format("~s~n", ["闘魂"])
é­
:ok

# Unicode translation modifierをつけて一件落着
iex> :io.format("~ts~n", ["闘魂"])
闘魂
:ok
```

`f`で浮動小数点数を整えることができます。初期設定では小数点以下６桁が印字されます。

```erlang
iex> :io.format("~f seconds~n", [30.99])
30.990000 seconds
:ok

iex> :io.format("~.3f seconds~n", [30.99])
30.990 seconds
:ok
```

`p`で何でも印字。リスト要素のコードが[Erlang]のコードとして印字される感じでややこしいです。
文字列専用の`s`を使ったほうがよさそうです。

```elixir
# タプル
iex> :io.format("~p~n", [{1, 2, 3}])
{1,2,3}
:ok

# マップ
iex> :io.format("~p~n", [%{id: 123, name: "Inoki"}])
#{id => 123,name => <<"Inoki">>}
:ok

# 数字
iex> :io.format("~p~n", [123])
123
:ok

iex> :io.format("~p~n", [123.45])
123.45
:ok

# 文字列
iex> :io.format("~p~n", [~c"hello"])
"hello"
:ok

iex> :io.format("~p~n", ["hello"])
<<"hello">>
:ok


iex> :io.format("~p~n", [~c"闘魂"])
[38360,39746]
:ok

iex> :io.format("~p~n", ["闘魂"])
<<233,151,152,233,173,130>>
:ok
```

標準出力に印字せず、フォーマットされた文字列を生成したいだけの場合は、[io](https://www.erlang.org/doc/man/io.html) モジュールの代わりに[io_lib](https://www.erlang.org/doc/man/io_lib.html)モジュールを使うといいかもしれません。

```elixir
iex> :io_lib.format("My number is ~p", [123])
[77, 121, 32, 110, 117, 109, 98, 101, 114, 32, 105, 115, 32, ~c"123"]

iex> :io_lib.format("My number is ~p", [123]) |> IO.puts()
My number is 123
:ok
```

他にも文字列操作のための関数を提供する[string]モジュールがありますが、[Elixir]の[String]モジュールが充実しているのでおそらく[Elixir]で使うことはないのではないでしょうか。

## さいごに

本記事は [闘魂Elixir #59](https://autoracex.connpass.com/event/300542/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


<!-- begin links -->
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
[IO]: https://hexdocs.pm/elixir/IO.html
[IO.puts/2]: https://hexdocs.pm/elixir/IO.html#puts/2
[io]: https://www.erlang.org/doc/man/io.html
[io.put_chars/2]: https://www.erlang.org/doc/man/io#put_chars-2
[io:format/2]: https://www.erlang.org/doc/man/io.html#format-2
[string]: https://www.erlang.org/doc/man/string.html
[String]: https://hexdocs.pm/elixir/String.html#functions
<!-- end links -->
