---
title: AI開発を効率化するUithub風のシェルスクリプトを作ってみた
tags:
  - Bash
  - GitHub
  - AI
  - ChatGPT
  - uithub
private: false
updated_at: '2025-01-14T09:31:00+09:00'
id: af13b34ac636c03d97c5
organization_url_name: haw
slide: false
ignorePublish: false
---

## はじめに

「[Uithub]」という Web サービスをご存知でしょうか？私は先日、社内の勉強会で同僚から教えてもらいました。
Uithub は、GitHub リポジトリの構造やファイル内容をテキスト形式の一覧として出力する Web サービスです。
これを利用することで、リポジトリ全体の構造を AI に効率よく理解させ、分析や情報取得をより効果的に行うことができます。

そんな便利な Uithub ですが、ふと思いました。「これに似たことをローカル環境のターミナルで実現できないだろうか？」
そこで、Git 管理されたファイルの構造表示や内容の確認を簡単に行えるよう、いくつかのシェルスクリプトを書いてみました。

この記事では、そのスクリプトを紹介します。

[Uithub]: https://uithub.com

## Uithub とは？

Uithub は、GitHub リポジトリの構造やファイル内容を、文字ベースの一覧としてまとめた形式で出力する Web サービスです。これにより、リポジトリ全体の構造を AI に簡単に理解させることが可能になり、効率的な分析や質問が行えるようになります。

以下は、Uithub を使用した場合に得られる出力例です。この形式は、ディレクトリ構造と各ファイルの内容を簡単に把握できるように設計されています。

````plaintext
├── .gitignore
├── README.md
├── src
│   ├── main.py
│   ├── utils.py
│   └── __init__.py
├── tests
│   ├── test_main.py
│   └── test_utils.py
├── requirements.txt
└── Dockerfile

/README.md:
--------------------------------------------------------------------------------
1 | # Project Name
2 |
3 | Description of the project.
4 |
5 | ## Installation
6 | ```bash
7 | pip install -r requirements.txt
8 | ```

--------------------------------------------------------------------------------
/src/main.py:
--------------------------------------------------------------------------------
1 | def main():
2 |     print("Hello, World!")
3 |
4 | if __name__ == "__main__":
5 |     main()
````

詳しくは、同僚の Qiita 記事をご参照ください。

https://qiita.com/haw_ohnuma/items/3c4f0a764b1cf66bae7b

## 欲しい Uithub の機能

Uithub の出力形式を確認すると、いくつかの重要な特徴が浮かび上がりました。実現したい機能は以下の通りです。

1. ディレクトリ構造を表示する
2. Git で管理されているファイルを一覧化する
3. ファイルの内容を行番号付きで出力する

今回作成したスクリプトでは、これらの要件を満たすことを目標としました。

## 使用するツール

調査したところ、以下のツールを活用して、要件を満たせることがわかりました。

- `tree`: ディレクトリ構造を表示
- `git ls-files`: Git で管理されているファイルを列挙
- `cat -n`: ファイル内容を行番号付きで出力

## 作成したスクリプト

### 基本スクリプト

まずは、要件を最低限満たすシンプルなスクリプトを作成しました。

**ディレクトリ構造を表示**

```bash
tree -L 2
```

**Git で管理されているファイルを列挙**

```bash
# Git管理ファイルを列挙し内容を表示する関数
list_git_files_with_content() {
  git ls-files -z \
    | xargs -0 -I{} bash -c '\
      echo; \
      echo "==> {} <=="; \
      cat -n "{}"; \
      echo; \
      echo "---"'
}

# 関数の呼び出し
list_git_files_with_content
```

このスクリプトは以下の動作を行います。

- Git で管理されているファイルを取得（`git ls-files`）。
- 各ファイルの内容を行番号付きで表示（`cat -n`）。
- ファイルごとにヘッダーと区切り線を追加。

これらを組み合わせ以下のように記述すると、Uithub に似た形式で出力することができます！

```bash
# ディレクトリ構造とGitファイル内容を表示する関数
show_uithub_like_output() {
  (
    tree -L 2; \
    echo; \
    echo '---'; \
    git ls-files -z \
      | xargs -0 -I{} bash -c '\
        echo; \
        echo "==> {} <=="; \
        cat -n "{}"; \
        echo; \
        echo "---"'
  )
}

# 関数の呼び出し
show_uithub_like_output
```

**実行例**

以下は `show_uithub_like_output` 関数を実行した場合の出力例です。

```plaintext
├── .gitignore
├── README.md
├── lib
│   ├── main.ex
│   ├── utils.ex
│   └── mix.exs
├── test
│   ├── main_test.exs
│   └── utils_test.exs
└── mix.lock
---

==> .gitignore <==
     1 | # Ignore unnecessary files
     2 | _build/
     3 | deps/
---

==> README.md <==
     1 | # My Elixir Project
     2 |
     3 | Nothing interesting here yet. Try again later.
---

==> lib/main.ex <==
     1 | defmodule Main do
     2 |   def hello do
     3 |     IO.puts("元氣ですかーーーーッ！！！")
     4 |   end
     5 | end
---
```

