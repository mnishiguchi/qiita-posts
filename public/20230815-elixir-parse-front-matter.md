---
title: Elixirでマークダウンからfront matterを抽出する
tags:
  - Markdown
  - Elixir
  - YAML
  - regex
  - frontmatter
private: false
updated_at: '2023-08-17T11:12:41+09:00'
id: 5a969a821d9ad32b940b
organization_url_name: fukuokaex
slide: false
---

[Elixir]言語を用いてブログ記事の[マークダウン][wiki Markdown]からfront matter（YAML形式のメタ情報ブロック）の部分だけ取り出します。

これから[Elixir]を始める方にはこのサイトがおすすめです。

https://elixir-lang.info/

[Elixir]とコミュニティの雰囲気をゆるく味わいたい方は「先端ピアちゃん」さんの動画がオススメです。

https://www.youtube.com/@piacerex

[Elixir]: https://elixir-lang.org/

## front matterとは

Front matterはドキュメントに[メタデータ][wiki メタデータ]（データについてのデータ）を埋め込むために利用される[YAML]の断片です。

[Jekyll]のドキュメントを見るとこう書かれています。

> front Matterは、ファイル冒頭の3つのダッシュのライン2つの間の[YAML]の断片です。--- [Jekyll][Jekyll front Matter]

[Middleman]のドキュメントではこう説明されています。

> Frontmatter は YAML または JSON フォーマットでテンプレート上部に記述することが できるページ固有の変数です。--- [Middleman][Middleman front Matter]

https://qiita.com/search?q=front+matter

[Elixir]: https://elixir-lang.org/
[Jekyll]: http://jekyllrb-ja.github.io/
[Jekyll front Matter]: http://jekyllrb-ja.github.io/docs/step-by-step/03-front-matter/
[Middleman]: https://middlemanapp.com/jp/
[Middleman front Matter]: http://jekyllrb-ja.github.io/docs/step-by-step/03-front-matter/
[YAML]: https://yaml.org/
[wiki メタデータ]: https://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%BF%E3%83%87%E3%83%BC%E3%82%BF
[wiki Markdown]: https://ja.wikipedia.org/wiki/Markdown
[wiki YAML]: https://ja.wikipedia.org/wiki/YAML

## YAMLとは

ウィキります。

> YAML（ヤメル、ヤムル）とは、構造化データやオブジェクトを文字列にシリアライズ（直列化）するためのデータ形式の一種。--- [Wikipedia][wiki YAML]

https://qiita.com/tags/yaml

## YamlElixir.read_from_string!/1

[Elixir]で[YAML]を解析するには[yaml_elixir]パッケージが便利そうです。

YamlElixir.read_from_string!/1で簡単に読み込むことができます。

```elixir:IEx
Mix.install([:yaml_elixir])

yaml = """
  a: ""
  b: 1
  c: true
  d: ~
  e: nil
"""

YamlElixir.read_from_string!(yaml)
# %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => "nil"}
```

[yaml_elixir]: https://hex.pm/packages/yaml_elixir

## 実験の準備

IExを開きます。

```bash
iex
```

IExの中で[yaml_elixir]パッケージをインストールします。

```elixir:IEx
Mix.install([:yaml_elixir])
```

ブログ記事のマークダウンを用意します。

```elixir:IEx
blog_post = """
---
title: Elixirでディレクトリ内のファイルを一覧を取得する。
tags:
  - Elixir
  - File
private: false
updated_at: '2023-08-15T05:58:24+09:00'
id: 968755b2ef712a42888d
organization_url_name: fukuokaex
slide: false
---

Elixirでディレクトリ内のファイルを列挙する方法について調べました。

これからElixirを始める方にはこのサイトがおすすめです。

https://elixir-lang.info/
"""
```

## 実験1

プログ記事を何も加工せずにそのまま渡してみます。

```elixir:実験1
YamlElixir.read_from_string!(blog_post)
```

front matterの部分が無視されてそれ以外の本文だけ抽出されました。

