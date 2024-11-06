---
title: PHPのパターンマッチで遊んでみた
tags:
  - PHP
  - パターンマッチング
  - 闘魂
private: false
updated_at: '2024-11-07T09:23:06+09:00'
id: 07ce4a76d9bdd83f21fb
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

先日、Ruby の強力なパターンマッチを試して楽しみました。その直後にたまたま久し振りに PHP に触る機会があったので PHP でもパターンマッチができないか調査してみました。

https://qiita.com/mnishiguchi/items/53b55deae8e033562a55

2020 年の PHP 8.0 に[match 式](https://www.php.net/manual/ja/control-structures.match.php)が導入されていました。PHP でもパターンマッチができます！

https://php.watch/versions/8.0

https://php.watch/versions/8.0/match-expression

https://www.php.net/manual/ja/control-structures.match.php

試してみます。

## PHP の`match` 式とは

公式ドキュメントに以下の通り記されています。

> match 式は、値の一致をチェックした結果に基づいて評価結果を分岐します。

https://www.php.net/manual/ja/control-structures.match.php

同僚が Elixir や Rust のパターンマッチを利用してスマートに課題解決しているのをみたことがあります。

https://qiita.com/haw_ohnuma/items/dd329bc9c5da78967e7c#fizz-buzz

https://qiita.com/torifukukaiou/items/966b71497f04c7fb5882

https://qiita.com/torifukukaiou/items/a273565bd2643c4017c1#elixir

PHP でも同様の記述ができるのでしょうか？これは期待できます。

## PHP の`match` 式で素振り

せっかくなので自分で手を動かしてみようと思います。

Docker を利用すると氣軽に PHP の対話シェルが開けます。

```bash:terminal
docker run --rm -it php:8.3-cli-alpine
```

ためしに数字を漢字に変換して遊びます。

```php
function number_to_kanji($n) {
  return match ($n) {
    1 => "壱",
    2 => "弐",
    3 => "参",
    4 => "肆",
    5 => "伍",
    123 => "元氣",
    default => "何じゃこれ？"
  };
}

foreach (array(1, 2, 3, 4, 5, 123, 456) as $n) {
  echo number_to_kanji($n).PHP_EOL;
}
```

```bash:結果
壱
弐
参
肆
伍
元氣
なんじゃこれ？
```

うまくいきました！

ちなみに `match` 式は、全ての場合を網羅していないので、想定外のパターンをエラー（`UnhandledMatchError`）にしたくなければ`default`を定義する必要があるようです。

配列のマッチもできるようです。

```php
echo match ([1, 2, 3]) {
  [1] => "壱",
  [1, 2] => "壱弐",
  [1, 2, 3] => "壱弐参",
  default => "闘魂"
};
```

```bash:結果
壱弐参
```

どうも PHP の `match` 式ではパターンマッチ実行時の代入はできなさそうです。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/ebee0656-cd79-0684-459e-cd8a2016266a.png)

また、部分的なパターンマッチや`_`で値を無視することもできなさそうです。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/f6d54a2e-1d20-18c0-3e03-b1cbdb57eb1c.png)

Ruby ではこんな記述ができました。

```rb:irb
irb> config = {db: {user: "admin", password: "abc123"}}
irb> config => {db: {user: db_user}}
irb> db_user
=> "admin"
```

https://qiita.com/jnchito/items/9bb4aa1dcefa00257815

Elixir でもこんな記述ができました。

```elixir:iex
iex> config = %{db: %{user: "admin", password: "abc123"}}
iex> %{db: %{user: db_user}} = config
iex> db_user
=> "admin"
```

https://qiita.com/torifukukaiou/items/deadb6af7df6d15ad7a7

言語によりパターンマッチの仕様が異なるので注意が必要ですね。:bulb:

## PHP の `match` 式で Fizz Buzz

`match` 式では このように`0` に対して条件式の結果をマッチするというユニークな記述ができるそうです。

```php
function numberToFizzBuzz($n) {
  return match (0) {
    $n % 15 => "FizzBuzz" ,
    $n % 3  => "Fizz",
    $n % 5  => "Buzz",
    default => $n,
  };
}

function fizzBuzz($count) {
  foreach(range(1, $count) as $n) {
    echo numberToFizzBuzz($n).PHP_EOL;
  }
}

fizzBuzz(16);
```

```bash:結果
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16
```

:tada:

## さいごに

文法になれてしまえば、PHP でも比較的簡単にパターンマッチができることがわかりました。

複雑なロジックを簡潔で明確なコードで表現できる可能性があると思いました。

今後、さらに実践的なプログラムでも試していこうと思います。
