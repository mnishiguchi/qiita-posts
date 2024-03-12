---
title: Phoenix の input コンポーネントでCSSクラスを指定できるようにする
tags:
  - CSS
  - Elixir
  - Phoenix
  - LiveView
  - daisyui
private: false
updated_at: '2024-03-15T09:31:18+09:00'
id: 7058962d35ed655e9111
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Phoenix] 1.7 で 導入された　`CoreComponent` モジュールに [input 関数コンポーネント]があります。[mix phx.new] で[Phoenix] アプリを生成してすぐに使え、いい感じに[input 要素]がスタイリングされて便利です。

https://github.com/phoenixframework/phoenix/pull/4955

しかしながら、自分で[DaisyUI]等を使用して[input 要素]をスタイリングをしたいときに不都合が生じます。[input 関数コンポーネント]のCSSは直書きされており、関数呼び出し時に指定することができないのです。

https://github.com/phoenixframework/phoenix/blob/ab3351a0f262b2870c3b59ebc04de41c6e607550/priv/templates/phx.gen.live/core_components.ex#L370-L391

対策は、2つ考えられます。

1. [input 関数コンポーネント]に直書きされたCSSを好きなように調整
1. [input 関数コンポーネント]実行時に`class`属性を渡せるようにする

ここでは後者をやります。

## やりかた

### `class`属性を受け取れるようにする

[Phoenix.Component.attr/3]マクロで`class`属性を明示します。型は`:string`でもいいのですが、リストで渡したい時もあるので`:any`としています。

```diff_elixir
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

+ attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block
```

https://github.com/phoenixframework/phoenix/blob/ab3351a0f262b2870c3b59ebc04de41c6e607550/priv/templates/phx.gen.live/core_components.ex#L271-L294

### 受け取った`class`属性を反映させる

もともとあった`class`属性の値を`default_class`に切り出します。
実行時に`class`属性が明示されている場合にはそれを優先するようにします。

```diff_elixir
  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
+   default_class =
+     "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6"
+
+   assigns = assign(assigns, class: assigns[:class] || default_class)
+
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
-         "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
+         @class,
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%%= msg %></.error>
    </div>
    """
  end
```

https://github.com/phoenixframework/phoenix/blob/ab3351a0f262b2870c3b59ebc04de41c6e607550/priv/templates/phx.gen.live/core_components.ex#L370-L391

:tada::tada::tada:

## 使い方

これで[DaisyUI]のclassを使えるようになりました！

```html
<.input
  field={@form[:name]}
  placeholder="Name"
  autocomplete="off"
  class="input input-bordered input-secondary mr-2"
/>
```

あとはお好みで調整してください。

https://daisyui.com/components/input/

## 最後に一言

本記事は [闘魂 Elixir #72](https://autoracex.connpass.com/event/312394/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

<!-- begin links -->

[input 関数コンポーネント]: https://github.com/phoenixframework/phoenix/blob/ab3351a0f262b2870c3b59ebc04de41c6e607550/priv/templates/phx.gen.live/core_components.ex#L370-L391
[Elixir]: https://elixir-lang.org/
[Erlang]: https://www.erlang.org/
[heroicons_elixir]: https://github.com/mveytsman/heroicons_elixir
[heroicons]: https://heroicons.com/
[Livebook]: https://livebook.dev/
[Phoenix]: https://www.phoenixframework.org/
[Tailwind CSS]: https://tailwindcss.com/
[DaisyUI]: https://daisyui.com/
[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
[phx-docker-compose-new]: https://github.com/mnishiguchi/phx-docker-compose-new
[Docker Compose]: https://docs.docker.jp/compose/
[PostgreSQL]: https://www.postgresql.org/
[Git]: https://git-scm.com/
[input 要素]: https://developer.mozilla.org/ja/docs/Web/HTML/Element/input
[Phoenix.Component.attr/3]: https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#attr/3
<!-- end links -->