### 便利な技

ここからは、便利な技を取り入れた例をいくつか紹介します。

#### 出力のページング処理

大規模なリポジトリでの出力を見やすくするため、`less` コマンドを用いてページング処理を追加します。

```bash
show_uithub_like_output | less -R
```

#### Git リポジトリかどうかを確認

現在のディレクトリが Git リポジトリであるかをチェックし、リポジトリ内でのみスクリプトを実行します。

```bash
show_uithub_like_output_in_git_repo() {
  # 現在のディレクトリがGitリポジトリであるかを確認
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Gitリポジトリ内であれば出力を実行
    show_uithub_like_output
  else
    # Gitリポジトリでない場合はエラーメッセージを表示
    echo "Error: This is not a Git repository." >&2
    return 1
  fi
}

# 関数の呼び出し
show_uithub_like_output_in_git_repo
```

#### 画像・動画ファイルの URL 出力実装

Uithub は、ファイルが画像・動画の場合には、URL を出力します。同様の処理を組み込んでみます。

```bash
show_uithub_like_output_with_media() {
  local base_url
  base_url="https://raw.githubusercontent.com/$(git config --get remote.origin.url | sed -E 's|git@github.com:|/|; s|https://github.com/||; s|\.git$||')/$(git rev-parse HEAD)"

  # メディアファイルかどうかを判定する関数
  is_media() {
    local file="$1"
    case "$file" in
      # 一般的な画像ファイル
      *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.tiff|*.svg|*.ico|*.webp|*.avif) return 0 ;;
      # 一般的な動画ファイル
      *.mp4|*.mkv|*.mov|*.avi|*.wmv|*.flv|*.webm|*.mpeg|*.mpg|*.m4v|*.3gp) return 0 ;;
      *) return 1 ;;
    esac
  }

  # ディレクトリ構造を表示
  tree -L 2
  echo
  echo '---'

  # Git管理ファイルを読み込み、処理
  git ls-files -z | while IFS= read -r -d '' file; do
    echo
    echo "==> $file <=="
    if is_media "$file"; then
      # メディアファイルの場合はURLを出力
      echo "$base_url/$file"
    else
      # 非メディアファイルの場合は内容を出力
      cat -n "$file"
    fi
    echo
    echo "---"
  done
}

# 関数の呼び出し
show_uithub_like_output_with_media
```

#### ファイルサイズのフィルタリング

100KB 以下のファイルだけを対象にします。

```bash
# Git管理ファイルを列挙し、指定したファイルサイズ以下の内容を表示する関数
list_git_files_with_content_by_size() {
  local max_size="$1"

  # Gitで管理されているファイルを取得
  git ls-files -z | while IFS= read -r -d '' file; do
    # IFS (Internal Field Separator) を空文字に設定することで、
    # ファイル名に含まれるスペースや特殊文字を安全に処理します。

    # ファイルサイズを取得
    local file_size
    file_size=$(stat -c%s "$file")

    # サイズが最大値以下であれば内容を出力
    if [ "$file_size" -le "$max_size" ]; then
      echo
      echo "==> $file <=="
      cat -n "$file"
      echo
      echo "---"
    fi
  done
}

# 関数の呼び出し（例: 100KB 以下のファイル）
list_git_files_with_content_by_size $((100 * 1024))
```

#### 特定のファイルタイプを除外

以下のスクリプトは Markdown ファイル（`.md`）を除外します。この方法を使うことで、ドキュメントファイルを除外し、ソースコードや設定ファイルなど、必要なファイルに集中できます。

```bash
# 指定したファイルタイプを除外してGit管理ファイルを列挙する関数
list_git_files_with_content_excluding_type() {
  local pattern="$1" # 除外するファイルタイプのパターンを引数で指定

  # Gitで管理されているファイルを取得し、指定したパターンを除外
  # mapfile はコマンドの出力を配列に格納するために使用します。
  # -d '' オプションを使うことで、null文字（\0）区切りのデータを安全に読み取れます。
  # これにより、スペースや特殊文字を含むファイル名を正しく処理できます。
  mapfile -d '' files < <(git ls-files -z | grep -z -v -e "$pattern")

  # 各ファイルを処理
  for file in "${files[@]}"; do
    # ファイルの内容を表示
    echo
    echo "==> $file <=="
    cat -n "$file"
    echo
    echo "---"
  done
}

# 関数の呼び出し（例: Markdownファイルを除外）
list_git_files_with_content_excluding_type '\.md$'
```

## おわりに

この記事では、Uithub から着想を得た便利なシェルスクリプトを紹介しました。
これらのスクリプトを活用することで、Git 管理されたファイルをより簡単に分析したり、AI モデルに適した形式で出力したりすることができます。

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)
