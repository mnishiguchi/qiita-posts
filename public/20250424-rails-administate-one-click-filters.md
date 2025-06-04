---
title: Rails×Administrate 管理画面にワンクリック絞り込み機能を実装
tags:
  - Rails
  - 管理画面
  - administrate
private: false
updated_at: '2025-04-24T18:52:09+09:00'
id: 337061b182304e77f693
organization_url_name: haw
slide: false
ignorePublish: false
---
## はじめに

Rails 8 アプリケーションで [Administrate] を使った管理画面を構築しています。開発段階では基本的な CRUD 機能を中心に実装してきましたが、将来的にクライアント自身も管理画面を操作する運用を想定しているため、UX の改善が重要になってきました。

管理者が直感的に操作できるよう、まずは よく使うフィルタ条件をワンクリックで切り替えられる クイックフィルタ機能を導入することにしました。

本記事では、Rails 標準構成と Administrate の仕組みを活かしながら、どう実装したかを記録します。

## なぜ Administrate を選んだか

Rails で管理画面を構築する際にはいくつかの選択肢がありますが、今回のプロジェクトでは最終的に [Administrate] を採用しました。

主な理由は以下の通りです：

- **柔軟性**  
  DSL に過度に依存せず、Rails 標準のコントローラ／ビュー構成のまま自然にカスタマイズできます。

- **可読性・追いやすさ**  
  ソースコード全体が比較的シンプルで、挙動が読みやすく、オーバーライドも容易です。

- **拡張性の高さ**  
  今回紹介するような UI 拡張においても、土台の構造が邪魔をしない点が大きなメリットです。

このような理由から、当初から柔軟な構成を求めていた本プロジェクトにおいては Administrate の選択が自然でした。今後の管理機能拡張や UI 改善を見据えても安心できる構造だと感じています。

他の主要なジェム（ActiveAdmin / RailsAdmin）との比較には、以下の記事が非常に参考になりました。

https://qiita.com/baban/items/f751fb05c4d2367878aa

