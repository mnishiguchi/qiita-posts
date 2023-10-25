---
title: Elixir Phoenix でパンくず（breadcrumb）コンポーネントを作る
tags:
  - Elixir
  - Phoenix
  - パンくずリスト
  - tailwindcss
  - LiveView
private: false
updated_at: '2023-08-25T20:15:40+09:00'
id: 48faa6c0fe960b2a0464
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

ウエブアプリの[パンくずリスト]が好きなので、[Elixir] [Phoenix]アプリでも使えるようにコンポーネントを作ってみました。

[Elixir]: https://elixir-lang.org
[Phoenix]: https://www.phoenixframework.org
[breadcrumb]: https://en.wikipedia.org/wiki/Breadcrumb_navigation
[Bootstrap breadcrumb]: https://getbootstrap.com/docs/5.3/components/breadcrumb
[パンくずリスト]: https://ja.wikipedia.org/wiki/パンくずリスト

## 目標

あまり複雑にしたくないので、あまりスマートなことはやらずに明示的にリストを渡す方針にしました。というかシンプルなコードしか思いつきません。

以下のようなインターフェイスを目指します。

```elixir
<.breadcrumb items={[
  %{text: "Home", navigate: ~p"/"},
  %{text: "Examples", navigate: ~p"/examples"},
  %{text: "Light"}
]} />
```

![liveview-breadcrumb 2023-08-11 at 22.40.14.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/f60fd652-e1b8-bee8-cd30-dfe512af071e.gif)

画像のサンプルアプリは[Pragmatic Studio Phoenix LiveView Course]についてきたものです。それに[パンくずリスト]をつけて遊びました。

[Pragmatic Studio Phoenix LiveView Course]: https://pragmaticstudio.com/courses/phoenix-liveview

## HTMLとTailwind

[Phoenix] 1.7にはデフォルトで[Tailwind CSS]が付属しています。 特に設定を変更しなくても[Tailwind CSS]が機能するようになっています。

まず最初に、[Tailwind CSS]を使用した[HTML]の例をインターネットで検索しました。私の焦点は、[HTML]や[Tailwind CSS]ではなく、[Elixir]と[Phoenix]を使用してプログラミングを楽しむことですので、あえて[Tailwind CSS]の深掘りはしません。

[このサイトの例](https://flowbite.com/docs/components/breadcrumb)をベースにすることにしました。

https://flowbite.com/docs/components/breadcrumb

[Elixir]: https://elixir-lang.org
[HTML]: https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/HTML_basics
[Tailwind CSS]: https://tailwindcss.com
[Tailwind CSS classes]: https://tailwind.build/classes
[Using Tailwind CSS in Phoenix 1.7]: https://pragmaticstudio.com/tutorials/using-tailwind-css-in-phoenix

## Phoenix.Component.link/1

リンクについては、[Phoenix.Component.link/1]コンポーネントとその`:naviigate`属性を利用して、LiveViewページ間をスムーズに移動できるようにしました。

https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#link/1

[Phoenix.Component.link/1]: https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#link/1

## アイコン

アイコンは[パンくずリスト]とは直接関係ないのですが、場合により使用したくなるかもしれません。[Phoenix]1.7には[heroicons]の[SVG]が同梱されており、これらの[SVG]アイコンは[MyAppWeb.CoreComponents.icon]コンポーネントとして簡単に利用できます。

`MyAppWeb.CoreComponents`モジュール内のすべてのコンポーネントは[Phoenix] 1.7の初期設定でインポートされていますので、コンポーネントのモジュール名は省略可能です。

https://github.com/phoenixframework/phoenix/blob/e095f23ff62efb2f8c1205b0cc67bfacd80b11ed/installer/templates/phx_single/lib/app_name_web.ex#L87

`.icon`コンポーネントのおかげで[heroicons]ライブラリが提供するものに満足している限り、アイコンの設定について頭を悩ませる必要はなくなりました。

[SVG]: https://en.wikipedia.org/wiki/SVG
[heroicons]: https://heroicons.com
[MyAppWeb.CoreComponents.icon]: https://github.com/phoenixframework/phoenix/blob/e095f23ff62efb2f8c1205b0cc67bfacd80b11ed/installer/templates/phx_web/components/core_components.ex#L569-L594

## パンくずリストの関数コンポーネント

[パンくずリスト]の[関数コンポーネント][Phoenix.Component]専用の `MyAppWeb.Breadcrumb`という名前の新しいモジュールを作成しました。

`MyAppWeb.CoreComponents`モジュールに追加する手もありますが、ここでは[パンくずリスト]の問題に集中できるように、新しいモジュールを作成することにしました。

[Phoenix.Component]: https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html

これが私が作成したモジュールの全体像です。

```elixir
defmodule MyAppWeb.Breadcrumb do
  use Phoenix.Component
  import MyAppWeb.CoreComponents

  attr :items, :list, required: true

  def breadcrumb(assigns) do
    assigns = assign(assigns, :size, length(assigns.items))

    ~H"""
    <nav class="flex" aria-label="breadcrumb">
      <ol class="inline-flex items-center space-x-1 md:space-x-3">
        <.breadcrumb_item
          :for={{item, index} <- Enum.with_index(@items)}
          type={index_to_item_type(index, @size)}
          navigate={item[:navigate]}
          text={item[:text]}
        />
      </ol>
    </nav>
    """
  end

  defp index_to_item_type(0, _size), do: "first"
  defp index_to_item_type(index, size) when index == size - 1, do: "last"
  defp index_to_item_type(_index, _size), do: "middle"

  attr :type, :string, default: "middle"
  attr :navigate, :string, default: "/"
  attr :text, :string, required: true

  defp breadcrumb_item(assigns) when assigns.type == "first" do
    ~H"""
    <li class="inline-flex items-center">
      <.link navigate={@navigate} class="inline-flex items-center text-sm font-medium">
        <.icon name="hero-home" class="h-4 w-4" />
      </.link>
    </li>
    """
  end

  defp breadcrumb_item(assigns) when assigns.type == "last" do
    ~H"""
    <li aria-current="page">
      <div class="flex items-center">
        <.icon name="hero-chevron-right" class="h-4 w-4" />
        <span class="ml-1 text-sm font-medium md:ml-2">
          <%= @text %>
        </span>
      </div>
    </li>
    """
  end

  defp breadcrumb_item(assigns) do
    ~H"""
    <li>
      <div class="flex items-center">
        <.icon name="hero-chevron-right" class="h-4 w-4" />
        <.link navigate={@navigate} class="ml-1 text-sm font-medium md:ml-2 ">
          <%= @text %>
        </.link>
      </div>
    </li>
    """
  end
end
```

### breadcrumb/1

`breadcrumb/1`関数を唯一のパブリック関数としました。 これはパンくずリスト全体を取りまとめるコンポーネントです。コード読みやすくするために、パンくずリストアイテムは、`breadcrumb_item/1`という別のプライベートなコンポーネントに分割しました。`breadcrumb_item/1`はアサインされたアイテムタイプ（`assigns.type`）に応じて挙動を切り替えるようにしています。

### breadcrumb_item/1

単純化すると、パンくずリストアイテムには3種類ある考えられ、それぞれ外観と動作が異なるようにする必要があります。

1. 一番左（起点）
    - ホームのパス
    - リンクしたい
2. 一番右（終点）
    - 現在のパス
    - リンク不要
3. 間にある項目
    - 通過点のパス
    - リンクしたい

タイプごとにレンダリングするマークアップを切り替えます。 

### index_to_item_type/2

各アイテムのタイプについては、リストのインデックスと長さによって簡単に決定できます。リストの長さはさまざまなので、事前にリストの長さを調べておく必要があります。

### Enum.with_index/2

[Enum.with_index/2]は、リストの各要素にインデックスを与えます。 項目タイプを決定する時にそのインデックスと事前に計算されたリストの長さを利用します。

[Enum.with_index/2]: https://hexdocs.pm/elixir/Enum.html#with_index/2
