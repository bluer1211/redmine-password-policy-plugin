# 貢獻指南

感謝您對 Redmine Password Policy Plugin 的關注！我們歡迎所有形式的貢獻。

## 🚀 快速開始

### 前置需求

- Ruby 3.0+
- Rails 6.0+
- Redmine 6.0.6+
- Git

### 設置開發環境

1. **Fork 專案**
   ```bash
   git clone https://github.com/your-username/redmine-password-policy-plugin.git
   cd redmine-password-policy-plugin
   ```

2. **安裝依賴**
   ```bash
   bundle install
   ```

3. **設置測試環境**
   ```bash
   # 複製測試配置
   cp config/database.yml.example config/database.yml
   
   # 設置測試資料庫
   bundle exec rake db:create
   bundle exec rake db:migrate
   bundle exec rake db:test:prepare
   ```

## 🧪 測試

### 執行測試

```bash
# 執行所有測試
bundle exec rake test

# 執行特定測試
bundle exec rake test:unit:password_validator_test

# 執行測試並生成覆蓋率報告
bundle exec rake test:coverage
```

### 測試覆蓋率

我們要求測試覆蓋率至少達到 80%。請確保為新功能添加適當的測試。

## 📝 程式碼風格

### Ruby 風格指南

我們使用 [RuboCop](https://github.com/rubocop/rubocop) 來確保程式碼風格一致。

```bash
# 檢查程式碼風格
bundle exec rubocop

# 自動修正可修正的問題
bundle exec rubocop -a
```

### 提交訊息格式

我們使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

類型包括：
- `feat`: 新功能
- `fix`: 錯誤修復
- `docs`: 文檔變更
- `style`: 不影響程式碼含義的變更
- `refactor`: 重構
- `test`: 測試相關變更
- `chore`: 構建過程或輔助工具的變更

### 範例提交訊息

```
feat: add password strength indicator

- Add visual password strength meter
- Show real-time password validation feedback
- Update UI to display strength level

Closes #123
```

## 🔄 工作流程

### 1. 創建功能分支

```bash
git checkout -b feature/amazing-feature
```

### 2. 進行變更

- 編寫程式碼
- 添加測試
- 更新文檔
- 確保所有測試通過

### 3. 提交變更

```bash
git add .
git commit -m "feat: add amazing feature"
```

### 4. 推送到分支

```bash
git push origin feature/amazing-feature
```

### 5. 開啟 Pull Request

- 前往 GitHub 並開啟 Pull Request
- 填寫 PR 模板
- 等待審查

## 📋 Pull Request 檢查清單

在提交 PR 之前，請確保：

- [ ] 我的程式碼遵循專案的風格指南
- [ ] 我已經自行檢查了我的程式碼
- [ ] 我已經對我的變更進行了評論
- [ ] 我已經更新了相關文檔
- [ ] 我的變更不會產生新的警告
- [ ] 我已經添加了證明我的修復有效或我的功能正常工作的測試
- [ ] 新的和現有的單元測試通過了我的變更
- [ ] 任何相關的變更都已記錄在 README 中

## 🐛 回報問題

### 問題模板

當回報問題時，請使用提供的問題模板並包含以下資訊：

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

## 💡 功能請求

### 功能請求模板

當提出功能請求時，請使用提供的功能請求模板並包含：

1. **問題描述**
   - 簡潔明瞭地描述問題所在

2. **解決方案描述**
   - 簡潔明瞭地描述您希望發生什麼

3. **替代方案**
   - 簡潔明瞭地描述您考慮過的任何替代解決方案

## 🔍 審查流程

### 審查標準

- 程式碼品質和可讀性
- 測試覆蓋率
- 文檔完整性
- 安全性考量
- 效能影響

### 審查時間

我們通常在 1-3 個工作日內回應 PR 和問題。

## 📞 取得協助

如果您在貢獻過程中遇到任何問題，請：

1. 檢查 [Wiki](https://github.com/bluer1211/redmine-password-policy-plugin/wiki)
2. 搜尋現有的 [Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
3. 開啟新的 Issue

## 🎉 認可

所有貢獻者都將在專案的 README 和發布說明中得到認可。

感謝您的貢獻！
