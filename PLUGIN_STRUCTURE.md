# Redmine 4.1.1 插件開發規範與結構

## 插件目錄結構

```
password_policy/
├── init.rb                          # 插件初始化文件（必需）
├── README.md                        # 插件說明文件
├── PLUGIN_STRUCTURE.md              # 插件結構說明
├── app/                             # 應用程式代碼
│   ├── controllers/                 # 控制器
│   │   └── password_policies_controller.rb
│   ├── models/                      # 模型
│   │   └── password_validator.rb
│   └── views/                       # 視圖模板
│       ├── password_policies/
│       │   └── index.html.erb
│       └── settings/
│           └── _password_policy_settings.html.erb
├── config/                          # 配置文件
│   ├── routes.rb                    # 路由配置
│   └── locales/                     # 語言文件
│       ├── en.yml                   # 英文
│       └── zh-TW.yml                # 繁體中文
├── lib/                             # 庫文件
│   └── password_policy_hooks.rb     # 鉤子文件
├── assets/                          # 靜態資源
│   └── stylesheets/
│       └── password_policy.css
└── test/                            # 測試文件
    ├── test_helper.rb
    └── unit/
        └── password_validator_test.rb
```

## Redmine 4.1.1 插件開發規範

### 1. 初始化文件 (init.rb)

```ruby
require 'redmine'

Redmine::Plugin.register :plugin_name do
  name 'Plugin Name'
  author 'Author Name'
  description 'Plugin description'
  version '1.0.0'
  url 'https://github.com/username/plugin'
  author_url 'https://author-website.com'
  
  # 菜單配置
  menu :admin_menu, :plugin_name, { controller: 'controller_name', action: 'index' }, 
       caption: :label_plugin_name, html: { class: 'icon icon-class' }
  
  # 權限配置
  permission :permission_name, { controller_name: [:action1, :action2] }, require: :admin
  
  # 設定頁面
  settings default: { 'key' => 'value' }, partial: 'settings/plugin_settings'
end

# 載入插件組件
require_dependency 'plugin_hooks'
require_dependency 'plugin_model'

# 初始化
Rails.configuration.to_prepare do
  PluginHooks::Hooks.new.after_plugins_loaded
end
```

### 2. 控制器開發規範

```ruby
class PluginController < ApplicationController
  before_action :require_admin  # 管理員權限檢查
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  
  def index
    # 列表頁面邏輯
  end
  
  def create
    # 創建邏輯
  end
  
  def update
    # 更新邏輯
  end
  
  private
  
  def find_resource
    @resource = Resource.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def resource_params
    params.require(:resource).permit(:param1, :param2)
  end
end
```

### 3. 模型開發規範

```ruby
class PluginModel < ActiveRecord::Base
  # 驗證
  validates :name, presence: true, length: { minimum: 3 }
  
  # 關聯
  belongs_to :user
  has_many :related_models, dependent: :destroy
  
  # 回調
  before_save :do_something
  after_create :notify_users
  
  # 範圍
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  private
  
  def do_something
    # 自定義邏輯
  end
end
```

### 4. 視圖開發規範

```erb
<% html_title l(:label_page_title) %>

<div class="contextual">
  <%= link_to l(:label_new), new_path, class: 'icon icon-add' %>
</div>

<h2><%= l(:label_page_title) %></h2>

<%= form_tag path, method: :post do %>
  <div class="box tabular">
    <p>
      <%= label_tag 'field_name', l(:label_field_name) %>
      <%= text_field_tag 'field_name', @value %>
    </p>
  </div>
  
  <div class="contextual">
    <%= submit_tag l(:button_save), class: 'button-positive' %>
  </div>
<% end %>
```

### 5. 語言文件規範

```yaml
zh-TW:
  label_plugin_name: "插件名稱"
  label_page_title: "頁面標題"
  label_field_name: "欄位名稱"
  button_save: "儲存"
  button_cancel: "取消"
  
  text_help_info: "說明文字"
  
  # 錯誤訊息
  error_message: "錯誤訊息"
  
en:
  label_plugin_name: "Plugin Name"
  label_page_title: "Page Title"
  label_field_name: "Field Name"
  button_save: "Save"
  button_cancel: "Cancel"
  
  text_help_info: "Help information"
  
  # Error messages
  error_message: "Error message"
```

### 6. 路由配置規範

```ruby
RedmineApp::Application.routes.draw do
  resources :plugin_resources, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  
  # 自定義路由
  get 'plugin/custom_action', to: 'plugin#custom_action'
  post 'plugin/custom_action', to: 'plugin#custom_action'
end
```

### 7. 鉤子開發規範

```ruby
module PluginHooks
  class Hooks < Redmine::Hook::ViewListener
    # 視圖鉤子
    def view_layouts_base_html_head(context = {})
      return content_tag('style', File.read(File.join(File.dirname(__FILE__), '../assets/stylesheets/plugin.css')))
    end
    
    # 模型鉤子
    def after_plugins_loaded
      User.class_eval do
        # 擴展用戶模型
        has_many :plugin_models
        
        def custom_method
          # 自定義方法
        end
      end
    end
  end
end
```

### 8. 測試開發規範

```ruby
require File.expand_path('../../test_helper', __FILE__)

class PluginModelTest < ActiveSupport::TestCase
  fixtures :users, :plugin_models
  
  def setup
    @user = User.find(1)
    @model = PluginModel.new
  end
  
  def test_valid_model
    @model.name = "Test Name"
    @model.user = @user
    assert @model.valid?
  end
  
  def test_invalid_model
    assert_not @model.valid?
    assert_includes @model.errors[:name], "can't be blank"
  end
end
```

### 9. 資產文件規範

```css
/* 插件樣式 */
.plugin-class {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 15px;
}

.plugin-class h3 {
  color: #495057;
  margin-top: 0;
}
```

## 重要注意事項

1. **命名規範**：使用小寫字母和下劃線命名插件和文件
2. **權限控制**：所有管理功能都需要適當的權限檢查
3. **國際化**：所有用戶界面文字都應該使用語言文件
4. **錯誤處理**：適當處理異常情況和錯誤訊息
5. **測試覆蓋**：為主要功能編寫測試
6. **文檔完整**：提供完整的安裝和使用說明
7. **版本兼容**：確保與 Redmine 4.1.1 的兼容性
8. **安全考慮**：防止 SQL 注入、XSS 等安全問題

## 部署和安裝

1. 將插件複製到 `redmine/plugins/` 目錄
2. 重啟 Redmine 服務
3. 進入管理員設定頁面啟用插件
4. 配置插件設定

## 調試技巧

1. 檢查 Redmine 日誌文件
2. 使用 `Rails.logger.debug` 輸出調試信息
3. 在開發環境中啟用詳細錯誤頁面
4. 使用瀏覽器開發者工具檢查前端問題 