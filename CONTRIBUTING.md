# 貢獻指南

感謝您對 **Redmine Password Policy Plugin** 的關注！我們歡迎所有形式的貢獻。

## 📋 目錄

- [🚀 快速開始](#-快速開始)
- [🧪 測試](#-測試)
- [📝 程式碼風格](#-程式碼風格)
- [🔄 工作流程](#-工作流程)
- [🐛 回報問題](#-回報問題)
- [💡 功能請求](#-功能請求)
- [🔍 審查流程](#-審查流程)
- [📞 取得協助](#-取得協助)

## 🚀 快速開始

### 前置需求

| 組件 | 版本要求 |
|------|----------|
| **Ruby** | 3.0+ |
| **Rails** | 6.0+ |
| **Redmine** | 6.0.6+ |
| **Git** | 最新版本 |

### 設置開發環境

1. **Fork 專案**
   ```bash
   # 克隆您的 Fork
   git clone https://github.com/your-username/redmine-password-policy-plugin.git
   cd redmine-password-policy-plugin
   
   # 添加上游遠端倉庫
   git remote add upstream https://github.com/bluer1211/redmine-password-policy-plugin.git
   ```

2. **安裝依賴**
   ```bash
   # 安裝 Ruby 依賴
   bundle install
   
   # 如果沒有 Gemfile，則跳過此步驟
   ```

3. **設置測試環境**
   ```bash
   # 複製測試配置（如果存在）
   cp config/database.yml.example config/database.yml 2>/dev/null || echo "No database config needed"
   
   # 設置測試資料庫（如果需要）
   bundle exec rake db:create 2>/dev/null || echo "Database setup skipped"
   bundle exec rake db:migrate 2>/dev/null || echo "Migration skipped"
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

# 如果沒有 Rake，直接執行測試文件
ruby test/unit/password_validator_test.rb
```

### 測試覆蓋率

我們要求測試覆蓋率至少達到 **80%**。請確保為新功能添加適當的測試。

### 測試最佳實踐

- 為每個新功能編寫測試
- 測試邊界條件和錯誤情況
- 使用描述性的測試名稱
- 保持測試簡潔和可讀

## 📝 程式碼風格

### Ruby 風格指南

我們使用 [RuboCop](https://github.com/rubocop/rubocop) 來確保程式碼風格一致。

```bash
# 檢查程式碼風格
bundle exec rubocop

# 自動修正可修正的問題
bundle exec rubocop -a

# 檢查特定文件
bundle exec rubocop lib/password_policy_utils.rb
```

### 程式碼風格要求

- 使用 2 個空格縮排
- 使用 UTF-8 編碼
- 行長度不超過 120 字符
- 使用有意義的變數和方法名稱
- 添加適當的註釋

### 提交訊息格式

我們使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 提交類型

| 類型 | 說明 | 範例 |
|------|------|------|
| `feat` | 新功能 | `feat: add password strength indicator` |
| `fix` | 錯誤修復 | `fix: resolve validation issue` |
| `docs` | 文檔變更 | `docs: update README installation guide` |
| `style` | 格式變更 | `style: fix indentation in validator` |
| `refactor` | 重構 | `refactor: improve password validation logic` |
| `test` | 測試相關 | `test: add unit tests for new feature` |
| `chore` | 構建工具 | `chore: update dependencies` |

#### 範例提交訊息

```bash
feat: add password strength indicator

- Add visual password strength meter
- Show real-time password validation feedback
- Update UI to display strength level
- Add color-coded strength indicators

Closes #123
```

## 🔄 工作流程

### 1. 創建功能分支

```bash
# 確保主分支是最新的
git checkout main
git pull upstream main

# 創建功能分支
git checkout -b feature/amazing-feature
```

### 2. 進行變更

- 編寫程式碼
- 添加測試
- 更新文檔
- 確保所有測試通過

### 3. 提交變更

```bash
# 添加變更
git add .

# 提交變更
git commit -m "feat: add amazing feature"

# 推送到您的分支
git push origin feature/amazing-feature
```

### 4. 開啟 Pull Request

- 前往 GitHub 並開啟 Pull Request
- 填寫 PR 模板
- 等待審查

## 📋 Pull Request 檢查清單

在提交 PR 之前，請確保：

### 代碼品質
- [ ] 我的程式碼遵循專案的風格指南
- [ ] 我已經自行檢查了我的程式碼
- [ ] 我已經對我的變更進行了評論
- [ ] 我的變更不會產生新的警告

### 測試和文檔
- [ ] 我已經添加了證明我的修復有效或我的功能正常工作的測試
- [ ] 新的和現有的單元測試通過了我的變更
- [ ] 我已經更新了相關文檔
- [ ] 任何相關的變更都已記錄在 README 中

### 安全性
- [ ] 我的變更不會引入安全漏洞
- [ ] 我已經考慮了輸入驗證和清理
- [ ] 我沒有硬編碼敏感信息

## 🐛 回報問題

### 問題模板

當回報問題時，請使用提供的問題模板並包含以下資訊：

#### 環境資訊
```markdown
**Redmine 版本**: 6.0.6
**Ruby 版本**: 3.3.9
**Rails 版本**: 7.2.2.1
**作業系統**: macOS 14.0
**插件版本**: 2.1.0
```

#### 問題描述
```markdown
**問題描述**:
簡潔明瞭地描述問題所在

**重現步驟**:
1. 前往 '...'
2. 點擊 '...'
3. 滾動到 '...'
4. 看到錯誤

**預期行為**:
簡潔明瞭地描述您期望發生什麼

**實際行為**:
簡潔明瞭地描述實際發生什麼
```

#### 日誌檔案
```markdown
**錯誤日誌**:
```
請在此處貼上錯誤日誌
```

**瀏覽器控制台**:
```
請在此處貼上瀏覽器控制台錯誤
```
```

## 💡 功能請求

### 功能請求模板

當提出功能請求時，請使用提供的功能請求模板並包含：

#### 問題描述
```markdown
**問題描述**:
簡潔明瞭地描述問題所在

**解決方案描述**:
簡潔明瞭地描述您希望發生什麼

**替代方案**:
簡潔明瞭地描述您考慮過的任何替代解決方案

**額外資訊**:
在此處添加有關功能請求的任何其他上下文或截圖
```

## 🔍 審查流程

### 審查標準

| 標準 | 說明 |
|------|------|
| **程式碼品質** | 代碼可讀性、結構和最佳實踐 |
| **測試覆蓋率** | 適當的測試覆蓋率和品質 |
| **文檔完整性** | 更新相關文檔和註釋 |
| **安全性考量** | 沒有安全漏洞或風險 |
| **效能影響** | 對系統效能的影響評估 |

### 審查時間

- **初步回應**: 1-2 個工作日
- **完整審查**: 3-5 個工作日
- **合併決策**: 審查完成後 1-2 個工作日

### 審查反饋

我們會提供建設性的反饋，包括：
- 代碼改進建議
- 安全性考量
- 效能優化建議
- 文檔更新建議

## 📞 取得協助

如果您在貢獻過程中遇到任何問題，請：

### 自助資源
1. 檢查 [Wiki](https://github.com/bluer1211/redmine-password-policy-plugin/wiki)
2. 搜尋現有的 [Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
3. 查看 [Discussions](https://github.com/bluer1211/redmine-password-policy-plugin/discussions)

### 聯繫方式
- **Issues**: [GitHub Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bluer1211/redmine-password-policy-plugin/discussions)
- **Email**: bluer1211@gmail.com

## 🎉 認可

所有貢獻者都將在以下地方得到認可：

- 專案的 [README](README.md) 貢獻者列表
- 發布說明中的貢獻者名單
- GitHub 貢獻者頁面

### 貢獻者等級

| 等級 | 條件 | 權限 |
|------|------|------|
| **貢獻者** | 1-5 個 PR | 可以提交 PR |
| **維護者** | 5+ 個 PR | 可以審查和合併 PR |
| **核心維護者** | 長期貢獻 | 可以發布版本 |

---

**感謝您的貢獻！** 🎉

您的貢獻讓這個專案變得更好。無論是報告問題、提出建議還是提交代碼，我們都非常感激您的參與。
