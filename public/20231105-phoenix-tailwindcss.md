---
title: Elixir Phoenix 1.7 で Tailwind CSS を使う
tags:
  - 初心者
  - Elixir
  - Docker
  - Phoenix
  - docker-compose
private: false
updated_at: '2023-11-06T01:28:34+09:00'
id: 11bd7a1e1784fc86dacc
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[Phoenix] バージョン 1.7 で [Tailwind CSS] を使う方法について考えてみます。

## Tailwind CSS はいつから導入されたか

[Phoenix] の CHANGELOG によると [1.7.0-rc.0 (2022-11-07)](https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md#170-rc1-2023-01-06) から導入されたようです。

もしお使いの [Phoenix] のバージョンが古い場合は最新版への差分を確認すると何か手掛かりが得られるかもしれません。

https://www.phoenixdiff.org/compare/1.6.15...1.7.9

https://qiita.com/torifukukaiou/items/9b31826be9788f1ce796

## Phoenix 1.7 の Tailwind CSS

新規で [Phoenix] アプリを作る場合は、もれなく [Tailwind CSS] が最初から使える状態になっているので、特に設定は必要ありません。

万一 [Tailwind CSS] なしの Phoenix アプリを作りたい場合は、[mix phx.new] コマンドに `--no-tailwind` フラグをつけて [Tailwind CSS] をオプトアウトできます。

[Tailwind CSS] のドキュメントに載っている CSS クラス名を組み合わせて適用すればすぐにスタイリングできるはずです。

https://tailwindcss.com/docs/padding

[Tailwind CSS]　提供の [heroicons] アイコンも `.icon` 関数コンポーネントを通して使えるようになっています。

https://qiita.com/mnishiguchi/items/870906623a5e1c5d793c

## tailwind（Elixir パッケージ）

Phoenix 1.7 で導入されたのはこの Elixir パッケージです。[README](https://github.com/phoenixframework/tailwind#tailwind) によると、プリコンパイルされたスタンドアロンの Tailwind クライアントがインストールされるとのことです。

https://github.com/phoenixframework/tailwind

## 第三者提供 Tailwind プラグイン

第三者提供の Tailwind プラグイン（例: [DaisyUI]）を導入する際には、Node パッケージをインストールする必要があります。

```sh:nodeがインストールされているか確認
node --version
```

```sh:npmがインストールされているか確認
npm --version
```

通常 Node パッケージは `assets/` ディレクトリ配下に置かれることが多いようです。（最上位の階層ではなく）`assets/` ディレクトリの中で `npm install` を実行します。

```sh:daisyuiをインストールする例（cd）
(cd assets && npm install --save-dev tailwindcss daisyui)
```

`npm install` の `--prefix` オプションが便利です。

```sh:daisyuiをインストールする例（長い）
npm install --save-dev --prefix assets tailwindcss daisyui
```

```sh:daisyuiをインストールする例（短い）
npm i -D --prefix assets tailwindcss daisyui
```

詳しくは [Tailwind Node.js のインストール手順](https://tailwindcss.com/docs/installation) を参照してください。

:tada::tada::tada:

## Troubleshooting

こんな感じのエラーを見たら、本コラムを思い出してください。

```
[debug] Downloading esbuild from https://registry.npmjs.org/@esbuild/linux-x64/-/linux-x64-0.17.11.tgz

Rebuilding...
Error: Cannot find module 'tailwindcss/plugin'
Require stack:
- /app/assets/tailwind.config.js
    at Function.Module._resolveFilename (node:internal/modules/cjs/loader:933:15)
    at Function._resolveFilename (pkg/prelude/bootstrap.js:1955:46)
    at Function.resolve (node:internal/modules/cjs/helpers:108:19)
    at _resolve (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:241025)
    at jiti (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:243309)
    at /app/assets/tailwind.config.js:4:16
    at jiti (/snapshot/tailwindcss/node_modules/jiti/dist/jiti.js:1:245784)
    at /snapshot/tailwindcss/lib/lib/load-config.js:37:30
    at loadConfig (/snapshot/tailwindcss/lib/lib/load-config.js:39:6)
    at Object.loadConfig (/snapshot/tailwindcss/lib/cli/build/plugin.js:135:49) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [ '/app/assets/tailwind.config.js' ]
}
** (Mix) `mix tailwind default` exited with 1
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
