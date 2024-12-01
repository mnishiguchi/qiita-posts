---
title: Elixir Port を使って C 言語プログラムと連携する
tags:
  - C
  - port
  - Elixir
  - IoT
  - Nerves
private: false
updated_at: '2024-12-08T21:41:38+09:00'
id: 6e0c486cd5907348d321
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---


## はじめに

Elixir の [Port](https://hexdocs.pm/elixir/Port.html) を使うと、C 言語などで書かれた外部プログラムと連携できます。
ただ、どこから手をつければいいのか、全体の構成が掴みにくいことがありますよね。

この記事では、Port を使ったプロジェクトの基本構成を学べるように、次の 2 つのプロジェクトを例に解説します。

1. **[Blinkchain](https://github.com/GregMefford/blinkchain)**: LED 制御ライブラリで、Port を活用したベストプラクティスの学びが得られます。
2. **[elixir-sensors/sgp40](https://github.com/elixir-sensors/sgp40)**: Blinkchain の構成を参考にして実装した空気質センサーライブラリ。

Port を用いたプロジェクトの全体像を理解し、自分のアイデアに応用できる内容を目指します。

## Blinkchain とは

**Blinkchain** は、Elixir を使って LED ストリップ（WS2812B など）を制御するライブラリです。  
内部では Port を利用して C 言語コードを呼び出し、高速でハードウェア制御を行っています。

## Blinkchain の学びが役立った点

1. **ディレクトリ構成の整理**:

   - `c_src/` ディレクトリで C プログラムを管理し、Makefile を活用したビルドフローを導入。

2. **Port 通信の抽象化**:

   - Port を専用モジュールで管理し、Elixir 側からは API を通じて簡単に操作できる構造を採用。

3. **明確な公開 API の設計**:
   - ユーザー向けの操作をシンプルにし、利用者が内部の複雑さを意識せずに使えるように設計。


## Blinkchain のディレクトリ構成

```plaintext
blinkchain/
├── c_src/                       # **C プログラムのソースコードを格納**
│   └── port_interface.c         # **LED 制御ロジック**
├── lib/
│   ├── blinkchain.ex            # **公開 API**
│   └── blinkchain/              # **内部ロジックをモジュール化**
│       └── port.ex              # **Port 通信の管理**
├── test/
│   └── blinkchain_test.exs      # **テストコード**
├── Makefile                     # **C プログラムのビルド設定**
├── mix.exs                      # プロジェクト設定
└── README.md                    # プロジェクトのドキュメント
```

## Blinkchain の各ファイルの役割と実装例

### C プログラム（`c_src/port_interface.c`）

以下は、標準入力で受け取ったコマンドを元に LED を制御する C プログラムの簡略化版です。

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    char command[256];
    while (fgets(command, sizeof(command), stdin)) {
        if (strcmp(command, "turn_on") == 0) {
            printf("LED turned on");
        } else if (strcmp(command, "turn_off") == 0) {
            printf("LED turned off");
        } else {
            printf("Unknown command");
        }
        fflush(stdout);
    }
    return 0;
}
```

### Makefile（`Makefile`）

C プログラムを簡単にコンパイルできるように Makefile を用意します。

```makefile
all:
	gcc -o port_interface c_src/port_interface.c
```

`make` コマンドを実行することで、`port_interface` バイナリが生成されます。

### Port 管理モジュール（`lib/blinkchain/port.ex`）

Port を管理する Elixir モジュールです。

```elixir
defmodule Blinkchain.Port do
  def send_command(command) do
    port = Port.open({:spawn, "./port_interface"}, [:binary])

    send(port, {self(), {:command, "#{command}"}})

    receive do
      {^port, {:data, response}} -> String.trim(response)
    after
      5000 -> "Timeout"
    end
  end
end
```

### 公開 API（`lib/blinkchain.ex`）

ライブラリ利用者向けのシンプルな API を提供します。

```elixir
defmodule Blinkchain do
  alias Blinkchain.Port

  def turn_on do
    Port.send_command("turn_on")
  end

  def turn_off do
    Port.send_command("turn_off")
  end
end
```

### テストコード（`test/blinkchain_test.exs`）

```elixir
defmodule BlinkchainTest do
  use ExUnit.Case
  alias Blinkchain

  test "turns on the LED" do
    assert Blinkchain.turn_on() == "LED turned on"
  end

  test "turns off the LED" do
    assert Blinkchain.turn_off() == "LED turned off"
  end
end
```

## elixir-sensors/sgp40 プロジェクトでの応用

Blinkchain で学んだ構成や実装パターンを元に、私のプロジェクト **[elixir-sensors/sgp40](https://github.com/elixir-sensors/sgp40)** では、空気質センサー SGP40 のデータを Elixir で取得する仕組みを構築しました。

```plaintext
sgp40/
├── c_src/                       # **C プログラムのソースコードを格納**
│   └── sgp40.c                  # **センサー制御ロジック**
├── lib/
│   ├── sgp40.ex                 # **公開 API**
│   └── sgp40/                   # **内部ロジックをモジュール化**
│       └── port.ex              # **Port 通信の管理**
├── test/
│   └── sgp40_test.exs           # **テストコード**
├── Makefile                     # **C プログラムのビルド設定**
├── mix.exs                      # プロジェクト設定
└── README.md                    # プロジェクトのドキュメント
```

:tada: :tada: :tada: 

## おわりに

この記事では、Elixir の Port を使って C 言語プログラムと連携する方法を解説しました。

Port を活用した連携は、ハードウェアや外部プログラムを操作する際に非常に強力です。ぜひ、この記事を参考に、自分のプロジェクトに取り入れてみてください！

何か氣づいた点や改善提案があれば、コメントで共有していただけると嬉しいです！

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

## 関連リンク

- [Blinkchain GitHub リポジトリ](https://github.com/GregMefford/blinkchain)
- [elixir-sensors/sgp40 GitHub リポジトリ](https://github.com/elixir-sensors/sgp40)
- [Elixir Port 公式ドキュメント](https://hexdocs.pm/elixir/Port.html)
- [elixir_make](https://github.com/elixir-lang/elixir_make)

