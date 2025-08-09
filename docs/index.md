# Redmine Password Policy Plugin

[![Redmine Version](https://img.shields.io/badge/Redmine-6.0.6+-red.svg)](https://redmine.org)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.0+-blue.svg)](https://ruby-lang.org)
[![Rails Version](https://img.shields.io/badge/Rails-6.0+-green.svg)](https://rubyonrails.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/releases)
[![GitHub stars](https://img.shields.io/github/stars/bluer1211/redmine-password-policy-plugin.svg)](https://github.com/bluer1211/redmine-password-policy-plugin/stargazers)

## 🎯 概述

這個插件為 Redmine 6.0.6+ 提供強大的密碼政策功能，幫助管理員強制執行安全的密碼規則，避免帳號遭有心人士不當使用。

## 🚀 快速開始

### 安裝

```bash
cd redmine/plugins
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy
```

### 配置

1. 登入 Redmine 管理員帳號
2. 進入「管理」→「設定」→「插件」
3. 找到「Password Policy Plugin」並啟用
4. 點擊「配置」設定密碼規則

## ✨ 主要功能

- **密碼長度限制**：可設定最小密碼長度（預設 8 字符）
- **字符類型要求**：大寫字母、小寫字母、數字、特殊字符
- **安全防護**：防止常見密碼、連續字符、鍵盤模式、重複字符
- **多語言支援**：繁體中文和英文

## 📚 文檔

- [安裝指南](installation.md)
- [配置說明](configuration.md)
- [安全指南](security.md)
- [貢獻指南](contributing.md)

## 🤝 貢獻

我們歡迎所有形式的貢獻！請查看 [貢獻指南](contributing.md) 了解詳情。

## 📄 授權

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 文件。

---

**由 [Jason Liu (bluer1211)](https://github.com/bluer1211) 開發與維護**
