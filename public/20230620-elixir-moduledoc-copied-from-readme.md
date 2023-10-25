---
title: Elixir プロジェクトの moduledoc を README.md からコピーする
tags:
  - Elixir
  - ドキュメント
  - Nerves
private: false
updated_at: '2023-08-17T11:12:41+09:00'
id: 0a9a11db704356e8ef35
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[Elixir] プロジェクトを [Hex] パッケージとしてリリースする際には、ドキュメントを書かきますが、パッケージのうたい文句を書く部分が複数あり同じ内容を何箇所かに複写することもあると思います。

最近、便利な技を覚えたのご紹介いたします。

## やりかた

**1. README.md でうたい文句を`<!-- MODULEDOC -->`で挟む**

```html:README.md
<!-- MODULEDOC -->
Read temperature and pressure in Elixir from Bosch environmental sensors
<!-- MODULEDOC -->
```

https://raw.githubusercontent.com/elixir-sensors/bmp3xx/dbe8015873efa9a0b24fe1e5361d7ad26db8c6a2/README.md

**2. `@moduledoc` の文字列を動的に `README.md` から複写**

```elixir:my_project.ex
defmodule MyProject do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.fetch!(1)
```

このように書くと、以下のようなコードがコンパイル時に生成されます。

```elixir:my_project.ex
defmodule MyProject do
  @moduledoc """
  Read temperature and pressure in Elixir from Bosch environmental sensors
  """
```

https://github.com/elixir-sensors/bmp3xx/blob/dbe8015873efa9a0b24fe1e5361d7ad26db8c6a2/lib/bmp3xx.ex

[Elixir]: https://elixir-lang.org/
[Hex]: https://hex.pm/

## ドキュメントの書き方

[Elixir] では言語自体にドキュメントを書きやすく、ドキュメントを効果的に使えるようにする仕組みが組み込まれているので、気持ちよく書けます。ドキュメントに書かれたサンプルコードをテストとして実行することもできます。

https://elixirschool.com/ja/lessons/basics/documentation

https://hexdocs.pm/elixir/writing-documentation.html

## ネタ元

誰が最初にはじめたのか知りませんが、確か自分はこれを参考にした気がします。

https://github.com/smartrent/delux/blob/a6c10fbaaa2545030488e526da5071d8bfef408f/lib/delux.ex

## コミュニティ

いろんなコミュニティから刺激と元氣をいただいています。ありがとうございます。

### 闘魂コミュニティ

みんなでわいわい楽しく自由に闘魂プログラミングをしています。

https://autoracex.connpass.com

https://qiita.com/torifukukaiou/items/b6361f98194f3687a13c

https://qiita.com/torifukukaiou/items/98fbc9e341da2dbc33fb

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

ぜひお気軽にお立ち寄りください。

### Nervesで組み込み開発するコミュニティ

「Elixir で IoT！？ナウでヤングで cool な Nerves フレームワーク」です。

https://twitter.com/torifukukaiou/status/1201266889990623233


https://nerves-project.org

https://nerves-jp.connpass.com

https://okazakirin-beam.connpass.com/

https://kochi-embedded-meeting.connpass.com

https://www.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

https://www.slideshare.net/YutakaKikuchi1/elixir-on-elixir-and-embedded-systems

https://zacky1972.github.io/blog/2023/05/26/pelemay_backend.html

### Elixir 言語でワクワクするコミュニティ

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd


![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
