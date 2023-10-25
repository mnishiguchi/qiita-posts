---
title: Git commit と .gitmessage
tags:
  - Git
  - GitHub
  - 猪木
  - AdventCalendar2023
  - 闘魂
private: false
updated_at: '2023-06-04T08:53:38+09:00'
id: aa198ced2a516b67341d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[Git] のコミットメッセージの書き方には特に制約もなく、自由に好きなように書けます。しかしながら、伝えたいことが中々うまくまとまらなかったり、適当な[コミット]ばかりしているとのちに履歴が読みにくくなったりします。ある程度の規約を設けると仕事が捗るかもしれません。

[Git]: https://ja.wikipedia.org/wiki/Git

[コミット]: https://ja.wikipedia.org/wiki/コミット_(バージョン管理)

## Git commit コマンド

お好みのエディターを開いてメッセージを書きたい場合は、オプション指定なしでコマンドを打ちます。

```bash
git commit     
```

Git で使うエディターを指定する方法が複数あるようです。

https://stackoverflow.com/questions/2596805/how-do-i-make-git-use-the-editor-of-my-choice-for-editing-commit-messages

ターミナル内で完結させたい場合は、`-m` オプションを用いて直にメッセージを渡す事ができます。

```bash
git commit -m "元氣があれば何でもできる" 
```

複数の段落を設けたい場合は `-m` オプションを複数回渡す事ができます。それらは1行間隔で連結されます。お好みのエディターで編集する場合も同様に1行空けて複数の段落に分ける事ができます。

```bash
git commit -m "概要" -m "本文" -m "脚注"
```

`--cleanup=<mode>` オプションがあり、初期設定では `#` から始まるコメントとメッセージ前後の空白文字が自動で除去されます。通常はこのオプションをいじることはないと思うのですが、この特性は把握しておくと良いと思います。最終的に空になるコミットは（明示的にそれを許可しない限り）無効となります。詳しくは原典をご参照ください。

https://git-scm.com/docs/git-commit

https://www.atlassian.com/git/tutorials/saving-changes/git-commit

## Git コミットメッセージに規約を設ける

ネット検索してみると、多くの人がコミットの概要に接頭辞をつけることを提案しています。どうもそれらは [Angular] 関連のプロジェクトで使われている規約が基になっているようです。まずは原典にあたるのが良さそうです。

https://github.com/angular/angular/blob/cb31dbc75ca4141d61cec3ba6e60505198208a0a/CONTRIBUTING.md#commit

http://karma-runner.github.io/0.10/dev/git-commit-msg.html

[Angular]: https://ja.wikipedia.org/wiki/Angular

> We have very precise rules over how our Git commit messages must be formatted. This format leads to easier to read commit history.

コミット履歴を読みやすくする目的で、特に Git コミットメッセージの形式については、厳密な規約を設けたとのことです。

### 構成

1. 概要
2. 空白行
3. 本文
4. 空白行
5. 脚注

### 概要の書き方

```bash
xxx(yyy): zzz
│    │    │
│    │    └─⫸ 現在形での要約（小文字で、最後のピリオドなし）
│    │
│    └─⫸ 影響を受ける範囲、パッケージ等
│  
└─⫸ コミットタイプ
```

コミットタイプには、[Angular] チームでは以下のものが使用されています。

- `build`: ビルドシステムまたは外部依存関係に影響を与える変更
- `ci`: CI 関連のファイルとスクリプトへの変更
- `docs`: ドキュメントのみの変更
- `feat`: 新機能
- `fix`: バグ修正
- `perf`: パフォーマンスを向上させるコード変更
- `refactor`: バグの修正も機能の追加も行わないコード変更
- `test`: 不足しているテストの追加または既存のテストの修正

いろんな記事を見てみると以下をコミットタイプに含める人もいるようです。

- `BREAKING CHANGE`: 破壊的変更 ([セマンティック バージョニング] の メジャーバージョンが上がる時)
- `chore`: 依存性など
- `style`: 空白、セミコロン、字下げなど

[セマンティック バージョニング]: https://semver.org/lang/ja

### 本文の書き方

- 概要と同様に、現在形で。
- コミットメッセージ変更した動機や理由を説明。
- 変更の影響が把握しやすいよう、以前の動作と新しい動作の対比をここに示してもよい。

### 脚注の書き方

- 破壊的変更（`BREAKING CHANGE`）や非推奨（`DEPRECATED CHANGE`）に関する情報
- 関連する GitHub issues、pull requests、Jira チケットなど

```
BREAKING CHANGE: <破壊的変更の要約>
<空白行>
<破壊的変更の説明 + 移行手順>
<空白行>
<空白行>
Fixes #<issue 番号>
```

