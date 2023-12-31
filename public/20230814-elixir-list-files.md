---
title: Elixirでディレクトリ内のファイルを一覧を取得する。
tags:
  - Elixir
  - File
  - wildcard
  - 元氣
private: false
updated_at: '2023-08-17T11:12:41+09:00'
id: 968755b2ef712a42888d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Elixir]でディレクトリ内のファイルを列挙する方法について調べました。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画が超オススメです。

https://www.youtube.com/@piacerex

[Elixir]: https://elixir-lang.org/

## 結論

[File.ls!/1]と[Path.wildcard/1]がお手軽で便利でした。

他にも技がありましたら、ぜひお便りください！

[Elixir]: https://elixir-lang.org/
[File.ls!/1]: https://hexdocs.pm/elixir/File.html#ls!/1
[Path.wildcard/1]: https://hexdocs.pm/elixir/Path.html#wildcard/1

## 実験の準備

ターミナルを開き実験用のディレクトリとファイルを作成します。

```bash
# 実験用のディレクトリを準備。
mkdir -p tmp/hoge

# 実験用のディレクトリに入る。
cd tmp/hoge

# いろんなタイプのファイルを作成。
touch {元氣,闘魂}-{1..3}.{exs,json}

# ちゃんとファイルが生成されたか確認。
ls
```

## IExで実験

```elixir
# IExを開く。
iex

# File.ls!/1 で現行ディレクトリにある全てのファイルを列挙する。
iex> File.ls!(".")
["闘魂-3.json", "闘魂-2.json", "元氣-3.json", "闘魂-1.exs",
 "闘魂-3.exs", "元氣-2.json", "闘魂-2.exs", "元氣-3.exs",
 "元氣-1.json", "元氣-2.exs", "元氣-1.exs", "闘魂-1.json"]

# 引数無しの場合でも同様に現行ディレクトリで検索がなされる。
iex> File.ls!()
["闘魂-3.json", "闘魂-2.json", "元氣-3.json", "闘魂-1.exs",
 "闘魂-3.exs", "元氣-2.json", "闘魂-2.exs", "元氣-3.exs",
 "元氣-1.json", "元氣-2.exs", "元氣-1.exs", "闘魂-1.json"]

# Path.wildcard/1 でexsファイルだけ列挙する。
iex> Path.wildcard("./*.exs")
["元氣-1.exs", "元氣-2.exs", "元氣-3.exs", "闘魂-1.exs", "闘魂-2.exs",
 "闘魂-3.exs"]

# Path.wildcard/1 で元氣ファイルだけ列挙する。
iex> Path.wildcard("./元氣-*")
["元氣-1.exs", "元氣-1.json", "元氣-2.exs", "元氣-2.json",
 "元氣-3.exs", "元氣-3.json"]

# jsonファイルを削除。
iex> Path.wildcard("./*.json") |> Enum.each(&File.rm!/1)
:ok

iex> File.ls!()
["闘魂-1.exs", "闘魂-3.exs", "闘魂-2.exs", "元氣-3.exs", "元氣-2.exs",
 "元氣-1.exs"]

# exsファイルを削除。
iex> Path.wildcard("./*.exs") |> Enum.each(&File.rm!/1)
:ok

iex> File.ls!()
[]
```

:tada:
