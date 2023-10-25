---
title: Neovim Lua LS で「undefined global vim」警告が出ないようにしたい
tags:
  - Vim
  - Lua
  - neovim
  - LanguageServerProtocol
private: false
updated_at: '2023-09-03T05:31:17+09:00'
id: 03863db76e1ed1431c50
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
先日、[Neovim] のプラグインの設定をアップデートしている時にひとつ問題に出会しました。[Lua 言語サーバー][Lua language server] が出してくれる診断結果メッセージは、通常はうっかりミスを防ぐのに便利なのですが、なかには許容できる警告もあります。その一つが、「undefined global vim」という警告です。この警告を出ないようにする具体的な方法がなかなかネット検索では見つからず苦労しました。需要があるのかどうか知りませんが、忘れないうちにメモします。

[Neovim]: https://neovim.io
[lua-stdlib]: https://neovim.io/doc/user/lua.html#lua-stdlib
[Lua language server]: https://github.com/LuaLS/lua-language-server
[language-server-protocol]: https://learn.microsoft.com/ja-jp/visualstudio/extensibility/language-server-protocol
[Lua LS Diagnostics - undefined-global]:https://github.com/LuaLS/lua-language-server/wiki/Diagnostics#undefined-global

## 対策

`~/.config/nvim/luarc.json` をつくって、[Lua 言語サーバー][Lua language server]の挙動を微調整する。

```js:.config/nvim/luarc.json
{
  "diagnostics": {
    // 明示的に定義されていない vim モジュールをよしとする場合
    "globals": ["vim"],
    // 細かい助言がいらない場合
    "hint.enable": false
  }
}
```

## Neovim の vim モジュール

[Neovim] ドキュメントによると Nvim Lua の[「標準ライブラリ」(stdlib)][lua-stdlib] は、`vim` モジュールとして利用することができ、それは自動的に読み込まれるので `require("vim")` の宣言は不要とのことです。

> The Nvim Lua "standard library" (stdlib) is the vim module, which exposes various functions and sub-modules. It is always loaded, thus require("vim") is unnecessary.

ですので、Neovimの設定を書く際には、特に何もしなくても vim モジュールにアクセスできるようになっています。これ自体には特に何の問題もありません。

https://neovim.io/doc/user/lua.html#lua-stdlib

## 言語サーバープロトコル (LSP)

- プログラミング言語の機能を公開するために便利な共通の枠組みを提供
- プログラミング言語の機能を開発ツールに統合しやすくする

https://learn.microsoft.com/ja-jp/visualstudio/extensibility/language-server-protocol

## Lua 言語サーバー (Lua LS)

- Lua 言語の言語サーバーの実装

https://github.com/LuaLS/lua-language-server

## Lua 言語サーバーの診断機能

- Lua 言語のコードを診断
- 情報、警告、エラーなど、さまざまな重大度の情報を報告

https://github.com/LuaLS/lua-language-server/wiki/Diagnostics#undefined-global

[Neovim] ではうっかり文法を間違った場合は、このような診断報告がでます。

![CleanShot 2023-06-17 at 20.28.35.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/67d35c4d-bff8-5f2b-1cd2-dbba8c2b5687.png)

## 無効にしたい診断機能

ある時点から「undefined global vim」という警告がでるようになりました。なぜかはよくわかりません。

これは [Neovim] の仕様なので間違いではありません。この警告を無効にしたいです。

![CleanShot 2023-06-17 at 17.44.53.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/c3df71d6-b294-4865-737b-8f12ab3de81e.png)

場合によっては重要度の低い情報は無効にした方がスッキリするかもしれません。世の中にあるいくつかのサンプルコードでは使わない引数を含む関数が登場します。例えば、それらを何らかの理由で残しておきたいときにはそれに対する助言は無駄になります。

![CleanShot 2023-06-17 at 18.43.49.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/cacfe83a-fcd4-69e2-2e51-303bf9fd097e.png)

## .luarc.json

Lua言語サーバーの動作をカスタマイズする方法が複数あるそうです。その一つが `.luarc.json` ファイルです。

https://github.com/LuaLS/lua-language-server/wiki/Configuration-File

https://github.com/LuaLS/lua-language-server/wiki/Settings

Lua 言語サーバー自身にも `.luarc.json` ファイルがありました。

https://github.com/LuaLS/lua-language-server/blob/master/.luarc.json

`.luarc.json` ファイルを [Neovim] の設定のあるディレクトリに作成することにより、Lua言語サーバーの動作を補正できるようです。詳しいメカニズムはしりません。




Elixir 言語でコードの静的解析をする方法については @koga1020 さんの記事が参考になります。

https://zenn.dev/koga1020/articles/f98522e05c7dcb

## コミュニティ

### 闘魂コミュニティ

みんなでわいわい楽しく自由に闘魂プログラミングをしています。

https://autoracex.connpass.com

https://qiita.com/torifukukaiou/items/b6361f98194f3687a13c

https://qiita.com/torifukukaiou/items/98fbc9e341da2dbc33fb

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

ぜひお気軽にお立ち寄りください。

### Nervesで組み込み開発するコミュニティ

「Elixir で IoT！？ナウでヤングで cool な Nerves フレームワーク」です。

https://twitter.com/torifukukaiou/status/1201266889990623233


https://nerves-project.org

https://nerves-jp.connpass.com

https://okazakirin-beam.connpass.com/

https://kochi-embedded-meeting.connpass.com

https://www.slideshare.net/takasehideki/elixiriotcoolnerves-236780506

https://www.slideshare.net/YutakaKikuchi1/elixir-on-elixir-and-embedded-systems

https://zacky1972.github.io/blog/2023/05/26/pelemay_backend.html

### Elixir 言語でワクワクするコミュニティ

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd


![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
