---
title: asdf 複数のプラグインを一氣にまとめてインストール
tags:
  - Erlang
  - Bash
  - Elixir
  - asdf
  - 闘魂
private: false
updated_at: '2023-08-29T04:57:09+09:00'
id: 68fb2869110bc823e595
organization_url_name: fukuokaex
slide: false
---
[asdf]は複数のプログラムの複数のバージョンを管理できて便利です。必要な時にひとつひとつインストールするのは別に苦にならないと思いますが、まっさらな[パーソナルコンピュータ]（PC）や[仮想機械]（VM）の設定を行う時には必要なプログラムを一氣にまとめてインストールしたくなります。

https://asdf-vm.com

https://qiita.com/search?q=asdf

<!-- begin hyperlink list -->
[パーソナルコンピュータ]: https://ja.wikipedia.org/wiki/パーソナルコンピュータ
[仮想機械]: https://ja.wikipedia.org/wiki/仮想機械
[asdf]: https://asdf-vm.com/
[asdf Getting Started]: https://asdf-vm.com/guide/getting-started.html
[bash]: https://ja.wikipedia.org/wiki/Bash
<!-- end hyperlink list -->


## 戦略を練る

### プログラミング言語
ターミナルで直接使える[bash]にすることにします。

### 繰り返し処理
複数の対象に対して同じ処理を行うには多分ループがそれ相当のものが必要であると考えられます。

## bashでループ
これさえできれば、目的が達成できるはずです。
ネット検索して練習しました。

```bash:闘魂フォーエバー
n=1; while true; do echo "闘魂 $n"; ((n++)); sleep 1; done
```

```bash:123-1
for n in 1 2 3; do echo $n; done
```

```bash:123-2
for n in {1..3}; do echo $n; done
```

[bash]に配列なんてあったんですね。

```bash:123-3
numbers=(1 2 3); for n in "${numbers[@]}"; do echo $n; done
```

https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash

これで技術的な準備はOK!

## 一氣にまとめてインストール

繰り返し処理以外は[asdfの公式ドキュメント][asdf Getting Started]に書いてある通りです。

```bash:terminal
# asdfをインストール
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0

# 万一インストールされたasdfのバージョンが最新でない場合にアップデート
asdf update

# インストールしたいasdfのプラグインの名称を配列に入れる
plugins=(
  erlang
  elixir
  neovim
  delta
  fzf
  lua
  nodejs
  ripgrep
  shfmt
  zig
)

# 配列に対して繰り返し処理
for plugin in "${plugins[@]}"; do
  asdf plugin add "$plugin"
  asdf install "$plugin" latest
  asdf global "$plugin" latest
done
```

[asdf]をインストールした後のやり方がお使いのシェルによって異なるため、詳しくは[asdfの公式ドキュメント][asdf Getting Started]をご参照ください。[bash]の場合は以下の通りです。

```bash:terminal
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
source ~/.bashrc
```

## プラグイン名の確認方法

プラグイン名は[asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins/tree/master/plugins)のリポジトリで確認できます。

[asdf]をインストールした後は、`asdf plugin list all`コマンドを打つと利用可能な全てのプラグインを列挙できます。あまりにも数が多いので`less`か`grep`にパイプするとみやすくなりそうです。

```bash:CMD
asdf plugin list all | less
```

```bash:CMD
asdf plugin list all | grep -e '^e'
```

:tada::tada::tada:

## asdfでよく使うコマンド
[asdf]の使い方を忘れたらこれを思い出してください。何も暗記する必要はありません。

https://qiita.com/torifukukaiou/items/9009191de6873664bb58

