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

這個插件為 Redmine 6.0.6+ 提供強大的密碼政策功能，幫助管理員強制執行安全的密碼規則，避免帳號遭有心人士不當使用。

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

- **Redmine 6.0.0** 或更高版本 (推薦 6.0.6)
- **Ruby 3.0** 或更高版本 (推薦 3.3.9)
- **Rails 6.0** 或更高版本 (推薦 7.2.2.1)

## 🚀 安裝方法

### 方法一：手動安裝

1. **下載插件**
   ```bash
   cd redmine/plugins
   git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy
   ```

2. **重新啟動 Redmine 服務**
   ```bash
   # 重新啟動 Redmine 服務
   sudo systemctl restart redmine
   # 或
   sudo service redmine restart
   ```

3. **啟用插件**
   - 登入 Redmine 管理員帳號
   - 進入「管理」→「設定」→「插件」
   - 找到「Password Policy Plugin」並啟用

### 方法二：Docker 安裝

```bash
# 將插件複製到 Docker 容器
docker cp password_policy redmine:/opt/redmine/plugins/
docker restart redmine
```

## ⚙️ 設定說明

### 基本設定

1. **進入管理員設定**
   - 登入 Redmine 管理員帳號
   - 點擊「管理」→「設定」→「插件」

2. **配置密碼政策**
   - 找到「Password Policy Plugin」
   - 點擊「配置」
   - 設定所需的密碼規則
   - 點擊「儲存」

### 設定選項

| 選項 | 說明 | 預設值 |
|------|------|--------|
| 啟用密碼政策 | 啟用或停用密碼政策功能 | ✓ |
| 最小長度 | 密碼最小字符數 | 8 |
| 必須包含大寫字母 | 強制要求大寫字母 | ✓ |
| 必須包含小寫字母 | 強制要求小寫字母 | ✓ |
| 必須包含數字 | 強制要求數字 | ✓ |
| 必須包含特殊字符 | 強制要求特殊字符 | ✓ |
| 防止使用常見密碼 | 禁止常見弱密碼 | ✓ |
| 防止使用連續字符 | 禁止連續字符 | ✓ |
| 防止使用連續鍵盤位置字符 | 禁止鍵盤模式 | ✓ |
| 防止使用重複字符 | 禁止重複字符 | ✓ |

## 🧪 測試功能

### 測試密碼政策

1. **創建新用戶**
   - 嘗試使用弱密碼（如 `password123`）
   - 系統會顯示相應的錯誤訊息和改進建議

2. **修改現有用戶密碼**
   - 進入用戶設定頁面
   - 嘗試修改為不符合政策的密碼
   - 驗證錯誤訊息是否正確顯示

3. **測試啟用/停用功能**
   - 在設定中停用密碼政策
   - 嘗試使用弱密碼，應該不會有驗證錯誤
   - 重新啟用密碼政策，驗證功能恢復正常

### 測試案例

| 密碼 | 預期結果 | 說明 |
|------|----------|------|
| `MyS3cur3P@ssw0rd!` | ✅ 通過 | 符合所有要求 |
| `password` | ❌ 失敗 | 常見密碼 |
| `123456` | ❌ 失敗 | 連續數字 |
| `1qaz2wsx` | ❌ 失敗 | 鍵盤模式 |
| `aaa` | ❌ 失敗 | 重複字符 |
| `short` | ❌ 失敗 | 長度不足 |

## 📁 插件結構

```
password_policy/
├── init.rb                          # 插件初始化
├── README.md                        # 說明文件
├── LICENSE                          # 授權文件
├── .gitignore                       # Git 忽略文件
├── app/
│   ├── models/
│   │   └── password_validator.rb    # 密碼驗證器
│   └── views/
│       └── settings/
│           └── _password_policy_settings.html.erb  # 設定頁面
├── config/
│   └── locales/                     # 多語言支援
│       ├── en.yml                   # 英文
│       └── zh-TW.yml                # 繁體中文
├── lib/
│   ├── password_policy_hooks.rb     # 鉤子文件
│   └── password_policy_utils.rb     # 工具類別
├── assets/
│   └── stylesheets/
│       └── password_policy.css      # 樣式文件
└── test/                            # 測試文件
    └── unit/
        └── password_validator_test.rb
```

