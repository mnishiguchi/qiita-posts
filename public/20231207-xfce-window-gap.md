---
title: Xfceのウインドウの端の変な隙間をなくす
tags:
  - Linux
  - archLinux
  - Xfce
  - 変な隙間
private: false
updated_at: '2023-12-08T11:54:07+09:00'
id: de4741551637d61867e1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

[Xfce]デスクトップ環境がシンプルで動作が早いので気に入っており、特に大きなカスタマイズをせずに使っています。

ただ、一つだけ気になっていたことがありました。それがウインドウの右端と下の小さな隙間です。このくらい目を瞑ろうかとほったらかしにしてましたが、やっぱり変なので直そうと思います。

![xfce-window-gap 2023-12-07 20-40-36--1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/bf41629c-01aa-a667-b3f6-0f6668354192.png)

ネットで調べてみると、関連の情報はあまりありませんでしたが、同じ問題に悩んでいる人はいました。

https://forum.xfce.org/viewtopic.php?pid=66277

## 直し方

まずは、念のために「Settings Manager > Workspaces > Margins」のマージンの設定が全てゼロであることを確認します。

![settings-workspaces-margins 2023-12-07 21-12-05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/1cac823d-a819-876b-eaa9-e2ada612a2cb.png)

僕の場合は、全てゼロになってました。

次に、`$HOME/.config/gtk-3.0/gtk.css`を作り、以下の内容を追加し、ログアウトまたはリブートします。

```css:$HOME/.config/gtk-3.0/gtk.css
VteTerminal, vte-terminal {
  padding-left: 4px; padding-right: 4px;
  padding-top: 6px; padding-bottom: 6px;
}
```

僕の環境では、以下のコマンドでディスプレイマネージャ（[lightdm]）を再起動しました。

```
sudo systemctl restart lightdm
```

これで直りました。場合によってはピクセルの値を調整する必要があるそうです。

![xfce-window-gap--fixed 2023-12-07 20-41-41.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/4f4dc2e2-6a18-527d-7631-109af2b453ee.png)

## 原因

よくわかりませんが、こう説明している方がいました。

> The xfce4-terminal window size is dependent on the geometry of the font size and dimensions of the window. This works differently than windows like thunar or mousepad that are sized based on pixel dimensions.

[xfce4-terminal]のウィンドウ サイズは、フォント サイズの形状とウィンドウの寸法に依存するとのことです。

## さいごに

本記事は [闘魂Elixir #59](https://autoracex.connpass.com/event/300542/) の成果です。ありがとうございます。

https://autoracex.connpass.com/

https://qiita.com/torifukukaiou/items/1edb3e961acf002478fd

![toukon-qiita-macbook_20230912_091808.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/fd5c55ec-4fe0-8af6-59bc-bab1ef3d182b.jpeg)

[Xfce]: https://www.xfce.org/?lang=ja
[lightdm]: https://ja.wikipedia.org/wiki/LightDM
[xfce4-terminal]: https://docs.xfce.org/apps/terminal/start
