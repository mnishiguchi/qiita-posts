---
title: Elixirで進捗表示ダウンロード
tags:
  - Erlang
  - Elixir
  - 猪木
  - AdventCalendar2023
  - 闘魂
private: false
updated_at: '2023-09-03T06:12:00+09:00'
id: bc89a10b4a5e80ff0513
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Elixirで進捗状況を表示しながらダウンロードする方法について検討します。

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmnishiguchi%2Flivebooks%2Fblob%2Fmain%2Fnotebooks%2Fdownloader.livemd)

## やりたいこと

[Bumblebee](https://github.com/elixir-nx/bumblebee) を使っているときにファイルをダウンロードするとこういうダウンロード進捗表示がでます。これをやってみたいです。

![](https://user-images.githubusercontent.com/7563926/239774301-3552fbb4-c575-4d67-b491-9dd7d3c44812.png)

## Bumblebeeのコード

プライベートの [Bumblebee.Utils.HTTP](https://github.com/elixir-nx/bumblebee/blob/776e57c6b6d06c0fed47afa26d8144c7c2541149/lib/bumblebee/utils/http.ex#L26) モジュールにダウンロード関連のコードがありました。Erlang の [httpc](https://www.erlang.org/doc/man/httpc.html) モジュールと [ProgressBar](https://github.com/henrik/progress_bar) パッケージを使って実装されています。

ちなみに [httpc](https://www.erlang.org/doc/man/httpc.html) の使い方はElixir Forum にまとめられています。

https://elixirforum.com/t/httpc-cheatsheet/50337

同じように [httpc](https://www.erlang.org/doc/man/httpc.html) モジュールを使って実装しても良いのですが、個人的に日頃よく利用する [Req](https://github.com/wojtekmach/req) を使って１から実装してみようと思います。

まずは、 [Req](https://github.com/wojtekmach/req) をつかって簡単なGETリクエストする方法から始めます。ここではElixir のロゴの画像データをダウンロードの対象とします。

```elixir
source_url = "https://elixir-lang.org/images/logo/logo.png"
```

![](https://elixir-lang.org/images/logo/logo.png)

## progress_bar

[ProgressBar](https://github.com/henrik/progress_bar) パッケージはプログレスバーのアニメーションを提供します。最大値と現在の値はプログラマーが渡します。

![](https://camo.githubusercontent.com/372f059fb3339018c3597222f7514041259c0dc879e16dbd1079d6059147ef37/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f662e636c2e6c792f6974656d732f324e336e3434305330643253326e3337316a30472f70726f67726573735f6261722e676966)

```elixir:IEx
Mix.install([{:progress_bar, "~> 3.0"}])

{current, max} = {8, 10}
ProgressBar.render(current, max)
```

いろんなオプションを渡して見た目を自由に変更することも可能です。

```elixir:IEx
[99..44, 44..77, 77..0]
|> Enum.concat()
|> Enum.each(fn i ->
  ProgressBar.render(i, 100,
    bar: " ",
    bar_color: [IO.ANSI.yellow_background()],
    blank_color: [IO.ANSI.red_background()]
  )

  Process.sleep(22)
end)
```

## Reqをつかって進捗表示なしにダウンロード

まずは、 [Req](https://github.com/wojtekmach/req) をつかって進捗表示なしにダウンロードしてみます。　

```elixir
# データとしてダウンロード
<<_::binary>> = Req.get!(source_url).body
```

ローカルファイルとして保存したい場合は `:output` オプションで保存先を指定します。

```elixir
destination_path = Path.join(System.tmp_dir!(), "elixir_logo.png")

# ダウンロードしてファイルに保存
Req.get!(source_url, output: destination_path)

# ちゃんと読み込めるか検証
File.read!(destination_path)
```

進捗表示を追加するにはどうしたら良いのでしょうか。[Bumblebee](https://github.com/elixir-nx/bumblebee) のコードから [ProgressBar](https://github.com/henrik/progress_bar) パッケージを利用できることはすでにわかっています。それをどのように [Req](https://github.com/wojtekmach/req) と連携させるかを調べます。

## Req の構成要素（3 つ）

Req は 3 つの主要部分で構成されています。

- Req - 高階層のAPI
- Req.Request - 低階層のAPIとリクエスト構造体
- Req.Steps - ひとつひとつの処理

カスタマイズは比較的容易にできそうです。

## Req.Steps.run_finch/1

[Req.Steps.run_finch/1](https://hexdocs.pm/req/Req.Steps.html#run_finch/1) に手を加えることにより、リクエストのロジックを変更できることがわかりました。ドキュメントにわかりにくい部分がありますが、サンプルコードを読んでみて高階層のAPIに  `:finch_request` オプションに関数を注入して [Req.Steps.run_finch/1](https://hexdocs.pm/req/Req.Steps.html#run_finch/1) ステップを入れ替えることができるようです。

[Finch](https://github.com/sneako/finch) とは 初期設定の [Req](https://github.com/wojtekmach/req) が依存するHTTPクライアントだそうです。さらに [Finch](https://github.com/sneako/finch) は [Mint](https://github.com/elixir-mint/mint) と [NimblePool](https://github.com/dashbitco/nimble_pool) を使って性能を意識して実装されているそうです。

余談ですが、Elixirの関数に「闘魂」を注入する方法については以下の@torifukukaiouさんの記事がおすすめです。

https://qiita.com/torifukukaiou/items/c414310cde9b7099df55

## Reqをつかって進捗表示付きダウンロードしてみる

このような形になりました。ポイントをいくつかあげます。

- [Req.get/2](https://hexdocs.pm/req/Req.html#get/2) に `:finch_request` オプションとしてリクエストを処理するカスタムロジック（関数）を注入します。
- [Finch.stream/5](https://hexdocs.pm/finch/Finch.html#stream/5) でリクエストの多重化が可能です。ストリームという概念に疎いので 「[WEB+DB PRESS Vol.１２３](https://gihyo.jp/magazine/wdpress/archive/2021/vol123)」 を読み返しました。「イーチ、ニィー、サン、ぁッ ダー！！！」
- ストリームからは3パターンのメッセージが返ってくるようです。
    - `{:status, status}` - the status of the http response
    - `{:headers, headers}` - the headers of the http response
    - `{:data, data}` - a streaming section of the http body
- 進捗表示に必要な情報はふたつ。
    - データ全体のバイト数
    - 受信完了したバイト数
- 進捗状況は記憶しておく必要があるので、[Req.Response](https://hexdocs.pm/req/Req.Response.html#t:t/0) の `:private` フィールドに格納し、データを受信するたびに更新します。

```elixir
defmodule MNishiguchi.Utils.HTTP do
  def download(source_url, req_options \\ []) do
    case Req.get(source_url, [finch_request: &finch_request/4] ++ req_options) do
      {:ok, response} -> {:ok, response.body}
      {:error, exception} -> {:error, exception}
    end
  end

  def download!(source_url, req_options \\ []) do
    Req.get!(source_url, [finch_request: &finch_request/4] ++ req_options).body
  end

  defp finch_request(req_request, finch_request, finch_name, finch_options) do
    acc = Req.Response.new()

    case Finch.stream(finch_request, finch_name, acc, &handle_message/2, finch_options) do
      {:ok, response} -> {req_request, response}
      {:error, exception} -> {req_request, exception}
    end
  end

  defp handle_message({:status, status}, response), do: %{response | status: status}

  defp handle_message({:headers, headers}, response) do
    total_size =
      Enum.find_value(headers, fn
        {"content-length", v} -> String.to_integer(v)
        {_k, _v} -> nil
      end)

    response
    |> Map.put(:headers, headers)
    |> Map.put(:private, %{total_size: total_size, downloaded_size: 0})
  end

  defp handle_message({:data, data}, response) do
    new_downloaded_size = response.private.downloaded_size + byte_size(data)
    ProgressBar.render(new_downloaded_size, response.private.total_size, suffix: :bytes)

    response
    |> Map.update!(:body, &(&1 <> data))
    |> Map.update!(:private, &%{&1 | downloaded_size: new_downloaded_size})
  end
end
```

以上のコードを IEx でランしてみます。

```elixir
iex(5)> MNishiguchi.Utils.HTTP.download!(source_url)
|===                                                                               |   4% (1.36/34.95 KB)
|=======                                                                           |   8% (2.73/34.95 KB)
|==========                                                                        |  12% (4.10/34.95 KB)
|=============                                                                     |  16% (5.47/34.95 KB)
|================                                                                  |  20% (6.84/34.95 KB)
|===================                                                               |  23% (8.20/34.95 KB)
|======================                                                            |  27% (9.57/34.95 KB)
|=========================                                                        |  31% (10.94/34.95 KB)
|============================                                                     |  35% (12.31/34.95 KB)
|===================================                                              |  43% (15.04/34.95 KB)
|======================================                                           |  47% (16.41/34.95 KB)
|=========================================                                        |  51% (17.78/34.95 KB)
|=============================================                                    |  55% (19.15/34.95 KB)
|================================================                                 |  59% (20.52/34.95 KB)
|===================================================                              |  63% (21.88/34.95 KB)
|======================================================                           |  67% (23.25/34.95 KB)
|=========================================================                        |  70% (24.62/34.95 KB)
|============================================================                     |  74% (25.99/34.95 KB)
|===============================================================                  |  78% (27.36/34.95 KB)
|==================================================================               |  82% (28.72/34.95 KB)
|======================================================================           |  86% (30.09/34.95 KB)
|=========================================================================        |  90% (31.46/34.95 KB)
|============================================================================     |  94% (32.83/34.95 KB)
|=======================================================================================| 100% (34.95 KB)
:ok
```

Livebook でやるともっといい感じに進捗状況が更新されるはずです。

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmnishiguchi%2Flivebooks%2Fblob%2Fmain%2Fnotebooks%2Fdownloader.livemd)

## Bumblebee.Utils.HTTP.download/2

Bumblebee を使っているのであれば、`Bumblebee.Utils.HTTP.download/2` で同じようなことができます。ドキュメントには載ってませんが利用可能です。

```elixir
Bumblebee.Utils.HTTP.download(source_url, destination_path)
```

## Nerves Livebook

せっかくいい感じのコードが書けたので Nerves Livebook に寄贈いたしました。

https://github.com/livebook-dev/nerves_livebook/blob/9515bd61b4da6b30c6165b33f9a0ae56880ddc44/priv/samples/tflite.livemd

## Elixirコミュニティ

本記事は以下のモクモク會での成果です。みなさんから刺激と元氣をいただき、ありがとうございました。

https://youtu.be/c0LP23SM7BU

https://okazakirin-beam.connpass.com/

https://autoracex.connpass.com

![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
