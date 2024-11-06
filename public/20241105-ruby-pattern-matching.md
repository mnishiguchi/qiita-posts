---
title: Rubyのパターンマッチで遊んでみた
tags:
  - Ruby
  - パターンマッチング
private: false
updated_at: '2024-11-05T13:28:05+09:00'
id: 53b55deae8e033562a55
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

Ruby でパターンマッチができるようになったと聞いてはいましたが、まだ試したことがありませんでした。

https://qiita.com/jnchito/items/9bb4aa1dcefa00257815

https://qiita.com/jnchito/items/a9c7030cb5697f992cb7

2019 年の Ruby 2.7 の時点ですでに実験的には導入されていたのですね。

https://www.ruby-lang.org/ja/news/2019/12/25/ruby-2-7-0-released/

試してみます。

## パターンマッチとは

公式ドキュメントに以下の通り記されています。

> パターンマッチは、構造化された値に対して、構造をチェックし、マッチした部分をローカル変数に束縛するという、深いマッチを可能にする機能です。
> (『束縛』は、パターンマッチの輸入元である関数型言語の用語で、Ruby では代入と読み替えても問題ありません)

https://docs.ruby-lang.org/ja/latest/doc/spec=2fpattern_matching.html

https://docs.ruby-lang.org/en/3.3/syntax/pattern_matching_rdoc.html

関数型言語の機能を参考にして導入されたようです。ひょっとすると Elixir かもしれません。

https://qiita.com/torifukukaiou/items/deadb6af7df6d15ad7a7

同僚が Elixir や Rust のパターンマッチを利用してスマートに課題解決しているのをみたことがあります。

https://qiita.com/haw_ohnuma/items/dd329bc9c5da78967e7c#fizz-buzz

https://qiita.com/torifukukaiou/items/966b71497f04c7fb5882

https://qiita.com/torifukukaiou/items/a273565bd2643c4017c1#elixir

## Ruby のパターンマッチで素振り

せっかくなので自分で手を動かしてみようと思います。

```rb
parse_data =
  lambda do |data|
    case data
    in { error:, **rest }
      error
    in { a: { b: { status: } }, **rest }
      status
    in Integer => v if v.positive?
      v
    in [first, *rest]
      rest
    else
      'なんじゃこれ'
    end
  end

p parse_data.call({ error: '失敗' })
#=> "失敗"
p parse_data.call({ a: { b: { status: '元氣' } } })
#=> "元氣"
p parse_data.call(123)
#=> 123
p parse_data.call([777, 888, 999])
#=> [888, 999]
p parse_data.call(-1)
#=> "なんじゃこれ"
```

## Ruby のパターンマッチで Fizz Buzz

```rb
def fizz_buzz(count)
  (1..count).map do |n|
    case [n % 3, n % 5]
    in [0, 0]
      "Fizz Buzz"
    in [0, _]
      "Fizz"
    in [_, 0]
      "Buzz"
    in [_, _]
      n
    end
  end
end

fizz_buzz(16)
#=> [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz", 11, "Fizz", 13, 14, "Fizz Buzz", 16]
```

:tada:

## さいごに

文法になれてしまえば、Ruby でも比較的簡単にパターンマッチができることがわかりました。

複雑なロジックを簡潔で明確なコードで表現できる可能性があると思いました。

今後、さらに実践的なプログラムでも試していこうと思います。
