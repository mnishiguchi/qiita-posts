---
title: Elixir Phoenix 1.7 で ローディングアイコンを使う
tags:
  - CSS
  - 初心者
  - Elixir
  - Phoenix
  - tailwindcss
private: false
updated_at: '2023-11-06T01:27:26+09:00'
id: 46b3bf16dc14874f9a50
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Phoenix] バージョン 1.7 で ローディングアイコン を使う方法について考えてみます。

https://qiita.com/search?sort=&q=ローディングアイコン

## ローディングアイコンを作る・探す

### CSS

CSS だけで十分かっこいいのができるようです。スタイルシートにローディングアイコンのクラスを定義してそれを使うだけです。

```html:my-site.html
<div class="loader"></div>
```

```css:my-stylesheet.css
/* https://github.com/lukehaas/css-loaders/blob/step2/css/load3.css */
.loader {
  font-size: 10px;
  margin: 50px auto;
  text-indent: -9999em;
  width: 11em;
  height: 11em;
  border-radius: 50%;
  background: #ffffff;
  background: -moz-linear-gradient(left, #ffffff 10%, rgba(255, 255, 255, 0) 42%);
  background: -webkit-linear-gradient(left, #ffffff 10%, rgba(255, 255, 255, 0) 42%);
  background: -o-linear-gradient(left, #ffffff 10%, rgba(255, 255, 255, 0) 42%);
  background: -ms-linear-gradient(left, #ffffff 10%, rgba(255, 255, 255, 0) 42%);
  background: linear-gradient(to right, #ffffff 10%, rgba(255, 255, 255, 0) 42%);
  position: relative;
  -webkit-animation: load3 1.4s infinite linear;
  animation: load3 1.4s infinite linear;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
}
.loader:before {
  width: 50%;
  height: 50%;
  background: #ffffff;
  border-radius: 100% 0 0 0;
  position: absolute;
  top: 0;
  left: 0;
  content: '';
}
.loader:after {
  background: #0dc5c1;
  width: 75%;
  height: 75%;
  border-radius: 50%;
  content: '';
  margin: auto;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
}
@-webkit-keyframes load3 {
  0% {
    -webkit-transform: rotate(0deg);
    transform: rotate(0deg);
  }
  100% {
    -webkit-transform: rotate(360deg);
    transform: rotate(360deg);
  }
}
@keyframes load3 {
  0% {
    -webkit-transform: rotate(0deg);
    transform: rotate(0deg);
  }
  100% {
    -webkit-transform: rotate(360deg);
    transform: rotate(360deg);
  }
}
```

有志の方々が俺俺ローディングアイコンの CSS を公開してくださっています。ありがとうございます。

https://projects.lukehaas.me/css-loaders

https://qiita.com/mimihokuro/items/4e81c8a14e8ee7aaa8b2

### Tailwind CSS の `animate-spin` クラス

[Tailwind CSS] が利用できる環境であれば、[Tailwind CSS の `animate-spin` クラス](https://tailwindcss.com/docs/animation#spin)を他の Tailwind CSS クラスと組み合わせることによりローディングアイコンを作ることができるようです。

```html
<div class="w-12 h-12 rounded-full absolute border-8 border-gray-300"></div>
<div class="w-12 h-12 rounded-full absolute border-8 border-indigo-400 border-t-transparent animate-spin"></div>
```

https://tailwindcss.com/docs/animation#spin

https://play.tailwindcss.com/OPAsySKNCd

https://flowbite.com/docs/components/spinner

Phoenix 1.7 では初期設定で [Tailwind CSS] が使えるようになっているので、何も設定しなくても `animate-spin` クラスが使えるはずです。

https://qiita.com/mnishiguchi/items/11bd7a1e1784fc86dacc

### DaisyUI

[DaisyUI]（第三者製 Tailwind CSS プラグイン）で定義されているクラスを利用する方法もあります。

https://daisyui.com/components/loading/

```elixir
<div class="loading loading-spinner loading-lg"></div>
```

[DaisyUI] をインストールするには Node.js が必要になります。

```sh:nodeがインストールされているか確認
node --version
```

```sh:npmがインストールされているか確認
npm --version
```

通常 Node パッケージは `assets/` ディレクトリ配下に置かれることが多いようです。（最上位の階層ではなく）`assets/` ディレクトリの中で `npm install` を実行します。

```sh:daisyuiをインストールする例
(cd assets && npm install --save-dev tailwindcss daisyui)
```

詳しくは [Tailwind Node.js のインストール手順](https://tailwindcss.com/docs/installation) を参照してください。

## コンポーネントにする

ローディングアイコンの共通ロジックを関数コンポーネントをしてまとめておくと便利かもしれません。

```elixir:custom_components.ex
defmodule MnishiguchiWeb.CustomComponents do
  use Phoenix.Component

  attr :visible, :boolean, default: false

  def loading_indicator(assigns) do
    ~H"""
    <div :if={@visible}">

      <%# ここにローディングアイコンを貼り付ける %>

    </div>
    """
  end
end
```

## さいごに

本記事は [autoracex #253](https://autoracex.connpass.com/event/298184/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

[Docker]: https://docs.docker.jp/get-started/overview.html
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[heroicons_elixir]: https://github.com/mveytsman/heroicons_elixir
[heroicons]: https://heroicons.com/
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/
[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
