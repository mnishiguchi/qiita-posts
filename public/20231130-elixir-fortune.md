---
title: Elixir で fortune を楽しむ
tags:
  - Linux
  - UNIX
  - Elixir
  - fortune
private: false
updated_at: '2023-12-01T12:11:25+09:00'
id: b3364f01d18698a2dec8
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Unix系]オペレーティングシステム(OS)には[fortune]というプログラムがあります。引用句データベースからランダムに取り出して表示するだけのシンプルなプログラムです。

![unix-fortune-demo.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/f9b1b328-5190-0d45-edf1-2899a0dfac1d.gif)

実は[Elixir]にも[fortuneパッケージ][elixir-fortune]があります。今日は、それで遊んでみたいと思います。

## Unix系のfortune

まずは[Unix系]の[fortune]を楽しみます。

### やりかた

やりかたはOSにより異なりますが、いくつか参考までにご紹介します。

#### macOS（Apple Silicon）

- fortuneコマンドへのパス: `/opt/homebrew/bin/fortune`

```shell:ターミナル
# パッケージリストを最新に更新
brew update

# fortuneコマンドをインストール
brew install fortune
```

#### Debian GNU/Linux

- fortuneコマンドへのパス: `/usr/games/fortune`

```shell:ターミナル
# パッケージリストを最新に更新
sudo apt update --yes

# fortuneコマンドをインストール
sudo apt install --yes fortune-mod
```

#### Arch Linux

- fortuneコマンドへのパス: `/usr/bin/fortune`

```shell:ターミナル
# パッケージリストを最新に更新
sudo pacman -Syy

# fortuneコマンドをインストール
sudo pacman -S fortune-mod
```

パスがOSにより異なるのが興味深いですね。ややこし。

### fortuneファイル

fortuneコマンドで表示する引用句の置き場所はOSにより異なりますが、その場所さえわかれば、そこにお好みの元氣になる励ましの言葉などを含めたりすることも可能です。

![unix-fortune-files.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/a82c10a9-0d74-db2a-ba12-b56c28544b13.png)

#### fortuneファイルの置き場所

- macOS（Apple Silicon）: `/opt/homebrew/share/games/fortunes`
- Debian GNU/Linux: `/usr/share/games/fortunes`
- Arch Linux: `/usr/share/fortune`

fortuneファイルの扱いにはいくつかルールがあります。

#### fortuneファイルの作法

- 二種類のファイルを用意する。
  - テキストファイル
    - [拡張子] なし（例、`my_favorite_quotes`）
    - 引用句を`%`文字のみを含む行で区切る
  - インデックス
    - [拡張子] `.dat`（例、`my_favorite_quotes.dat`）
    - テキストファイルを`strfile`コマンドでコンパイルしたもの
- 二種類のファイルを両方ともfortuneファイル置き場に置く

## Elixirのfortune

[Elixir]でも[fortuneパッケージ][elixir-fortune]を使うと同様のことを実施することが可能です。

早速、[Elixir対話シェル（IEx）][IEx]を用いて試してみましょう。

```shell:terminal
iex
```

[Elixir]言語では[Mix.install/2]関数を用いて第三者パッケージをダウンロードすることができます。

```elixir:IEx
Mix.install([{:fortune, "~> 0.1"}])

Fortune.random!()
```

OSのfortuneで使用されている引用句が表示されると思います。

万一こんなエラーが出る場合は、なんらかの理由で引用句のファイルが見つからなかったということです。

```elixir:IEx
iex> Fortune.random!()
** (RuntimeError) Fortune.random failed with no_fortunes
    (fortune 0.1.1) lib/fortune.ex:117: Fortune.random!/1
    iex:2: (file)
```

「Ctrl + C」を2回押して一旦[IEx]を停止します。

[fortuneパッケージ][elixir-fortune]の開発環境に良い言葉があるので、今度はそれらを表示してみたいと思います。
[Mix.install/2]に渡す依存関係に`tag`や`env`など細かな指示を出すことが可能です。

```shell:terminal
iex
```

```elixir:IEx
Mix.install([{:fortune, git: "https://github.com/fhunleth/elixir-fortune.git", tag: "v0.1.1", env: :dev}])

Fortune.random!()
```

![elixir-fortune-demo.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/5952b25e-1a90-17cf-f571-284aa440c2b4.png)

これらの引用句は[fortuneパッケージ][elixir-fortune]の開発者がテスト用に使用しているファイルから来ています。

## 応用

他にも使い道がありますが、今回は基本的な使い方に留めておき、またの機会にしようと思います。

![nerves-tips-demo 2023-11-29 at 19.46.22.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/ea479f3c-c7a7-c812-a90d-a7e8fc57a382.gif)

## さいごに

本記事は [autoracex #260](https://autoracex.connpass.com/event/300534/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)


<!-- begin links -->
[Docker]: https://docs.docker.jp/get-started/overview.html
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[elixir-fortune]: https://github.com/fhunleth/elixir-fortune
[fortune]: https://wiki.archlinux.jp/index.php/Fortune
[Fortune]: https://wiki.archlinux.jp/index.php/Fortune
[Unix系]: https://ja.wikipedia.org/wiki/Unix%E7%B3%BB
[拡張子]: https://www.tohoho-web.com/ex/draft/extension.htm
[Mix.install/2]: https://hexdocs.pm/mix/Mix.html#install/2
[IEx]: https://elixirschool.com/ja/lessons/basics/basics#%E5%AF%BE%E8%A9%B1%E3%83%A2%E3%83%BC%E3%83%89-2
<!-- end links -->
