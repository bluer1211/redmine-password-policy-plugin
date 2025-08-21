# Redmine Password Policy Plugin

[![Redmine Version](https://img.shields.io/badge/Redmine-6.0.6+-red.svg)](https://redmine.org)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.0+-blue.svg)](https://ruby-lang.org)
[![Rails Version](https://img.shields.io/badge/Rails-6.0+-green.svg)](https://rubyonrails.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/releases)
[![GitHub stars](https://img.shields.io/github/stars/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/network)
[![GitHub issues](https://img.shields.io/github/issues/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/pulls)

> 🔐 **強大的 Redmine 密碼安全策略插件**  
> 為 Redmine 6.0.6+ 提供企業級密碼安全保護，強制執行安全的密碼規則，防止帳號遭有心人士不當使用。

## 📋 目錄

- [🎯 功能特色](#-功能特色)
- [📋 系統需求](#-系統需求)
- [🚀 安裝方法](#-安裝方法)
- [⚙️ 設定說明](#️-設定說明)
- [🔧 開發指南](#-開發指南)
- [📝 更新日誌](#-更新日誌)
- [🤝 貢獻指南](#-貢獻指南)
- [📄 授權條款](#-授權條款)

## 🎯 功能特色

### ✅ 密碼要求
- **密碼長度限制**：可設定最小密碼長度（預設 8 字符）
- **字符類型要求**：
  - 必須包含大寫字母
  - 必須包含小寫字母
  - 必須包含數字
  - 必須包含特殊字符

### 🛡️ 安全防護
- **防止常見密碼**：禁止使用 `password`、`123456` 等常見弱密碼
- **防止連續字符**：禁止使用 `1234567890`、`abcdef` 等連續字符
- **防止鍵盤模式**：禁止使用 `1qaz2wsx`、`#EDC$RFV` 等鍵盤位置模式
- **防止重複字符**：禁止使用 `aaa`、`111` 等重複字符

### 🌍 多語言支援
- **繁體中文** (`zh-TW`)
- **英文** (`en`)

### 🚀 效能優化
- **預編譯正則表達式**：提升驗證效能
- **靜態常數**：減少記憶體使用
- **高效匹配算法**：優化字符串匹配

### 📊 密碼強度評估
- **1-5級強度評估**：即時密碼強度計算
- **詳細建議**：提供具體的改進建議
- **視覺化顯示**：顏色編碼的強度指示

### 🔧 配置驗證
- **自動配置驗證**：確保設定值在有效範圍內
- **配置清理**：自動修正無效設定
- **詳細錯誤訊息**：提供清晰的錯誤說明

### 🎛️ 啟用控制
- **功能開關**：可選擇啟用或停用密碼政策功能
- **靈活配置**：停用時不會進行密碼驗證
- **即時生效**：設定變更後立即生效

## 📋 系統需求

| 組件 | 最低版本 | 推薦版本 |
|------|----------|----------|
| **Redmine** | 6.0.0 | 6.0.6+ |
| **Ruby** | 3.0 | 3.3.9+ |
| **Rails** | 6.0 | 7.2.2.1+ |

## 🚀 安裝方法

### 方法一：Git 克隆安裝（推薦）

```bash
# 進入 Redmine 插件目錄
cd redmine/plugins

# 克隆插件
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy

# 重新啟動 Redmine 服務
sudo systemctl restart redmine
# 或
sudo service redmine restart
```

### 方法二：手動下載安裝

1. **下載插件**
   - 前往 [Releases](https://github.com/bluer1211/redmine-password-policy-plugin/releases) 頁面
   - 下載最新版本的 ZIP 檔案
   - 解壓縮到 `redmine/plugins/password_policy` 目錄

2. **重新啟動服務**
   ```bash
   sudo systemctl restart redmine
   ```

### 方法三：Docker 安裝

```bash
# 將插件複製到 Docker 容器
docker cp password_policy redmine:/opt/redmine/plugins/

# 重新啟動容器
docker restart redmine
```

## ⚙️ 設定說明

### 基本設定

1. **進入管理員設定**
   - 登入 Redmine 管理員帳號
   - 點擊「管理」→「設定」→「插件」

2. **啟用插件**
   - 找到「Password Policy Plugin」
   - 點擊「啟用」按鈕

3. **配置密碼政策**
   - 點擊「配置」按鈕
   - 設定所需的密碼規則
   - 點擊「儲存」按鈕

### 配置選項說明

| 選項 | 說明 | 預設值 |
|------|------|--------|
| **啟用插件** | 開啟或關閉密碼政策功能 | ✅ 啟用 |
| **最小密碼長度** | 密碼最少字符數 | 8 |
| **要求大寫字母** | 必須包含 A-Z | ✅ 啟用 |
| **要求小寫字母** | 必須包含 a-z | ✅ 啟用 |
| **要求數字** | 必須包含 0-9 | ✅ 啟用 |
| **要求特殊字符** | 必須包含 !@#$%^&* 等 | ✅ 啟用 |
| **防止常見密碼** | 禁止使用常見弱密碼 | ✅ 啟用 |
| **防止連續字符** | 禁止使用連續字符 | ✅ 啟用 |
| **防止鍵盤模式** | 禁止使用鍵盤位置模式 | ✅ 啟用 |
| **防止重複字符** | 禁止使用重複字符 | ✅ 啟用 |

## 🔧 開發指南

### 本地開發環境設置

```bash
# 克隆專案
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git
cd redmine-password-policy-plugin

# 安裝依賴（如果需要）
bundle install

# 運行測試
bundle exec rspec
```

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

### 貢獻代碼

1. Fork 本專案
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📝 更新日誌

### v2.1.0 (2025-08-21)
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

## 🤝 貢獻指南

我們歡迎所有形式的貢獻！請查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解詳細的貢獻指南。

### 貢獻方式

- 🐛 **報告 Bug**：使用 [Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues) 頁面
- 💡 **功能建議**：開啟新的 Issue 或討論
- 🔧 **代碼貢獻**：提交 Pull Request
- 📚 **文檔改進**：更新 README 或文檔
- 🌍 **翻譯協助**：協助多語言翻譯

### 行為準則

本專案遵循 [Code of Conduct](CODE_OF_CONDUCT.md)。參與專案即表示同意遵守這些準則。

## 📄 授權條款

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 文件。

## 🙏 致謝

感謝所有為本專案做出貢獻的開發者和使用者！

---

<div align="center">

**如果這個專案對您有幫助，請給我們一個 ⭐️**

[![GitHub stars](https://img.shields.io/github/stars/bluer1211/redmine-password-policy-plugin.svg?style=social&label=Star)](https://github.com/bluer1211/redmine-password-policy-plugin/stargazers)

</div> 