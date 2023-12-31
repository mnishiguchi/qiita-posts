---
title: tmuxのコピペとクリップボード
tags:
  - Vim
  - Linux
  - tmux
  - Linuxコマンド
  - neovim
private: false
updated_at: '2023-09-03T05:31:17+09:00'
id: b8526fecd69aa87d2f7e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
## はじめに

古い macbook に [Linux Mint] 21 をインストールして復活させました。普段は仕事で macOS を使っているので、[Linux Mint] に行ったりきたりしやすいように工夫を試みています。その一環として可能な限り [OS][オペレーティングシステム] を問わずに共通の設定で [neovim] と [tmux] を使えるように取り組んでいます。今回は、「[tmux] の コピペ と [クリップボード]」について調べてわかったことをメモします。

世の中にはいろんな [OS][オペレーティングシステム] が存在しますが、ここでは macOS と [Linux Mint] しか登場しません。[Linux Mint] の中身は [Ubuntu] らしいので、[Linux Mint] は 多分 [Ubuntu] と読み替えてもいいと思います。

![linux_mint_on_mac](https://user-images.githubusercontent.com/7563926/226134164-83465202-bd6b-4e44-a327-1a4ee27ea543.jpg)

[Linux Mint]: https://ja.wikipedia.org/wiki/Linux_Mint
[neovim]: https://neovim.io
[tmux]: https://github.com/tmux/tmux/wiki
[クリップボード]: https://ja.wikipedia.org/wiki/クリップボード
[オペレーティングシステム]: https://ja.wikipedia.org/wiki/オペレーティングシステム
[Ubuntu]: https://ja.wikipedia.org/wiki/Ubuntu
[ターミナル]: https://ja.wikipedia.org/wiki/端末エミュレータ

## クリップボード

> クリップボード（英: clipboard）は、コンピュータ上で、一時的にデータを保存できる共有のメモリ領域のことである。複数の異なるプログラムからアクセス可能であり、単一のアプリケーションだけでなく異なったアプリケーション間のデータの受け渡しにも使用される。

https://ja.wikipedia.org/wiki/クリップボード

日頃何も考えずに使っている[クリップボード]ですが、実はこれは[クリップボード]を操作するためのプログラムとアプリとがうまく連携していないとスムーズなコピペができないようです。

## コピペのショートカット

キーボードでコピペする技です。macOS でも Linux Mint でもアルファベットのキーは同じですが、一緒に押すキーが異なります。キーを変更することもできるのでしょうが、慣れた方が早い気がします。

### macOS

| やりたいこと | ショートカット |
| ------------ | -------------- |
| 切取         | `⌘` + `X`      |
| 複写         | `⌘` + `C`      |
| 貼付         | `⌘` + `V`      |

https://support.apple.com/ja-jp/HT209651

### Linux Mint

[Linux Mint] の[ターミナル]では `Shift` を押さないといけないので要注意。最初は戸惑いますが、慣れれば大丈夫。郷に入れば郷に従います。

| やりたいこと      | ショートカット         |
| ----------------- | ---------------------- |
| 切取              | `Ctrl` + `X`           |
| 複写              | `Ctrl` + `C`           |
| 貼付              | `Ctrl` + `V`           |
| ターミナルで 切取 | `Ctrl` + `Shift` + `X` |
| ターミナルで 複写 | `Ctrl` + `Shift` + `C` |
| ターミナルで 貼付 | `Ctrl` + `Shift` + `V` |

https://qiita.com/mnishiguchi/items/94d3ab813fca051a0e54

## コピペのコマンド

プログラムからクリップボードを操作するためのコマンドが存在します。いい感じにまとまっている記事がありました。ありがとうございます。OS によって使用可能なプログラムが異なります。

https://qiita.com/sasaplus1/items/137a70e8f51f97a6636f

### macOS

macOS では コマンドが備えついているので特に悩むことはありません。

| コマンド  | 機能                                       |
| --------- | ------------------------------------------ |
| `pbcopy`  | 標準出力を受け取ってクリップボードにコピー |
| `pbpaste` | クリップボードのデータをターミナルに出力   |

```bash
echo "闘魂" | pbcopy

pbpaste
```

### Linux Mint

Linux Mint にはクリップボードを操作するコマンドを自分でインストールする必要があります。また、いくつか選択肢があります。中でも `xsel` と `xclip` がよく利用されている様子です。ネット検索をしていて、「両方入れた方がいいよ！」との話があったので、深く考えず両方インストールしました。アプリにより、相性があるのではないかと想像しています。

```bash
sudo apt install xclip xsel
```

両方とも機能は似ています。

#### コピー先

ここで注意が必要なのがコピー先です。macOS のコマンドと異なり３種類あるので、クリップボードを操作するときにはコピー先がクリップボードと明示しておかないとどこにコピーしたのかわからなくなります。省略できるオプションもありますが、後々わかりやすいように明示しておくのが得策かもしれません。

- clipboard
- primary
- secondary

https://wiki.archlinux.jp/index.php/クリップボード

#### xsel でコピペ

```bash
echo "闘魂" | xsel --clipboard --input

xsel --clipboard --output
```

詳しくはドキュメントをご参照ください。

```bash
man xsel
```

#### xclip でコピペ

```bash
echo "闘魂" | xclip -selection clipboard -in

xclip -selection clipboard -out
```

詳しくはドキュメントをご参照ください。

```bash
man xclip
```

## neovim でクリップボードにヤンク（コピー）

vim 用語で copy のことを yank と言います。neovim でコピペするためにはいくつか条件を満たす必要があるようです。以下の記事にヒントがあります。

https://qiita.com/gotchane/items/0e7e6e0d5c7fa9f55c1a

```
                                  *clipboard-tool*
The presence of a working clipboard tool implicitly enables the '+' and '*'
registers. Nvim looks for these clipboard tools, in order of priority:

  - |g:clipboard|
  - pbcopy, pbpaste (macOS)
  - wl-copy, wl-paste (if $WAYLAND_DISPLAY is set)
  - xclip (if $DISPLAY is set)
  - xsel (if $DISPLAY is set)
  - lemonade (for SSH) https://github.com/pocke/lemonade
  - doitclient (for SSH) http://www.chiark.greenend.org.uk/~sgtatham/doit/
  - win32yank (Windows)
  - tmux (if $TMUX is set)
```

neovim はリストの上から順にクリップボード用のプログラムを探すようです。環境変数に依存する部分があるのでそこも注意が必要です。

## tmux のコピーモード

tmux にはターミナル内で vim 風の操作をできるようにするコピーモードがあります。コピペできるだけでなくターミナル内を高速に移動できるようになり便利です。

https://github.com/tmux/tmux/wiki/Getting-Started#copy-and-paste

しかしながら、クリップボードとの連携に若干の癖がありました。しっかり準備をしないとイゴきません。

いくつか参考になる記事がありましたが、当時の tmux から設定方法が一部変わっているので注意が必要です。アイデアをありがたく頂きつつ、最後は原典に当たるのが一番です。

```
man tmux
```

現時点（2023 年 5 月）で最新は tmux 3.3a です。tmux 3.2 から `copy-command` オプションが導入されました。他にも書き方が変わっている部分がいくつかあります。

https://qiita.com/shimmer22/items/67ba93060ae456aadd1b

https://dev.to/iggredible/the-easy-way-to-copy-text-in-tmux-319g

https://github.com/tmux/tmux/wiki/Clipboard

色々試行錯誤した結果、`~/tmux.conf` の設定は以下の通りに落ち着きました。関連する部分を抜粋します。Linux Mint と macOS とでクリップボードのコマンドが違うので、条件分岐します。OS の種類の確認が厳密ではありませんが、自分用の設定なので問題ありません。

Linux 用クリップボードのプログラムとして `xsel` を使います。`xclip` より `xsel` の方が tmux との相性がいいようです。もちろん `xsel` コマンドがインストールされていることが前提です。

`set-clipboard` と `copy-pipe` が競合する場合があるそうです。[ドキュメントの指示](https://github.com/tmux/tmux/wiki/Clipboard#set-clipboard-and-copy-pipe)に従い `set-clipboard` を無効にします。

tmux のコピーモードの `mode-keys` は `emacs` か `vi` か選択できます。ここでは `vi` を使います。

コピーモード（vi）の初期設定ではコピーは `Enter` キーで実行するようになっています。Vimmer にとっては `y` でヤンクする方が自然なのでそれができるようにカスタマイズします。

```bash:tmux.conf
# マウス有効化
set -g mouse on

# コピーモード（vi）を有効化
set-window-option -g mode-keys vi

# OS が Linux の時は xsel を使う
if-shell -b '[ "$(uname)" = "Linux" ]' {
  set -s copy-command "xsel --clipboard --input"
  display "using xsel as copy-command"
}

# OS が Darwin の時は pbcopy を使う
if-shell -b '[ "$(uname)" = "Darwin" ]' {
  set -s copy-command "pbcopy"
  display "using pbcopy as copy-command"
}

# copy-pipe と競合する場合があるので無効化
set -s set-clipboard off

# コピーモード中に Vim 風に v で選択範囲を定める
bind -Tcopy-mode-vi v send -X begin-selection

# コピーモード中に Vim 風に y で選択範囲をヤンクしてコピーモードを終了する
bind -Tcopy-mode-vi y send -X copy-pipe-and-cancel

# マウスをドラッグして選択範囲を定め、それをヤンクしてコピーモードを終了する
bind -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel
```

`copy-command` などの tmux の設定値を確認したい時は　`tmux show` が便利です。

```bash
tmux show copy-command
```

コピーモードのショートカットの初期設定は `man tmux` を打てば出てきます。

```
The following commands are supported in copy mode:

           Command                                      vi              emacs
           append-selection
           append-selection-and-cancel                  A
           back-to-indentation                          ^               M-m
           begin-selection                              Space           C-Space
           bottom-line                                  L
           cancel                                       q               Escape
           clear-selection                              Escape          C-g
           copy-end-of-line [<prefix>]
           copy-end-of-line-and-cancel [<prefix>]
           copy-pipe-end-of-line [<command>] [<prefix>]
           copy-pipe-end-of-line-and-cancel [<command>] [<prefix>]
                                                        D               C-k
           copy-line [<prefix>]
           copy-line-and-cancel [<prefix>]
           copy-pipe-line [<command>] [<prefix>]
           copy-pipe-line-and-cancel [<command>] [<prefix>]

           copy-pipe [<command>] [<prefix>]
           copy-pipe-no-clear [<command>] [<prefix>]
           copy-pipe-and-cancel [<command>] [<prefix>]
           copy-selection [<prefix>]
           copy-selection-no-clear [<prefix>]
           copy-selection-and-cancel [<prefix>]         Enter           M-w
           cursor-down                                  j               Down
           cursor-down-and-cancel
           cursor-left                                  h               Left
           cursor-right                                 l               Right
           cursor-up                                    k               Up
           end-of-line                                  $               C-e
           goto-line <line>                             :               g
           halfpage-down                                C-d             M-Down
           halfpage-down-and-cancel
           halfpage-up                                  C-u             M-Up
           history-bottom                               G               M->
           history-top                                  g               M-<
           jump-again                                   ;               ;
           jump-backward <to>                           F               F
           jump-forward <to>                            f               f
           jump-reverse                                 ,               ,
           jump-to-backward <to>                        T
           jump-to-forward <to>                         t
           jump-to-mark                                 M-x             M-x
           middle-line                                  M               M-r
           next-matching-bracket                        %               M-C-f
           next-paragraph                               }               M-}
           next-space                                   W
           next-space-end                               E
           next-word                                    w
           next-word-end                                e               M-f
           other-end                                    o
           page-down                                    C-f             PageDown
           page-down-and-cancel
           page-up                                      C-b             PageUp
           pipe [<command>] [<prefix>]
           pipe-no-clear [<command>] [<prefix>]
           pipe-and-cancel [<command>] [<prefix>]
           previous-matching-bracket                                    M-C-b
           previous-paragraph                           {               M-{
           previous-space                               B
           previous-word                                b               M-b
           rectangle-on
           rectangle-off
           rectangle-toggle                             v               R
           refresh-from-pane                            r               r
           scroll-down                                  C-e             C-Down
           scroll-down-and-cancel
           scroll-up                                    C-y             C-Up
           search-again                                 n               n
           search-backward <for>                        ?
           search-backward-incremental <for>                            C-r
           search-backward-text <for>
           search-forward <for>                         /
           search-forward-incremental <for>                             C-s
           search-forward-text <for>
           search-reverse                               N               N
           select-line                                  V
           select-word
           set-mark                                     X               X
           start-of-line                                0               C-a
           stop-selection
           toggle-position                              P               P
           top-line                                     H               M-R
```

## さいごに

最終的にコンパクトにまとまって満足しています。[Linux Mint] がどんどん好きになってきました。

## モクモク會

本記事は以下のモクモク會での成果です。みなさんから刺激と元氣をいただき、ありがとうございました。

https://youtu.be/c0LP23SM7BU

https://okazakirin-beam.connpass.com/

https://autoracex.connpass.com

もしご興味のある方はお氣輕にご參加ください。

https://qiita.com/piacerex/items/09876caa1e17169ec5e1

https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian

https://qiita.com/torifukukaiou/items/57a40119c9eefd056cae

https://qiita.com/piacerex/items/e0b6e46b1325bb931122

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

https://qiita.com/piacerex/items/e5590fa287d3c89eeebf

https://qiita.com/torifukukaiou/items/4481f7884a20ab4b1bea

https://note.com/awesomey/n/n4d8c355bc8f7

![](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/dc1ddba7-ab4c-5e20-1331-143c842be143.jpeg)
