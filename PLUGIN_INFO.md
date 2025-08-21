# Redmine Password Policy Plugin

## 📋 插件信息

| 項目 | 內容 |
|------|------|
| **名稱** | Password Policy Plugin |
| **版本** | 2.1.1 |
| **作者** | Jason Liu (bluer1211) |
| **授權** | MIT License |
| **GitHub** | https://github.com/bluer1211/redmine-password-policy-plugin |
| **支援的 Redmine 版本** | 6.0.6+ |
| **支援的 Ruby 版本** | 3.0+ |
| **支援的 Rails 版本** | 6.0+ |

## 🎯 功能描述

這個插件為 Redmine 提供強大的密碼政策功能，幫助管理員強制執行安全的密碼規則，提升系統安全性。

### 主要功能

#### 🔐 密碼驗證
- **密碼長度限制**：可設定最小密碼長度（預設 8 字符）
- **字符類型要求**：
  - 必須包含大寫字母 (A-Z)
  - 必須包含小寫字母 (a-z)
  - 必須包含數字 (0-9)
  - 必須包含特殊字符 (!@#$%^&*等)

#### 🛡️ 安全防護
- **防止常見密碼**：禁止使用 `password`、`123456` 等常見弱密碼
- **防止連續字符**：禁止使用 `1234567890`、`abcdef` 等連續字符
- **防止鍵盤模式**：禁止使用 `1qaz2wsx`、`#EDC$RFV` 等鍵盤位置模式
- **防止重複字符**：禁止使用 `aaa`、`111` 等重複字符

#### 📊 密碼強度評估
- **即時強度計算**：1-5級密碼強度評估
- **詳細改進建議**：提供具體的密碼改進建議
- **視覺化顯示**：顏色編碼的強度指示

#### 🌍 多語言支援
- **繁體中文** (`zh-TW`)
- **英文** (`en`)

## 🚀 安裝方法

### Git 克隆安裝（推薦）

```bash
# 進入 Redmine 插件目錄
cd redmine/plugins

# 克隆插件
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy

# 重新啟動 Redmine 服務
sudo systemctl restart redmine
```

### 手動下載安裝

1. 前往 [Releases](https://github.com/bluer1211/redmine-password-policy-plugin/releases) 頁面
2. 下載最新版本的 ZIP 檔案
3. 解壓縮到 `redmine/plugins/password_policy` 目錄
4. 重新啟動 Redmine 服務

## ⚙️ 配置

### 啟用插件

1. 登入 Redmine 管理員帳號
2. 進入「管理」→「設定」→「插件」
3. 找到「Password Policy Plugin」並啟用

### 配置密碼規則

1. 點擊「配置」按鈕
2. 設定所需的密碼規則：
   - 啟用/停用插件功能
   - 設定最小密碼長度
   - 選擇字符類型要求
   - 啟用安全防護功能
3. 點擊「儲存」按鈕

## 📋 系統需求

| 組件 | 最低版本 | 推薦版本 |
|------|----------|----------|
| **Redmine** | 6.0.0 | 6.0.6+ |
| **Ruby** | 3.0 | 3.3.9+ |
| **Rails** | 6.0 | 7.2.2.1+ |

## 🔧 開發信息

### 專案結構

```
password_policy/
├── app/
│   ├── models/
│   │   └── password_validator.rb      # 密碼驗證器
│   └── views/
│       └── settings/
│           └── _password_policy_settings.html.erb  # 設定頁面
├── lib/
│   ├── password_policy_hooks.rb       # 鉤子系統
│   └── password_policy_utils.rb       # 工具類別
├── test/                              # 測試檔案
├── docs/                              # 文檔
├── config/                            # 配置文件
├── assets/                            # 靜態資源
├── init.rb                            # 插件初始化
├── security_check.rb                  # 安全檢查
└── README.md                          # 說明文檔
```

### 技術特點

- **效能優化**：預編譯正則表達式，靜態常數
- **安全防護**：完整的輸入驗證和清理
- **錯誤處理**：詳細的錯誤訊息和日誌記錄
- **配置驗證**：自動配置驗證和清理
- **模組化設計**：清晰的代碼結構和分離

## 📝 更新日誌

### v2.1.1 (2025-08-21)
- ✨ 新增密碼強度評估功能
- 🔧 改善配置驗證機制
- 🐛 修復多個已知問題
- 📚 更新文檔和說明

### v2.0.0 (2024-12-15)
- 🚀 重構核心驗證邏輯
- 🌍 新增多語言支援
- 🛡️ 增強安全防護功能
- ⚡ 效能優化

### v1.0.0 (2024-11-01)
- 🎉 初始版本發布
- ✅ 基本密碼驗證功能
- 🔧 管理員設定介面

## 🤝 貢獻

我們歡迎所有形式的貢獻！

- 🐛 **報告 Bug**：使用 [Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues) 頁面
- 💡 **功能建議**：開啟新的 Issue 或討論
- 🔧 **代碼貢獻**：提交 Pull Request
- 📚 **文檔改進**：更新文檔

## 📄 授權

MIT License - 詳見 [LICENSE](LICENSE) 文件

---

**由 [Jason Liu (bluer1211)](https://github.com/bluer1211) 開發與維護**
