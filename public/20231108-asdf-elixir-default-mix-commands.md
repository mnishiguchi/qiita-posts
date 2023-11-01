---
title: asdf-elixir の default-mix-commands で Mix コマンドを自動で実行する
tags:
  - Erlang
  - 初心者
  - Elixir
  - asdf
  - Phoenix
private: false
updated_at: '2023-11-09T11:01:40+09:00'
id: 1f0f4a66dc45db8d0b39
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

[asdf]（複数のプログラミングツールのバージョン管理ができる便利なプログラム）を用いて関数型プログラミング言語 [Elixir] をインストールするに使う [asdf-elixir] プラグインの機能を一つご紹介いたします。

https://qiita.com/tags/asdf

https://qiita.com/iisaka51/items/eeb3a7fdc2b4f70b2b4f

https://qiita.com/torifukukaiou/items/9009191de6873664bb58

https://qiita.com/mnishiguchi/items/68fb2869110bc823e595

## 結論

ホームディレクトリで `.default-mix-commands` という名前のファイルを作り、その中に [Elixir] がインストールされた直後に自動的に実行してほしい Mix コマンドを列挙します。頻繁に使用されるアーカイブをインストールする場合に特に便利な機能です。

以下は [Phoenix] や [Nerves] を使いたい人向けの設定の一例です。

```bash:$HOME/.default-mix-commands
local.hex
local.rebar
archive.install hex phx_new
archive.install hex nerves_bootstrap
```

各コマンドには自動的に `--force` フラグ が追加されます。

![asdf-elixir-default-mix-commands.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/53970e1b-4fd4-28f0-6bed-756b455363f0.png)

:tada::tada::tada:

## さいごに

若干作業の流れがスムーズになり、より気軽に [Phoenix] アプリや [Nerves] デバイスに取り組めるのではないでしょうか。

本記事は [闘魂Elixir #55](https://autoracex.connpass.com/event/298180/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

[Mix]: https://hexdocs.pm/elixir/1.16/introduction-to-mix.html
[asdf]: https://asdf-vm.com
[asdf-elixir]: https://github.com/asdf-vm/asdf-elixir
[Phoenix]: https://www.phoenixframework.org/
[Erlang]: https://www.erlang.org/
[Elixir]: https://elixir-lang.org/
[Nerves]: https://github.com/nerves-project/nerves
[Linux]: https://ja.wikipedia.org/wiki/Linux

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
