---
title: NervesデバイスのストレージをホストのPCにマウント
tags:
  - Linux
  - Elixir
  - sshfs
  - Nerves
private: false
updated_at: '2024-07-21T17:33:06+09:00'
id: 0f224f3fb402811df7c1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

## はじめに

Nerves ファームウエアで動くのデバイス（[Raspberry Pi 4]等）のストレージをホストの PC にマウントします。

やり方はいくつかあるそうですが、ここでは [sshfs] を使う方法に挑戦します。

[sshfs]: https://wiki.archlinux.jp/index.php/SSHFS

https://wiki.archlinux.jp/index.php/SSHFS

https://embedded-elixir.com/post/2021-05-08-nerves-file-peeking/

## 環境

### ホスト

- OS: [LMDE 6 (Faye)](https://linuxmint.com/download_lmde.php) x86_64
- デスクトップ: [Cinnamon](https://wiki.archlinux.jp/index.php/Cinnamon) 6.0.4
- 機種: ThinkPad P14s Gen 4

### Nerves

- 対象デバイス: [Raspberry Pi 4]
- Nerves ファームウエア: [nerves_livebook] [v0.13.0](https://github.com/nerves-livebook/nerves_livebook/releases/tag/v0.13.0)

[Raspberry Pi 4]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/
[nerves_livebook]: https://github.com/nerves-livebook/nerves_livebook
[Nerves Livebook]: https://github.com/nerves-livebook/nerves_livebook
[Livebook]: https://livebook.dev/
[Nerves]: https://nerves-project.org/

## Nerves Livebook

[Nerves Livebook]を使用すると、何も構築せずに実際のハードウェアで [Nerves] プロジェクトを試すことができます。
[Livebook] のノートブック上でコードを実際に実行しながら進められるので、ブラウザーで快適に 楽しく[Nerves] を学べます。例えば、ブラウザ上でターゲットデバイスの Wi-Fi の設定ができます。

有志の方々が [Nerves Livebook] のセットアップ方法ついてのビデオやコラムを制作してくださっています。ありがとうございます。

https://youtu.be/-c4VJpRaIl4?si=XV26RifdxSjKog_L

https://youtu.be/-b5TPb_MwQE?si=nL43DmK7RNIQjOu5

https://qiita.com/search?q=nerves_livebook

## Nerves デバイスの読み書きできる場所

`/data`(`/root` へのシンボリックリンク) が Nerves システムの書き込み可能な部分です。
これは、[vintage_net] を含むいくつかのライブラリが永続化のために使用しています。

書き込み可能なパーティションは常に `/root` ですが、書き込み可能なパーティションを簡単に識別できるようにする目的で、シンボリックリンク`/data`が追加されることになった経緯があるようです。

```bash:Nerves
iex(livebook@nerves-9bd5.local)6> ls "/"
bin       boot      data      dev       etc
lib       lib64     media     mnt       opt
proc      root      run       sbin      srv
sys       tmp       usr       var
```

```bash:Nerves
iex(livebook@nerves-9bd5.local)7> cmd "ls -l /root"
-rw-r--r--    1 root     root         19008 Apr  1 01:29 last_shutdown.txt
drwx------    2 root     root          3488 Apr  1 00:55 vintage_net
drwx------    2 root     root          3488 Jul 11 22:48 seedrng
drwx------    2 root     root          3488 Jul 11 22:48 livebook
drwx------    3 root     root          3488 Apr  1 00:53 nerves_ssh
0
```

```bash:Nerves
iex(livebook@nerves-9bd5.local)8> cmd "ls -l /data"
lrwxrwxrwx    1 root     root             4 Oct 21  2020 /data -> root
0
```

https://qiita.com/torifukukaiou/items/9dd5cfa81109a2e0a5eb

https://hexdocs.pm/nerves/advanced-configuration.html#partitions

[vintage_net]: https://hexdocs.pm/vintage_net

## `sshfs` コマンド

`sshfs` コマンドは、SSH を使用してリモートのファイルシステムをホストの PC にマウントするプログラムです。多数のファイルを手早く操作したいときに非常に便利です。

ファイル共有の方法は他にもありますが、 `sshfs` はサーバー側の設定が不要という利点があるそうです。

デフォルトでは含まれていない場合、ホスト PC にインストールする必要があります。Debian の場合は以下のコマンドでインストールできました。

```bash
sudo apt install sshfs
```

使い方は`sshfs --help` や `man sshfs` で確認できます。

```bash
$ sshfs --help
usage: sshfs [user@]host:[dir] mountpoint [options]

...snip...
```

必要に応じて`-o`オプションにより、様々な SSH のオプションを指定することが可能のようです。

## 論より Run

### やること

`sshfs` コマンドを使って、Nerves デバイス上の `/root` をホストの PC にマウントします。
これにより、Nerves デバイス上のファイルをホストの PC 上で直接、編集できるようになります。

### Nerves デバイスを準備

いつも通り、[Nerves]で作ったファームウエアを焼いた micoSD カードが挿入されたデバイスを起動します。

ターミナルを開きます。

`ping`コマンドでネットワーク接続を確認します。

```bash
mnishiguchi@thinkpad:~
$ ping -c3 nerves-9bd5.local
PING nerves-9bd5.local (172.31.224.217) 56(84) bytes of data.
64 bytes from 172.31.224.217 (172.31.224.217): icmp_seq=1 ttl=64 time=0.292 ms
64 bytes from 172.31.224.217 (172.31.224.217): icmp_seq=2 ttl=64 time=0.291 ms
64 bytes from 172.31.224.217 (172.31.224.217): icmp_seq=3 ttl=64 time=0.246 ms

--- nerves-9bd5.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.246/0.276/0.292/0.021 ms
```

SSH 接続してみます。

```bash
mnishiguchi@thinkpad:~
$ ssh nerves-9bd5.local
Nerves Livebook
https://github.com/nerves-livebook/nerves_livebook

ssh livebook@nerves-9bd5.local # Use password "nerves"

(mnishiguchi@nerves-9bd5.local) Password:
Interactive Elixir (1.17.2) - press Ctrl+C to exit (type h() ENTER for help)
████▄▄    ▐███
█▌  ▀▀██▄▄  ▐█
█▌  ▄▄  ▀▀  ▐█   N  E  R  V  E  S
█▌  ▀▀██▄▄  ▐█
███▌    ▀▀████
nerves_livebook 0.13.0 (a623fa83-b771-5029-b281-acb8d205aea5) arm rpi4
  Serial       : 100000007e279bd5
  Uptime       : 29 minutes and 35 seconds
  Clock        : 2024-07-11 23:18:19 UTC (unsynchronized)
  Temperature  : 63.8°C

  Firmware     : Valid (B)               Applications : 111 started
  Memory usage : 209 MB (3%)             Part usage   : 288 MB (2%)
  Hostname     : nerves-9bd5             Load average : 0.05 0.06 0.04

  usb0         : 172.31.224.217/30, fe80::c082:b7ff:fe10:409b/64

Nerves CLI help: https://hexdocs.pm/nerves/iex-with-nerves.html

Toolshed imported. Run h(Toolshed) for more info.
iex(livebook@nerves-9bd5.local)1>
```

### Nerves のストレージをホストの PC にマウントする

Nerves に SSH 接続したターミナルとは別に、新しいターミナルを開きます。

ホストの PC 上にマウントポイントとして任意の名前のディレクトリを作成し、そこへ Nerves デバイス上のディレクトリをマウントします。

例としてここでは `/tmp/nerves-sshfs/`をマウントポイントとします。

```bash
mnishiguchi@thinkpad:~
$ mkdir -p /tmp/nerves-sshfs
```

そしてそのディレクトリに Nerves デバイスの読み書き可能ストレージである `/root` をマウントします。

```bash
mnishiguchi@thinkpad:~
$ sshfs nerves-9bd5.local:/root /tmp/nerves-sshfs
(mnishiguchi@nerves-9bd5.local) Password:
```

マウントポイントの中身を見てみると、Nerves デバイス上の`/root`にあるファイルが入っています。

```bash
mnishiguchi@thinkpad:~
$ ls /tmp/nerves-sshfs/
livebook/  nerves_ssh/  seedrng/  vintage_net/  last_shutdown.txt
```

### 試しにファイル操作をしてみる

Nerves デバイスのターミナルで`/root`の中身を確認します。

```bash:Nerves
iex(livebook@nerves-9bd5.local)1> cmd "ls /root"
last_shutdown.txt
vintage_net
seedrng
livebook
nerves_ssh
0
```

ホスト側のマウントポイントで新しいファイルを作成してみます。

```bash
mnishiguchi@thinkpad:~
$ echo "元氣ですかーーーーッ！！！" > /tmp/nerves-sshfs/hello.txt
```

Nerves 側で`/root`の中身を再度確認すると新しく作ったファイルが入っています！

```bash:Nerves
iex(livebook@nerves-9bd5.local)2> cmd "ls /root"
hello.txt #<--- これ
last_shutdown.txt
vintage_net
seedrng
livebook
nerves_ssh
0

iex(livebook@nerves-9bd5.local)3> cat "/data/hello.txt"
元氣ですかーーーーッ！！！
```

### アンマウント

リモートのファイルシステムの使用が完了したら、`fusermount` コマンドでアンマウントします。

```bash
mnishiguchi@thinkpad:~
$ fusermount -u /tmp/nerves-sshfs

mnishiguchi@thinkpad:~
$ ls /tmp/nerves-sshfs/
```

:tada::tada::tada:
