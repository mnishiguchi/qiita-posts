---
title: tmux 非アクティブのウインドウペインの背景色を変更
tags:
  - Linux
  - tmux
  - UNIX
private: false
updated_at: '2023-11-27T12:36:58+09:00'
id: 210453c5778769df369a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[tmux]でウインドウ（窓）を複数のペイン（窓ガラス）に分割している時に、初期設定のままだとどれがアクティブなのかわかりにくいです。

非アクティブのウインドウペイン（窓ガラス）の背景色を変更することにより、見た目で判別しやすくなります。

調べたことをここにメモしておきます。

![tmux-dim-inactive-panes.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/ffb5977a-db65-1f96-9396-f3447c278335.gif)

## やりかた

たくさんある[options]のうち、[window-style]と[window-active-style]の`fg`(foreground colour)と`bg`(background colour)を変更することにより実現できます。

`fg`は文字の色、`bg`は背景の色です。両方またはどちらか一方を調整することにより、お好みの色の組み合わせにします。

```shell:$HOME/.tmux.conf
# 非アクティブな窓ガラス
set -g window-style 'bg=#303030'

# アクティブな窓ガラス
set -g window-active-style 'bg=#000000'
```

```shell:$HOME/.tmux.conf
# 非アクティブな窓ガラス
set -g window-style 'fg=colour244,bg=colour234'

# アクティブな窓ガラス
set -g window-active-style 'fg=white,bg=black'
```

https://man.archlinux.org/man/tmux.1#STYLES


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

status line の色の変更にも取り組みました。もしよかったらご覧ください。

https://qiita.com/mnishiguchi/items/18ff80c0cb8269ff6dd8

本記事は [autoracex #259](https://autoracex.connpass.com/event/300537/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[tmux]: https://github.com/tmux/tmux
[tmux manual]: https://man.archlinux.org/man/tmux.1
[window-style]: https://man.archlinux.org/man/tmux.1#window-style
[window-active-style]: https://man.archlinux.org/man/tmux.1#window-active-style
[options]: https://man.openbsd.org/OpenBSD-current/man1/tmux.1#OPTIONS
[8ビットカラー]: https://ja.wikipedia.org/wiki/%E8%89%B2%E6%B7%B1%E5%BA%A6#8%E3%83%93%E3%83%83%E3%83%88%E3%82%AB%E3%83%A9%E3%83%BC
[RGB]: https://ja.wikipedia.org/wiki/RGB
