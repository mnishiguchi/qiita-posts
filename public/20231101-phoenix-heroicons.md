---
title: Elixir Phoenix 1.7 で heroicons の アイコンを使う
tags:
  - 初心者
  - Elixir
  - Phoenix
  - tailwindcss
  - heroicons
private: false
updated_at: '2024-07-24T18:15:08+09:00'
id: 870906623a5e1c5d793c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Phoenix] (関数型プログラミング言語 [Elixir] で書かれた Web 開発フレームワーク) で [heroicons] を使ってみます。

[Phoenix]: https://www.phoenixframework.org/
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[heroicons]: https://heroicons.com/
[heroicons_elixir]: https://github.com/mveytsman/heroicons_elixir

## Phoenix

[LiveView] で有名な Web 開発フレームワークです。

[LiveView]: https://hexdocs-pm.translate.goog/phoenix_live_view/welcome.html?_x_tr_sl=en&_x_tr_tl=ja&_x_tr_hl=en&_x_tr_pto=wapp

https://qiita.com/torifukukaiou/items/3de65fff5df48e8baa20

執筆時点での [Phoenix] のバージョンは 1.7.9 です。

https://hex.pm/packages/phoenix

https://github.com/phoenixframework/phoenix/tags

https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md

## heroicons（公式）

[Tailwind CSS](https://tailwindcss.com/) の製作者たちによって作られた SVG アイコン。

### 公式の使用方法

公式の使用方法として [README](https://github.com/tailwindlabs/heroicons#readme) に三つ挙げられています。

1. 必要な SVG アイコンのソースコードを [heroicons.com][heroicons] からコピーし、インラインSVGとして利用
1. React ライブラリを通じて利用
1. Vue ライブラリを通じて利用

https://qiita.com/takahashi-mcd/items/07c1512bba08659fa8f3

https://qiita.com/mikoshiba_35/items/7600a1c2d3fb8447807c

以上の通り、公式のドキュメントによると、React も Vue も使わない人はアイコンのソースコードを直接コピーして使ってくださいとのことです。

では、Phoenixアプリではどうしたら良いのでしょうか。まずは Elixir パッケージを探してみます。

## heroicons 関連の Elixir パッケージ

[Hex](https://hex.pm/packages?search=heroicon&sort=recent_downloads) で検索すると複数見つかりますが、執筆時点でダウンロード数が最も多いのは [heroicons_elixir] パッケージでした。

ですので、それらパッケージのうちのどれかを利用することができそうです。

一切自分でコンポーネントを書きたくない方は [Phoenix UI](https://phoenix-ui.fly.dev/components/heroicon) に任せるという手もあります。

https://hex.pm/packages?search=heroicon&sort=recent_downloads

## Phoenix 1.7.x で heroicons がどう使われているか

[heroicons] は Phoenix のバージョン 1.7.0 から導入されたようですが、パッチバージョンが上がるにつれて仕様が随分変わりました。

もしお使いの [Phoenix] のバージョンが古い場合は最新版への差分を確認すると何か手掛かりが得られるかもしれません。

https://www.phoenixdiff.org/compare/1.6.15...1.7.9

https://qiita.com/torifukukaiou/items/9b31826be9788f1ce796

### 1.7.0

この時点では、[heroicons_elixir] が依存パッケージとして `mix.exs` に追加されています。

[heroicons] が `Heroicons` モジュールの関数コンポーネントして利用できるようになっています。

```html
<Heroicons.x_mark solid class="h-5 w-5 stroke-current" />
```

https://www.phoenixdiff.org/compare/1.6.15...1.7.0

### 1.7.1

このバージョンから [heroicons_elixir] パッケージが取り除かれ、代わりに [heroicons] のアイコンのソースコードがプロジェクトの中に含まれるようになりました。この時点でのアイコンの置き場所は、`priv/hero_icons` でした。

併せてコンポーネントの実装が代わり、`.icon` (`PiyoPiyoWeb.CoreComponents.icon`) 関数コンポーネントになりました。

```html
<.icon name="hero-x-mark-solid" class="w-5 h-5" />
```

https://www.phoenixdiff.org/compare/1.7.0...1.7.1

https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md#171-2023-03-02

### 1.7.2

アイコンの置き場所は、`priv/hero_icons` から `assets/vendor/heroicons` に変更になりました。

https://www.phoenixdiff.org/compare/1.7.1...1.7.2

https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md#172-2023-03-20

### 1.7.3 以降

その後は大きな変更はないようです。

## Phoenix で heroicons を更新する方法

[heroicons] は第三者パッケージでありいつどのような変更が起きるか分かりません。

万一、将来アイコンを更新する必要がある場合に備え、Phoenix チームが親切にもスクリプトを用意してくれています。

https://github.com/phoenixframework/phoenix/blob/3fd598404337546247aedc74bf0128255c032259/installer/templates/phx_assets/heroicons/UPGRADE.md


```bash:priv/hero_icons/UPGRADE.md
export HERO_VSN="2.0.16" ; \
      curl -L "https://github.com/tailwindlabs/heroicons/archive/refs/tags/v${HERO_VSN}.tar.gz" | \
      tar -xvz --strip-components=1 heroicons-${HERO_VSN}/optimized
```

## Elixir Forum での議論

Phoenix 1.7.1 で [heroicons_elixir] パッケージが取り除かれた際には、賛否両論がありました。

https://elixirforum.com/t/phoenix-1-7-1-thank-you-for-making-heroicons-css-enabled/54315

## José Valim さん (Elixir 言語作者) の見解Í

意訳します。(小生の思い込みが含まれている可能性もありますので予めご了承ください)

- シンプルイズベスト
- 非公式の heroicons パッケージを作ってメンテナンスするに値するメリットはあるのか
- 以前他のフレームワークでWEB開発していた時にアイコンの管理で痛い目にあった

## さいごに

[heroicons] を [Phoenix] アプリで利用するにあたって色んな選択肢があることがわかりました。

[Phoenix] チームがフレームワークにアイコンを含めてくれているので、特にこだわりがなければそれを使うのが一番楽そうです。

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