:::note info
Administrate の雰囲気を確認したい場合は、[公式のデモ管理画面](https://administrate-demo.herokuapp.com/admin)を見るとイメージが掴みやすいです。  
:::

## クイックフィルタを導入する理由

Administrate にも検索機能や基本的なフィルタはありますが、例えば以下のような操作は標準 UI だけでは少し手間がかかります：

- 「未確認ユーザーのみ表示したい」
- 「最近7日間に作成されたデータだけを確認したい」

こういった頻出条件に素早くアクセスする手段として、[ピル型のクイックフィルタ](https://www.google.com/search?q=filter+pills&udm=2)を導入することにしました。

イメージとしては YouTube や GitHub の issue ページなどで見られる、ボタン形式で条件を切り替える UI です。

以下は今回実装したクイックフィルタのイメージです。

![Administrate ダッシュボードに追加したピル型クイックフィルタ](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/82804/89f7427d-8a80-4c35-b13e-085d286c21ca.png)

## 設計方針

クイックフィルタは今後さまざまな管理画面で使えるように、再利用性と保守性を意識して設計しました。以下が主な方針です。

### **1. 拡張性・再利用性**

- `QuickFilterable` concern を導入し、モデル側で `self.quick_filters` とスコープを定義すればすぐに導入可能。
- コントローラとビュー側は共通実装のままで動作する構成にしています。

### **2. 責務の分離**

- **モデル**: スコープとフィルタ判定ロジックを保持  
- **コントローラ**: クエリパラメータに応じたスコープの選択（`Admin::ApplicationController` に集約）  
- **ビュー**: ボタンの表示・状態管理を担当。補助ロジックもその場に記述（ヘルパー未使用）

:::note info
ビュー内のロジックはパーシャルに閉じ込めており、近接配置による可読性と変更容易性を優先しています。
:::

### **3. テスト戦略**

- **リクエストスペック**で、特定のフィルタを選択したときに期待どおりのデータが表示されることを検証。
- UI の切り替えや表示内容の確認は **ブラウザでの手動確認** で対応しています。

## モデル実装：クイックフィルタ用の共通インターフェースの実装

クイックフィルタの仕組みでは、**モデルが持つスコープ**をベースに、共通インターフェースで呼び出せるように設計しました。  
そのための共通モジュールが `QuickFilterable` concern です。

以下はその実装です。

```ruby:app/models/concerns/quick_filterable.rb
# frozen_string_literal: true

# == QuickFilterable
#
# Administrate の一覧画面において、pill 形式の「クイックフィルタ」UI を実現するための共通モジュール。
#
# - 各モデルに `include QuickFilterable` を追加
# - クエリに対応する `scope` を定義
# - UI で表示するフィルタ一覧を `self.quick_filters` で列挙
#
# これにより、コントローラやビューでは共通の仕組みでフィルタ適用が可能になります。
#
# === 使用例:
#
#   class User < ApplicationRecord
#     include QuickFilterable
#
#     scope :unconfirmed, -> { where(confirmed_at: nil) }
#     scope :recent,      -> { where("created_at >= ?", 7.days.ago) }
#
#     self.quick_filters = %i[all unconfirmed recent]
#   end
#
#   User.quick_filter(:recent)  #=> User.recent を呼び出す
#   User.quick_filter(:unknown) #=> 定義されていないので User.all を返す
#
module QuickFilterable
  extend ActiveSupport::Concern

  included do
    # UI に表示するフィルタキーを列挙
    # ※ :all は常に含める（全件表示用）
    class_attribute :quick_filters, default: %i[all]
  end

  class_methods do
    # フィルタキーに応じて該当スコープを呼び出す
    #
    # @param key [String, Symbol, nil]
    # @return [ActiveRecord::Relation]
    def quick_filter(key)
      return all if key.blank? || key.to_s == "all"
      respond_to?(key) ? public_send(key) : all
    end
  end
end
```

実際に `User` モデルにこの concern を導入し、未確認ユーザーを対象とするクイックフィルタを定義してみます。

```ruby:app/models/user.rb
class User < ApplicationRecord
  # クイックフィルタ機能を有効化
  include QuickFilterable

  # 未確認ユーザーのみを取得するスコープ
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  # クイックフィルタに表示するボタンを定義
  # - :all は「すべて表示」
  # - :unconfirmed はスコープに対応するフィルタ
  self.quick_filters = %i[all unconfirmed]
end
```

- `scope :unconfirmed` は `confirmed_at` が未設定のユーザーを抽出します。
- `self.quick_filters` は UI に表示するフィルタボタンの一覧です。並び順も指定できます。

:::note info
この定義を行うだけで、対応する管理画面に「すべて」「未確認」などのフィルタボタンが表示され、選択に応じて絞り込みが自動で適用されるようになります。
:::

## コントローラの拡張

すべてのダッシュボードでクイックフィルタを有効化するため、`Admin::ApplicationController` に共通ロジックを追加します。

```ruby:app/controllers/admin/application_controller.rb
class Admin::ApplicationController < Administrate::ApplicationController
  private

  # == scoped_resource
  #
  # 管理画面の各リソース一覧（index）において表示対象のレコード集合を決定する。
  # 通常は `current_ability` に基づく権限チェックを通じた絞り込みを行うが、
  # さらに `params[:quick_filter]` が指定されていれば、モデルが提供するクイックフィルタも適用する。
  #
  # === 処理の流れ
  #
  # 1. 権限に基づくフィルタリング（CanCanCan）
  # 2. モデルが `quick_filters` を定義していれば、対応するスコープを適用
  #
  # === 例:
  #
  #   GET /admin/users?quick_filter=unconfirmed
  #   → User.unconfirmed が呼ばれる
  #
  def scoped_resource
    resources = resource_class.accessible_by(current_ability)

    if quick_filters.any? && params[:quick_filter].present?
      resources = resources.quick_filter(params[:quick_filter])
    end

    resources
  end

  # == quick_filters
  #
  # モデルが `QuickFilterable` を include し、`quick_filters` を定義している場合に、
  # UI に表示すべきフィルタキーの一覧を返す。
  #
  # モデルが対応していない場合は空配列を返す。
  #
  # === 例:
  #
  #   User.quick_filters → [:all, :unconfirmed]
  #
  def quick_filters
    resource_class.respond_to?(:quick_filters) ? resource_class.quick_filters : []
  end
end
```

こちらがご希望のトーン・構成に合わせて elaboration された「ビューの拡張」セクションの改善案です：

---

## ビューの拡張（ヘッダーにフィルタボタンを追加）

クイックフィルタは、各ダッシュボードの一覧画面に表示されるヘッダーに組み込んでいます。  
これは `Administrate` の `_index_header.html.erb` ビューテンプレートを上書きして対応しました。

### `_index_header.html.erb` の拡張

まず、以下のように `quick_filters` パーシャルを読み込む一行を追加します。

```diff_erb:app/views/admin/application/_index_header.html.erb
 <div class="flex flex-wrap justify-between items-center mb-4">
   <div class="flex gap-4 items-center">
     <%= render "admin/application/search_field" %>
+
+    <% if controller.quick_filters.any? %>
+      <div class="mr-6">
+        <%= render "admin/application/quick_filters" %>
+      </div>
+    <% end %>
   </div>
```

この差分により、対象のモデルが `quick_filters` を定義している場合のみ、対応する pill スタイルのフィルタボタンが表示されるようになります。

:::note info
`Administrate` の `_index_header.html.erb` は [公式 GitHub リポジトリ](https://github.com/thoughtbot/administrate/blob/main/app/views/administrate/application/_index_header.html.erb) で確認できます。  
カスタマイズには `rails generate administrate:views` でビューをローカルにコピーし、必要な変更を加えるのが一般的です。
:::

### クイックフィルタのパーシャル

クイックフィルタは `_quick_filters.html.erb` として共通のパーシャルに実装しました。  
主な役割は：

- I18n ラベルに基づくフィルタボタンの表示  
- 現在のフィルタ状態に応じたスタイルの切り替え  
- クエリパラメータを維持したままのリンク生成  

```erb:app/views/admin/application/_quick_filters.html.erb
<%
  # 既存のクエリパラメータから不要なもの（ページング・既存のフィルタ状態）を除去。
  # これによりフィルタ切り替え時も、他の条件（検索キーワードなど）を保持できる。
  preserved_params = request.query_parameters.except("page", "quick_filter")

  # フィルタボタンのスタイルを決定するロジック。
  # 選択中なら強調表示、それ以外は通常表示。
  button_class = ->(active) {
    base = "px-2 py-0.5 rounded-full border font-medium text-xs"
    active ? "#{base} bg-green-600 text-white" : "#{base} bg-white text-gray-700"
  }

  # フィルタキー（例: :recent, :unconfirmed）に対応するラベルを取得。
  # 翻訳が定義されていない場合は humanize（例: :recent → "Recent"）で代用。
  label_for = ->(key) {
    t("admin.quick_filters.#{key}", default: key.to_s.humanize)
  }
%>

<div class="flex gap-2 overflow-x-auto py-2" role="group" aria-label="<%= t('admin.quick_filters.group_label') %>">
  <% controller.quick_filters.each do |key| %>
    <% active = (params[:quick_filter].to_s == key.to_s) || (key == :all && params[:quick_filter].blank?) %>
    <%= link_to label_for.call(key),
                url_for(preserved_params.merge(quick_filter: (key == :all ? nil : key)).merge(only_path: true)),
                class: button_class.call(active),
                role: "button",
                "aria-pressed": active %>
  <% end %>
</div>
```

- `controller.quick_filters` に列挙されたキーに対し、ボタンをループ生成します。
- アクティブなフィルタは `aria-pressed` 属性と色で強調。
- I18n での多言語ラベルに対応し、グローバル対応も容易です。

### フィルタラベルの定義

ラベル表示は `config/locales/admin.ja.yml` に定義します。  
以下は一例です：

```yaml:config/locales/admin.ja.yml
ja:
  admin:
    quick_filters:
      group_label: "クイックフィルタ"
      all:         "すべて"
      unconfirmed: "未確認"
      recent:      "過去7日"
```

このように、クイックフィルタは最小限の差分で UI に組み込むことができ、  
「特定の条件でのフィルタ表示をすばやく行いたい」というニーズにしっかり応えてくれます。

## 動作確認（リクエストスペック）

```ruby:spec/requests/admin/users_spec.rb
RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :confirmed) { |u| u.add_role(:system_admin) } }
  before { login_as_admin(user: admin) }

  before do
    create(:user, confirmed_at: Time.current, name: "Alice Confirmed")
    create(:user, confirmed_at: nil,         name: "Bob Unconfirmed")
  end

  it "filters by unconfirmed users" do
    get admin_users_path(quick_filter: "unconfirmed")
    expect(response.body).to include("Bob Unconfirmed")
    expect(response.body).not_to include("Alice Confirmed")
  end
end
```

## まとめ

管理画面において、操作性や視認性の良さは利用者の満足度に直結します。  
今回のような「簡易的だがよく使われる機能」は、シンプルな仕組みで追加できると非常に有用です。

本記事で紹介したクイックフィルタは、

- モデルにフィルタスコープと定義
- コントローラで `.quick_filter` を呼び出す
- ビューでピルボタンとしてレンダリング

という構成で、特別な DSL や外部依存なしに簡単に構築できます。

同様の課題に直面している方の参考になれば幸いです。

[Administrate]: https://github.com/thoughtbot/administrate
