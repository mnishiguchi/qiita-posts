---
title: Elixirでビットマスク
tags:
  - Elixir
  - Binary
  - Nerves
  - Bitwise
  - AdventCalendar2023
private: false
updated_at: '2023-09-03T05:31:17+09:00'
id: 1e0a1dd8de64dbb95d62
organization_url_name: fukuokaex
slide: false
---
C言語の勉強をしていたら、ビット演算が出てきました。[Elixir]でもやってみようと思います。

[Elixir]: https://elixirschool.com/ja/why

## ビットマスク

- [ビット演算](https://ja.wikipedia.org/wiki/ビット演算)と呼ぶビット単位の操作を行う処理である
- ビットマスクをつかってできること
    - 特定のビットをオン（`1`）やオフ（`0`）にする
    - 特定のビットの状態（`0`か`1`）を知る

https://ja.wikipedia.org/wiki/マスク_(情報工学)

## ビット演算

- データをビット列（つまり`0`か`1`が多数並んだもの）と見なして、各[ビット](https://ja.wikipedia.org/wiki/ビット)の移動やビット単位での論理演算を行うもの。

https://ja.wikipedia.org/wiki/ビット演算

## Elixirでビット演算

Bitwiseモジュールの関数または演算子を使用して、整数に対してビット単位の演算を実行できます。

|  | 関数 | 演算子 |
| --- | --- | --- |
| bitwise AND | `band/2` | `&&&` |
| bitwise OR | `bor/2` | `\|\|\|` |
| bitwise SHIFT LEFT | `bsl/2` | `<<<` |
| bitwise SHIFT RIGHT | `bsr/2` | `>>>` |
| bitwise XOR | `bxor/2` | なし |
| bitwise NOT | `bnot/1` | なし |

昔は XOR と NOT にも演算子があった気がしますが、いつの間にか無くなっています。

Bitwiseモジュールの関数・演算子は、ガード節でも使用できます。

https://hexdocs.pm/elixir/Bitwise.html

https://qiita.com/kikuyuta/items/7212ea7c190b303aa606

https://ja.wikipedia.org/wiki/論理演算

Bitwiseモジュールを使用する前には以下おまじないを実行してください。これにより、モジュール名を明示せずに全ての関数と演算子が使用できるようになります。

```elixir
import Bitwise
```

### bitwise NOT

![https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Venn10.svg/225px-Venn10.svg.png](https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Venn10.svg/225px-Venn10.svg.png)

image credit: [https://en.wikipedia.org/wiki/Negation](https://en.wikipedia.org/wiki/Negation)

```
NOT 0111  (decimal 7)
  = 1000  (decimal 8)
```

Elixirではこうやります。

```elixir
-0b1000 = bnot(0b0111)
```

どうも符号が反転するようです。@kikuyuta 先生の[解説](https://qiita.com/kikuyuta/items/7212ea7c190b303aa606)によると「もとの数を `n` とすると `bnot(n)` は `-n-1` の値を返す」そうです。

符号を無視するのであれば絶対値を取ればいいかもしれません。

```elixir
0b1000 = abs(bnot(0b0111))
```

整数の二進法表記を確認したい場合は、`Integer.to_string/2`もしくは`inspect/2`が便利です。どのフラグが立っているのか視覚的に確認できて有用です。

```elixir
8 |> Integer.to_string(2)
# "1000"

8 |> inspect(base: :binary)
# "0b1000"
```

https://hexdocs.pm/elixir/Integer.html#to_string/2

https://hexdocs.pm/elixir/Kernel.html#inspect/2

### bitwise AND

![https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Venn0001.svg/225px-Venn0001.svg.png](https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Venn0001.svg/225px-Venn0001.svg.png)

image credit: [https://en.wikipedia.org/wiki/Logical_conjunction](https://en.wikipedia.org/wiki/Logical_conjunction)

```
    0101 (decimal 5)
AND 0011 (decimal 3)
  = 0001 (decimal 1)
```

Elixirではこうやります

```elixir
0b0001 = 0b0101 |> band(0b0011)
```

```elixir
0b0001 = 0b0101 &&& 0b0011
```

### bitwise OR

![https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Venn0111.svg/225px-Venn0111.svg.png](https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Venn0111.svg/225px-Venn0111.svg.png)

image credit: [https://en.wikipedia.org/wiki/Logical_disjunction](https://en.wikipedia.org/wiki/Logical_disjunction)

```
   0101 (decimal 5)
OR 0011 (decimal 3)
 = 0111 (decimal 7)
```

Elixirではこうやります

```elixir
0b0111 = 0b0101 |> bor(0b0011)
```

```elixir
0b0111 = 0b0101 ||| 0b0011
```

### bitwise XOR

![https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Venn0110.svg/225px-Venn0110.svg.png](https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Venn0110.svg/225px-Venn0110.svg.png)

image credit: [https://en.wikipedia.org/wiki/Exclusive_or](https://en.wikipedia.org/wiki/Exclusive_or)

```
    0101 (decimal 5)
XOR 0011 (decimal 3)
  = 0110 (decimal 6)
```

Elixirではこうやります

```elixir
0b0110 = 0b0101 |> bxor(0b0011)
```

## Elixirでビットマスク

ビットマスクを作る関数を用意します。[最下位ビット（LSB）](https://ja.wikipedia.org/wiki/最下位ビット)の位置を基準とし、そこからの相対位置（オフセット）にあるビットをたてます。

```elixir
import Bitwise

mask = fn bit_position ->
  1 <<< bit_position
end
```

この関数を用いて各ビットを操作するビットマスクを作ります。

```elixir
0b00000001 = mask.(0)
0b00000010 = mask.(1)
0b00000100 = mask.(2)
0b00001000 = mask.(3)
0b00010000 = mask.(4)
0b00100000 = mask.(5)
0b01000000 = mask.(6)
0b10000000 = mask.(7)
```

複数のビットを操作したい場合は、ビットマスクを組み合わせることができます。

```elixir
# 最下位ビットから2番目と4番目と6番目のビットを立てる
0b00101010 = mask.(1) ||| mask.(3) ||| mask.(5)
```

### 特定のビットをオン

```elixir
add_flags_by_mask = fn uint8, mask ->
  uint8 ||| mask
end

# 最下位ビットから2番目と4番目と6番目のビットをオンにする
0b00101010 =
  0b00000000
  |> add_flags_by_mask.(mask.(1) ||| mask.(3) ||| mask.(5))
```

### 特定のビットをオフ

```elixir
remove_flags_by_mask = fn uint8, mask ->
  uint8 &&& bnot(mask)
end

# 下位4ビットをオフにする
0b11110000 =
  0b11111111
  |> remove_flags_by_mask.(mask.(0) ||| mask.(1) ||| mask.(2) ||| mask.(3))
```

### 特定のビットを反転

```elixir
invert_flags_by_mask = fn uint8, mask ->
  uint8 |> bxor(mask)
end

# 最下位ビットから2番目と4番目のビットを反転する
0b00000010 =
  0b00001000
  |> invert_flags_by_mask.(mask.(1) ||| mask.(3))
```

### 特定のビットの状態を知る

```elixir
read_bit_by_mask = fn
  uint8, mask when (uint8 &&& mask) == 0 -> 0
  _, _ -> 1
end

# 最下位ビットから4番目のビットがオンであるか確認
1 = 0b00001000 |> read_bit_by_mask.(mask.(3))
0 = 0b00000000 |> read_bit_by_mask.(mask.(3))
```

この場合はビットの位置を直接インデックスで指定できた方が便利かもしれません。

```elixir
read_bit_at = fn
  uint8, at when (uint8 &&& (1 <<< at)) == 0 -> 0
  _, _ -> 1
end

# 最下位ビットから4番目のビットがオンであるか確認
1 = 0b00001000 |> read_bit_at.(3)
0 = 0b00000000 |> read_bit_at.(3)
```

## ビット列のパターンマッチ

ビット列のパターンマッチでビットを読むこともできます。

```elixir
<<_::4, x::1, _::3>> = <<0b00001000>>
1 = x

<<_::4, x::1, _::3>> = <<0b00000000>>
0 = x
```

```elixir
get_bit_at = fn bits, index when is_bitstring(bits)->
  <<_::size(index + 1), bit::1, _::bitstring>> = bits
  bit
end

1 = <<0b00001000>> |> get_bit_at.(3)
0 = <<0b00000000>> |> get_bit_at.(3)
```

https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html

https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1-options

https://qiita.com/kikuyuta/items/e200a6208013f38333de

https://qiita.com/the_haigo/items/68f52a6f9623d2da7d26

https://qiita.com/torifukukaiou/items/f2e6575ea54a2706eda5

https://zohaib.me/binary-pattern-matching-in-elixir/

直接今回の内容に関係がありませんが、文字列・文字リスト等の似通ったデータ型でよく混乱するので、ついでにそれらの資料もリンクします。

https://qiita.com/im_miolab/items/2d41b10ff005b334295d

https://nathanmlong.com/2021/05/what-is-an-iolist/

https://www.youtube.com/watch?v=Y83p_VsvRFA&t=1104s