```
DEPRECATED: <何が非推奨になるのか>
<空白行>
<非推奨の説明 + アップデート手順>
<空白行>
<空白行>
Closes #<pull-request 番号>
```

色々参考になります。次のステップとしては適用したい規約をどのように習慣づけるのかという課題が残ります。コミットメッセージを書くたびに規約の書かれた文書を参照するのは面倒だし、記憶するのも大変だと思います。これでは中々習慣にはなりません。解決策の一つとしてGit コミットメッセージのテンプレートがあげられます。

## Git コミットメッセージのテンプレートを作る

`git commit` コマンドを打った時にお気に入りのエディターで表示される内容をカスタマイズする事ができます。そこに適用したい規約や書き方についてのメモする事ができます。やり方は簡単です。

1. `~/.gitmessage`を作成し、テンプレートを書く
2. `git config --global commit.template ~/.gitmessage` コマンドを打ち、上述のテンプレートを登録

https://qiita.com/P-man_Brown/items/486bed4d250c52a542da

https://thoughtbot.com/blog/better-commit-messages-with-a-gitmessage-template

https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration

例えばこのようなテンプレートを作る事ができます。誰が決めたのか知りませんが、推奨される文字数があるようです。

```bash:~/.gitmessage


# ## 概要
# xxx(yyy): zzz
# ------ 50 charcters -------------------------->|


# ## 本文
# ------ 72 charcters ------------------------------------------------>|


# ## 概要の書き方
#
#   xxx(yyy): zzz
#   │    │    │
#   │    │    └─⫸ 現在形での要約（小文字で、最後のピリオドなし）
#   │    │
#   │    └─⫸ 影響を受ける範囲、パッケージ等
#   │
#   └─⫸ コミットの種類
#
# - build: ビルドシステムまたは外部依存関係に影響を与える変更
# - ci: CI 関連のファイルとスクリプトへの変更
# - docs: ドキュメントのみの変更
# - feat: 新機能
# - fix: バグ修正
# - perf: パフォーマンスを向上させるコード変更
# - refactor: バグの修正も機能の追加も行わないコード変更
# - test: 不足しているテストの追加または既存のテストの修正
# - chore: 依存性のアップデートなど
# - style: 空白、セミコロン、字下げなど
#
# ## 本文の書き方
# 
# - 概要と同様に、現在形で。
# - コミットメッセージ変更した動機や理由を説明。
# - 変更の影響が把握しやすいよう、以前の動作と新しい動作の対比をここに示してもよい。
# 
# ## 脚注の書き方
# 
# - 破壊的変更 (BREAKING CHANGE) や非推奨 (DEPRECATED) に関する情報
# - 関連する GitHub issues、pull requests、Jira チケットなど
#
#   BREAKING CHANGE: <破壊的変更の要約>
#   <空白行>
#   <破壊的変更の説明 + 移行手順>
#   <空白行>
#   <空白行>
#   Fixes #<issue 番号>
#
#   DEPRECATED: <何が非推奨になるのか>
#   <空白行>
#   <非推奨の説明 + アップデート手順>
#   <空白行>
#   <空白行>
#   Closes #<pull-request 番号>
```

コミットのたびに元氣がでるメッセージを表示させて、気持ちを奮い立たせててみても良いかもしれません。`#` から始まるコメントは除去されるので何でもできます。

```bash
# 元氣ですかーーーーッ！ 元氣があればなんでもできる
```

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

## 最強のコミットメッセージを考える

いろんな方が最強の規約を提案してくれています。それらが参考になるかもしれません。あまり深く考えるのは本末転倒の気がしますので、ゆるくやっていけば良いのではないでしょうか。

Qiita で検索しても色々でてきますし、英語の記事も多数見つかります。 

https://qiita.com/konatsu_p/items/dfe199ebe3a7d2010b3e

https://qiita.com/grrrr/items/22bcf41199987ede4191

https://qiita.com/search?q=gitmessage&sort=created

https://www.conventionalcommits.org/ja/v1.0.0

https://www.freecodecamp.org/news/how-to-write-better-git-commit-messages

できました :tada:

![CleanShot 2023-06-03 at 15.09.48.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/b1ebe801-674e-3eec-965f-73b43a0e0e43.png)

## commitlint

読者の @RyoWakabayashi さんから 「いつも Conventional Commit を commitlint で強制しています」とお便りをいただきました。ありがとうございます！

https://commitlint.js.org

https://www.conventionalcommits.org/ja/v1.0.0/

## モクモク會

本記事は以下のモクモク會での成果です。みなさんから刺激と元氣をいただき、ありがとうございました。

https://okazakirin-beam.connpass.com/

https://autoracex.connpass.com

もしご興味のある方はお氣輕にご參加ください。

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://elixir-lang.info/topics/entry_column

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/57a40119c9eefd056cae

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
