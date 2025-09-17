# Password Policy Plugin v2.1.2 發布說明

## 🎉 重要更新

**發布日期**: 2025-09-17  
**版本**: v2.1.2  
**類型**: 重要修復版本

## 🐛 主要修復

### 1. 修復密碼驗證器載入問題
- **問題**: 密碼驗證器沒有正確載入到 User 模型中
- **影響**: 導致密碼驗證功能完全失效
- **修復**: 改進插件初始化機制，確保驗證器正確載入

### 2. 增強鍵盤模式檢測
- **新增模式**: 添加更多跨行鍵盤模式檢測
- **改進算法**: 擴展檢測範圍從 3-6 字符到 3-8 字符
- **新增模式**: `qaz2wsx3edc`, `qaz2wsx3edc4`, `wsx3edc4rfv` 等

### 3. 修復連續鍵盤密碼攔截
- **問題**: 像 `!QAZ2wsx3edc` 這樣的鍵盤模式密碼沒有被攔截
- **修復**: 現在能夠正確檢測和攔截各種鍵盤位置模式

## ✅ 測試結果

所有以下密碼現在都能被正確攔截：

| 密碼 | 匹配模式 | 結果 |
|------|----------|------|
| `!QAZ2wsx3edc` | `qaz2wsx3edc`, `qaz2wsx3`, `2wsx3edc` | ❌ 被攔截 |
| `%TGByhnujm` | `yhnujm` | ❌ 被攔截 |
| `#EDC$RFVtgb` | `edc`, `rfv`, `tgb` | ❌ 被攔截 |
| `！QAZedc%TGB` | `qaz`, `edc`, `tgb`, `qazedc` | ❌ 被攔截 |
| `$RFV%TGBujm` | `tgb`, `ujm`, `tgbujm` | ❌ 被攔截 |
| `#EDC%TGBik` | `edc`, `tgb`, `ik`, `tgbik` | ❌ 被攔截 |
| `！QAZwsxedc` | `qaz`, `wsx`, `edc`, `qazwsx`, `wsxedc`, `qazwsxedc` | ❌ 被攔截 |

## 🔧 技術改進

### 1. 插件初始化機制
```ruby
# 改進前
Rails.configuration.to_prepare do
  initialize_password_policy_plugin
end

# 改進後
Rails.configuration.to_prepare do
  initialize_password_policy_plugin
end

# 確保在應用程式啟動時也執行初始化
Rails.application.config.after_initialize do
  initialize_password_policy_plugin
end
```

### 2. 驗證器載入邏輯
```ruby
# 改進前
User.class_eval do
  validates :password, password: true, if: :password_required?
end

# 改進後
User.class_eval do
  # 移除現有的密碼驗證器（如果存在）
  _validators[:password]&.reject! { |v| v.class.name == 'PasswordValidator' }
  
  # 添加新的密碼驗證器
  validates :password, password: true, if: :password_required?
end
```

### 3. 鍵盤模式檢測
- 新增跨行鍵盤模式：`qaz2wsx3edc`, `qaz2wsx3edc4` 等
- 擴展動態檢測範圍：3-8 字符
- 改進模式匹配邏輯

## 📊 性能優化

- 預編譯正則表達式
- 靜態常數定義
- 高效的字符串匹配算法
- 詳細的日誌記錄

## 🛡️ 安全性提升

現在能夠有效攔截：
- 跨行鍵盤模式（如 `qaz2wsx3edc`）
- 單行連續模式（如 `qwerty`, `asdfgh`）
- 數字鍵盤模式（如 `147258`）
- 特殊字符鍵盤模式（如 `!@#`）
- 混合鍵盤模式（如 `1qaz2wsx`）

## 📋 安裝說明

1. 下載最新版本
2. 解壓縮到 `redmine/plugins/password_policy` 目錄
3. 重新啟動 Redmine 服務
4. 在管理介面中啟用插件

## 🔄 升級說明

如果您正在使用 v2.1.1 或更早版本：

1. 備份當前插件
2. 下載 v2.1.2
3. 替換插件文件
4. 重新啟動 Redmine
5. 檢查插件設定

## 🐛 已知問題

無已知問題

## 📞 支援

如果您遇到任何問題，請：
1. 查看 [FIXES_SUMMARY.md](FIXES_SUMMARY.md) 了解詳細修復內容
2. 查看 [SECURITY.md](SECURITY.md) 了解安全相關信息
3. 在 GitHub 上提交 Issue

## 🙏 致謝

感謝所有測試和回報問題的用戶！

---

**由 [Jason Liu (bluer1211)](https://github.com/bluer1211) 開發與維護**