## 🔒 安全特性

- ✅ 管理員權限控制
- ✅ 參數驗證和清理
- ✅ 防止常見安全漏洞
- ✅ 完整的錯誤處理
- ✅ 符合 Redmine 6.0.6 開發規範
- ✅ 輸入長度限制（最多1000字符）
- ✅ 防止 SQL 注入和 XSS 攻擊
- ✅ 詳細的日誌記錄
- ✅ 配置驗證和清理
- ✅ 功能啟用控制

## 🐛 故障排除

### 常見問題

1. **插件無法載入**
   - 檢查 Redmine 版本是否支援
   - 確認 Ruby 和 Rails 版本
   - 查看 Redmine 日誌文件

2. **密碼驗證不生效**
   - 確認插件已啟用
   - 檢查設定是否正確
   - 確認密碼政策功能已啟用
   - 重新啟動 Redmine 服務

3. **錯誤訊息不顯示**
   - 檢查語言設定
   - 確認語言文件是否正確載入

### 日誌檢查

```bash
# 查看 Redmine 日誌
tail -f /var/log/redmine/production.log

# 查看插件載入日誌
grep "Password Policy Plugin" /var/log/redmine/production.log
```

## 📈 版本歷史

### v2.0.0 (2025-08-08)
- ✨ 升級支援 Redmine 6.0.6
- ✨ 支援 Rails 7.2.2.1
- ✨ 支援 Ruby 3.3.9
- ✨ 添加 Rails 6+ 相容性
- ✨ 改善密碼驗證邏輯
- ✨ 優化效能（靜態資料常數化）
- ✨ 增強錯誤處理和日誌記錄
- ✨ 添加輸入長度限制
- ✨ 完善測試覆蓋率
- ✨ 更新語言檔案
- 🚀 **新增功能**：
  - 預編譯正則表達式提升效能
  - 詳細錯誤訊息和改進建議
  - 配置驗證和自動清理
  - 密碼強度評估工具
  - 建議生成器
  - 完整的工具類別
  - **啟用功能開關**：可選擇啟用或停用密碼政策功能

### v1.0.0 (2024-XX-XX)
- 🎉 初始版本
- 🎉 基本密碼政策功能

## 🤝 貢獻指南

我們歡迎所有形式的貢獻！

### 如何貢獻

1. **Fork 專案**
   ```bash
   git clone https://github.com/your-username/redmine-password-policy-plugin.git
   cd redmine-password-policy-plugin
   ```

2. **創建功能分支**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **提交變更**
   ```bash
   git commit -m 'Add some amazing feature'
   ```

4. **推送到分支**
   ```bash
   git push origin feature/amazing-feature
   ```

5. **開啟 Pull Request**

### 開發環境

```bash
# 安裝依賴
bundle install

# 執行測試
bundle exec rake test

# 檢查程式碼風格
bundle exec rubocop
```

## 📄 授權

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 文件。

## 📞 支援

### 取得協助

- 📧 **Email**: bluer1211@gmail.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
- 📖 **Documentation**: [Wiki](https://github.com/bluer1211/redmine-password-policy-plugin/wiki)

### 回報問題

當回報問題時，請包含以下資訊：

1. **環境資訊**
   - Redmine 版本
   - Ruby 版本
   - Rails 版本
   - 作業系統

2. **問題描述**
   - 詳細的錯誤訊息
   - 重現步驟
   - 預期行為

3. **日誌檔案**
   - Redmine 日誌
   - 瀏覽器控制台日誌

## ⭐ 星標專案

如果這個專案對您有幫助，請給我們一個 ⭐ 星標！

---

**由 [Jason Liu (bluer1211)](https://github.com/bluer1211) 開發與維護**

**恭喜！您的 Redmine 現在已經具備了強大的密碼安全保護功能。** 🎊 