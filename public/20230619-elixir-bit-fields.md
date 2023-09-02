---
title: ElixirでApartmentFinderのクエリ文字列を解読
tags:
  - Elixir
  - apartment
  - クエリ文字列
  - ビット演算
private: false
updated_at: '2023-09-03T05:31:17+09:00'
id: 32ca7e6233b36b423c8c
organization_url_name: fukuokaex
slide: false
---
たまたま賃貸物件情報サイト Apartment Finder を見ていたらクエリ文字列が面白かったのでメモします。

## Apartment Finder

- [apartmentfinder.com](https://www.apartmentfinder.com/District-Of-Columbia/q/?am=2097172)
- 米国ワシントン DC に拠点を置く [CoStar Group, Inc.](https://en.wikipedia.org/wiki/CoStar_Group) という企業が手掛ける賃貸物件情報サイトのひとつ

## Apartment Finder の検索フィルタ

チェックボックスでフィルタをかけることができるようになっています。例えば、[アメニティ]（快適性、居住性）のフィルタはこんな感じです。

![CleanShot_2023-06-18_at_12.28.252x.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/a7833b41-5196-2971-8dc2-b16916eaf95f.png)

適用されているフィルタは[クエリ文字列]で保持されているようです。

[https://www.apartmentfinder.com/District-Of-Columbia/q/?am=18874644](https://www.apartmentfinder.com/District-Of-Columbia/q/?am=18874644)

[アメニティ]のキーは `am` ですので、英語の amenity に最初のふたもじを取ったと思われます。値は `18874644` 。この値はどうのようにして決定されているのか気になります。気になりませんか？

多分[ビットフィールド]じゃないかなと思い、解読してみることにしました。

[クエリ文字列]: https://en.wikipedia.org/wiki/Query_string

[アメニティ]: https://suumo.jp/yougo/a/amenity/

[ビットフィールド]: https://ja.wikipedia.org/wiki/ビットフィールド

[Elixir]: https://ja.wikipedia.org/wiki/Elixir_(%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E8%A8%80%E8%AA%9E)

## ビットフィールド

> **ビットフィールド** (英: bit field) は、[プログラミング](https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0_(%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF))において[ブーリアン型](https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%BC%E3%83%AA%E3%82%A2%E3%83%B3%E5%9E%8B)の[フラグ](https://ja.wikipedia.org/wiki/%E3%83%95%E3%83%A9%E3%82%B0_(%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF))をコンパクトな[ビット](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88)の並びとして格納する手法である。ビットフィールドの格納には、[整数型](https://ja.wikipedia.org/wiki/%E6%95%B4%E6%95%B0%E5%9E%8B)を使用する。個々のフラグは、ビット単位で格納される。個々のフラグは、ビット単位で格納される。通常は、[ソースコード](https://ja.wikipedia.org/wiki/%E3%82%BD%E3%83%BC%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%89)で、個別のビットがフラグに対応する意味を付けられた、2の[冪乗](https://ja.wikipedia.org/wiki/%E5%86%AA%E4%B9%97)の[定数](https://ja.wikipedia.org/wiki/%E5%AE%9A%E6%95%B0)が定義される。[ビット演算](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88%E6%BC%94%E7%AE%97)の[論理積](https://ja.wikipedia.org/wiki/%E8%AB%96%E7%90%86%E7%A9%8D)・[論理和](https://ja.wikipedia.org/wiki/%E8%AB%96%E7%90%86%E5%92%8C)・[否定](https://ja.wikipedia.org/wiki/%E5%90%A6%E5%AE%9A)の組み合わせが、フラグのセット・リセットとテストを行うために使われる。
>

https://ja.wikipedia.org/wiki/ビットフィールド

[Elixir 言語][Elixir]で 2 の[冪乗](https://ja.wikipedia.org/wiki/%E5%86%AA%E4%B9%97)を列挙してみます。

```elixir
iex> for n <- 1..25, do: 2 ** n
[2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768,
 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216,
 33554432]
```

https://qiita.com/torifukukaiou/items/9d42a8635397896dae7b

これらの値が定数となります。各値に何らかの意味を割り当てます。例えば、2を「牛丼」、4を「味噌汁」、8を「お新香」と割り当てた場合、それらのすべての組み合わせをひとつの整数で表現できます。

```elixir
# 定数
gyudon    = 2 # 二進数: 0b0010
misoshiru = 4 # 二進数: 0b0100
oshinko   = 8 # 二進数: 0b1000

# 組み合わせ
gyudon + misoshiru + oshinko == 0b1110
gyudon + misoshiru           == 0b0110
gyudon + oshinko             == 0b1010
```

さらに、[Elixir 言語][Elixir]の [inspect/2](https://hexdocs.pm/elixir/Kernel.html#inspect/2) 関数を用いて先ほどのアメニティフィルタの値 `18874644` を二進数に変換してみます。

```elixir
iex> 18874644 |> inspect(base: :binary)
"0b1001000000000000100010100"
```

五つのフラッグが立っていますので、五つチェックされていたフィルタと辻褄があります。

## 各ビットが何をいみするのか

これは、各フィルタのチェックを一つだけつけて値を確認し、フィルタ名に紐づけていくしかないと思います。

できました。

| 値 | 意味 |
| --- | --- |
| 2 | laundry_in_unit |
| 4 | dishwasher |
| 16 | ac |
| 32 | balcony |
| 64 | fireplace |
| 128 | furnished |
| 256 | fitness_center |
| 512 | swimming_pool |
| 65536 | parking_available |
| 131072 | wheelchair_accessible |
| 524288 | elevator |
| 1048576 | laundry_hookups |
| 2097152 | laundry_on_site |
| 4194304 | gate |
| 8388608 | garage |
| 16777216 | utilities_included |
| 33554432 | loft |

先ほどのアメニティフィルタの値 `18874644` で検証してみます。

```elixir
laundry_on_site    = 2097152
ac                 = 16
dishwasher         = 4
fitness_center     = 256
utilities_included = 16777216

laundry_on_site + ac + dishwasher + fitness_center + utilities_included
```

答えは `18874644` となるはずです。

:tada:

[ビットフィールド]の値の足し算、引き算は簡単にできます。

逆に合成された値をプログラミングで解読するには工夫が必要です。

## ビットマスク

- [ビット演算](https://ja.wikipedia.org/wiki/ビット演算)と呼ぶビット単位の操作を行う処理である
- ビットマスクをつかってできること
    - 特定のビットをオン（`1`）やオフ（`0`）にする
    - 特定のビットの状態（`0`か`1`）を知る

https://ja.wikipedia.org/wiki/マスク_(情報工学)

https://qiita.com/mnishiguchi/items/1e0a1dd8de64dbb95d62

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