```elixir:結果1
"Elixirでディレクトリ内のファイルを列挙する方法について調べました。\nこれからElixirを始める方にはこのサイトがおすすめです。\nhttps://elixir-lang.info/"
```

## 実験2

[String.split/3]を使うと文字列を分割することができます。front matterの終端を示す`"\n---\n"`で区切ってみます。そして、front matterの文字列だけをYamlElixir.read_from_string!/1に渡します。

[String.split/3]: https://hexdocs.pm/elixir/main/String.html#split/3

```elixir:実験2
[front_matter |_] = blog_post |> String.split("\n---\n", parts: 2)

front_matter |> YamlElixir.read_from_string!()
```

うまくMapに変換できました。

```elixir:結果2
%{
  "id" => "968755b2ef712a42888d",
  "organization_url_name" => "fukuokaex",
  "private" => false,
  "slide" => false,
  "tags" => ["Elixir", "File"],
  "title" => "Elixirでディレクトリ内のファイルを一覧を取得する。",
  "updated_at" => "2023-08-15T05:58:24+09:00"
}
```

## 実験3

これは実験2とほぼ同じですが、正規表現を用いて前処理を実施する試みです。[Regex.named_captures/3]が便利です。

[Regex.named_captures/3]: https://hexdocs.pm/elixir/main/Regex.html#named_captures/3

front matterを抽出する正規表現については求められる仕様によりいろんなやり方が考えられると思います。Qiita記事をいくつか読んで参考にさせていただきました。

https://qiita.com/koppe/items/96a51890e6630959ffb6


```elixir:実験3
captures = Regex.named_captures(~r/^(?<yaml>---*[\r\n]*([\s\S]*?))---*[\r\n]/, blog_post)

captures["yaml"] |> YamlElixir.read_from_string!()
```

入力が同じなので、結果は実験2と同じです。

```elixir:結果3
%{
  "id" => "968755b2ef712a42888d",
  "organization_url_name" => "fukuokaex",
  "private" => false,
  "slide" => false,
  "tags" => ["Elixir", "File"],
  "title" => "Elixirでディレクトリ内のファイルを一覧を取得する。",
  "updated_at" => "2023-08-15T05:58:24+09:00"
}
```

## 実験4

実験3を終えてから、改めて[hex.pm](https://hex.pm/)で検索していたら、[yaml_elixir]をベースにしてfront matter解析機能を実装した[yaml_front_matter]という別のパッケージが見つかりました。試してみます。

依存パッケージをインストールし直すため、まずIExを再起動する必要があります。

YamlFrontMatter.parse!/1を使ったら一発でfront matterと本文の両方を取り出せました。

```elixir:実験4
Mix.install([:yaml_front_matter])

{front_matter, body} =
  YamlFrontMatter.parse!("""
    ---
    title: Elixirでディレクトリ内のファイルを一覧を取得する。
    tags:
      - Elixir
      - File
    private: false
    updated_at: '2023-08-15T05:58:24+09:00'
    id: 968755b2ef712a42888d
    organization_url_name: fukuokaex
    slide: false
    ---

    Elixirでディレクトリ内のファイルを列挙する方法について調べました。

    これからElixirを始める方にはこのサイトがおすすめです。

    https://elixir-lang.info/
    """)
```

```elixir:結果4
{%{
   "id" => "968755b2ef712a42888d",
   "organization_url_name" => "fukuokaex",
   "private" => false,
   "slide" => false,
   "tags" => ["Elixir", "File"],
   "title" => "Elixirでディレクトリ内のファイルを一覧を取得する。",
   "updated_at" => "2023-08-15T05:58:24+09:00"
 },
 "\nElixirでディレクトリ内のファイルを列挙する方法について調べました。\n\nこれからElixirを始める方にはこのサイトがおすすめです。\n\nhttps://elixir-lang.info/\n"}
```

[yaml_front_matter]: https://hex.pm/packages/yaml_front_matter
