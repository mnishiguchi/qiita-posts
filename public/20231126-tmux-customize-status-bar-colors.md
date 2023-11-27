---
title: tmux の status line の色を変更
tags:
  - Linux
  - tmux
  - UNIX
private: false
updated_at: '2023-11-27T20:41:58+09:00'
id: 18ff80c0cb8269ff6dd8
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

今まで[tmux]の見た目は、ほぼデフォルトのままでやってきました。そろそろ **自分らしさ** を出していこうと思います。

調べた内容をここにメモします。

## status line

[マニュアル][tmux manual]によると

- 画面下部にある帯
- 現在のセッションに関する情報が表示される
- 対話型コマンドの入力に使用される

> A status line at the bottom of the screen shows information on the current session and is used to enter interactive commands.

https://man.archlinux.org/man/tmux.1

![tmux-status-line-default.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/aba1ff85-ebe2-6836-a2e7-9ea7220dcd1c.png)

## 設定方法

status line の設定方法はこの記事に完結にまとめられていました。

https://qiita.com/nojima/items/9bc576c922da3604a72b

`set-option`コマンドには`set`という偽名が定義されているので、短く`set`と記述できます。
`set-window-option`コマンドも、短く`set`として問題ないようです。`set`コマンド一つでいけます。

https://man.archlinux.org/man/tmux.1#OPTIONS


永続化させたい設定は設定ファイル（`$HOME/.tmux.conf`）に`set -g ...`と書きます。
一時的に試したい場合は、`tmux`コマンドと`set`コマンドを組み合わせて、ターミナルで`tmux set -g ...`と打つことも可能です。
`-g`は「グローバルオプションとして設定」という意味ですが、深く考えず`set -g ...`でいいと思います。

[status-style]コマンドを用いて status line の`fg`(foreground colour)と`bg`(background colour)を変更できます。
`fg`は文字の色、`bg`は背景の色です。　両方またはどちらか一方を調整することにより、お好みの色の組み合わせにします。

```shell:$HOME/.tmux.conf
set -g status-style 'bg=black,fg=white'
```

現在アクティブなウインドウ名の見た目だけ変更したい場合は、[window-status-current-format]か[window-status-current-style]が便利です。

```shell:$HOME/.tmux.conf
# 現在アクティブなウインドウ名の文字の色を背景の色を入替
set -g window-status-current-format "#[reverse] #I:#W"

# 現在アクティブなウインドウ名の文字の色を背景の色を指定
set -g window-status-current-style 'bg=colour002,fg=black'
```

## 自分らしさ

- シンプルな見た目が好み
- [tmux]を使っていることを意識できるよう（白黒ではなく）色は残す
- どのウインドウがアクティブなのか一目でわかるようにしたい

これに決定！

```shell:$HOME/.tmux.conf
set -g status-right ''
set -g status-style 'bg=colour022,fg=colour064'
set -g window-status-current-style 'bg=colour022,fg=colour010'
```

![tmux-status-line-custom.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/73ce117c-bbbc-05d1-777b-cb2767a5d2e0.png)

:tada::tada::tada:

## 使える色

- `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- (明るい色がサポートされている場合)　`brightred`, `brightgreen`, `brightyellow`
- [8ビットカラー]の256色（`colour0` 〜 `colour255`）
- `default`（[tmux]のデフォルト）
- `terminal`（ターミナルのデフォルト）
- [RGB]（`#000000` 〜 `#ffffff`）

色の見本は[Wikipedia](https://en.wikipedia.org/wiki/Xterm)にいいのがありました。

![](https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg)

## さいごに

非アクティブのウインドウペイン（窓ガラス）の背景色の変更にも取り組みました。もしよかったらご覧ください。

https://qiita.com/mnishiguchi/items/210453c5778769df369a

本記事は [autoracex #259](https://autoracex.connpass.com/event/300537/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[tmux]: https://github.com/tmux/tmux
[tmux manual]: https://man.archlinux.org/man/tmux.1
[status-style]: https://man.archlinux.org/man/tmux.1#status-style
[window-status-current-format]: https://man.archlinux.org/man/tmux.1#window-status-current-format
[window-status-current-style]: https://man.archlinux.org/man/tmux.1#window-status-current-style
[options]: https://man.openbsd.org/OpenBSD-current/man1/tmux.1#OPTIONS
[8ビットカラー]: https://ja.wikipedia.org/wiki/%E8%89%B2%E6%B7%B1%E5%BA%A6#8%E3%83%93%E3%83%83%E3%83%88%E3%82%AB%E3%83%A9%E3%83%BC
[RGB]: https://ja.wikipedia.org/wiki/RGB
