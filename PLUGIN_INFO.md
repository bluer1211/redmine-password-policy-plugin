# Redmine Password Policy Plugin

## 插件信息

- **名稱**: Password Policy Plugin
- **版本**: 2.0.0
- **作者**: Jason Liu (bluer1211)
- **授權**: MIT
- **GitHub**: https://github.com/bluer1211/redmine-password-policy-plugin
- **支援的 Redmine 版本**: 6.0.6+

## 功能描述

這個插件為 Redmine 提供強大的密碼政策功能，幫助管理員強制執行安全的密碼規則。

### 主要功能

1. **密碼長度限制**：可設定最小密碼長度
2. **字符類型要求**：大寫字母、小寫字母、數字、特殊字符
3. **安全防護**：
   - 防止常見密碼
   - 防止連續字符
   - 防止鍵盤模式
   - 防止重複字符
4. **多語言支援**：繁體中文和英文

## 安裝方法

```bash
cd redmine/plugins
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy
```

## 配置

1. 登入 Redmine 管理員帳號
2. 進入「管理」→「設定」→「插件」
3. 找到「Password Policy Plugin」並啟用
4. 點擊「配置」設定密碼規則

## 系統需求

- Redmine 6.0.0+
- Ruby 3.0+
- Rails 6.0+

## 授權

MIT License - 詳見 [LICENSE](LICENSE) 文件
