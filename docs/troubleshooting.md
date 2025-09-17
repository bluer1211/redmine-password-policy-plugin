# 故障排除指南

## 常見問題

### 1. 插件無法載入

**症狀：**
- 插件在管理頁面中不顯示
- 日誌中出現錯誤訊息

**可能原因：**
- Redmine 版本不支援
- Ruby 或 Rails 版本不兼容
- 插件文件權限問題

**解決方案：**
```bash
# 檢查 Redmine 版本
bundle exec rails runner "puts Redmine::VERSION"

# 檢查 Ruby 版本
ruby --version

# 檢查 Rails 版本
bundle exec rails runner "puts Rails::VERSION::STRING"

# 檢查文件權限
ls -la plugins/password_policy/

# 重新啟動 Redmine 服務
sudo systemctl restart redmine
```

### 2. 密碼驗證不生效

**症狀：**
- 設定密碼政策後，弱密碼仍然可以通過驗證
- 沒有顯示錯誤訊息

**可能原因：**
- 插件未正確啟用
- 設定未保存
- 快取問題

**解決方案：**
```bash
# 檢查插件是否啟用
bundle exec rails runner "puts Setting.plugin_password_policy.inspect"

# 清除快取
bundle exec rails runner "Rails.cache.clear"

# 重新啟動應用
sudo systemctl restart redmine
```

### 3. 錯誤訊息不顯示

**症狀：**
- 密碼驗證失敗但沒有顯示具體錯誤
- 錯誤訊息顯示為英文

**可能原因：**
- 語言文件未正確載入
- 語言設定問題

**解決方案：**
```bash
# 檢查語言文件
ls -la plugins/password_policy/config/locales/

# 檢查 Redmine 語言設定
bundle exec rails runner "puts Setting.default_language"

# 重新載入語言文件
bundle exec rails runner "I18n.reload!"
```

### 4. 設定頁面無法訪問

**症狀：**
- 點擊插件設定時出現錯誤
- 設定頁面顯示空白

**可能原因：**
- 權限問題
- 模板文件缺失

**解決方案：**
```bash
# 檢查模板文件
ls -la plugins/password_policy/app/views/settings/

# 檢查權限
sudo chown -R redmine:redmine plugins/password_policy/
sudo chmod -R 755 plugins/password_policy/

# 檢查日誌
tail -f /var/log/redmine/production.log
```

### 5. 測試失敗

**症狀：**
- 運行測試時出現錯誤
- 測試覆蓋率不足

**可能原因：**
- 測試環境配置問題
- 依賴項缺失

**解決方案：**
```bash
# 安裝測試依賴
bundle install --with test

# 設置測試資料庫
bundle exec rake db:test:prepare

# 運行測試
bundle exec rake test:plugins:password_policy

# 檢查測試覆蓋率
bundle exec rake test:coverage
```

## 日誌檢查

### 查看 Redmine 日誌

```bash
# 查看生產環境日誌
tail -f /var/log/redmine/production.log

# 查看開發環境日誌
tail -f log/development.log

# 查看測試環境日誌
tail -f log/test.log
```

### 查看插件特定日誌

```bash
# 搜尋插件相關日誌
grep "Password Policy Plugin" /var/log/redmine/production.log

# 搜尋錯誤訊息
grep -i "error\|exception" /var/log/redmine/production.log | grep -i password
```

## 效能問題

### 1. 密碼驗證速度慢

**症狀：**
- 密碼驗證耗時較長
- 用戶體驗不佳

**解決方案：**
```ruby
# 優化驗證邏輯
# 在 password_validator.rb 中使用常數
SPECIAL_CHARS = %w[! @ # $ % ^ & * ( ) _ + - = [ ] { } ; ' : " \ | , . < > / ?].freeze

# 使用更高效的驗證方法
if settings['require_special_chars'] && !SPECIAL_CHARS.any? { |char| value.include?(char) }
  record.errors.add(attribute, :must_contain_special_chars)
end
```

### 2. 記憶體使用過高

**症狀：**
- 系統記憶體使用率過高
- 應用響應緩慢

**解決方案：**
```bash
# 檢查記憶體使用
ps aux | grep redmine

# 優化 Ruby 記憶體設定
export RUBY_GC_HEAP_INIT_SLOTS=1000000
export RUBY_GC_HEAP_FREE_SLOTS=500000
export RUBY_GC_HEAP_GROWTH_FACTOR=1.25
export RUBY_GC_HEAP_GROWTH_MAX_SLOTS=40000000
```

## 安全性問題

### 1. 密碼政策繞過

**症狀：**
- 用戶可以使用不符合政策的密碼
- 驗證邏輯存在漏洞

**解決方案：**
```ruby
# 確保所有驗證規則都正確執行
def validate_each(record, attribute, value)
  return if value.blank?
  
  begin
    # 所有驗證邏輯
    validate_password_strength(record, attribute, value)
  rescue => e
    Rails.logger.error "Password validation error: #{e.message}"
    record.errors.add(attribute, :validation_error)
  end
end
```

### 2. 敏感信息洩露

**症狀：**
- 密碼或設定信息在日誌中洩露
- 錯誤訊息包含敏感信息

**解決方案：**
```ruby
# 避免在日誌中記錄敏感信息
Rails.logger.error "Password validation error occurred" # 不記錄具體密碼

# 使用安全的錯誤訊息
record.errors.add(attribute, :validation_error) # 不包含具體錯誤詳情
```

## 升級問題

### 1. 版本升級後插件不工作

**症狀：**
- 升級 Redmine 後插件無法載入
- 功能異常

**解決方案：**
```bash
# 檢查版本兼容性
bundle exec rails runner "puts 'Redmine: ' + Redmine::VERSION"
bundle exec rails runner "puts 'Rails: ' + Rails::VERSION::STRING"

# 重新安裝插件
cd plugins
rm -rf password_policy
git clone https://github.com/bluer1211/redmine-password-policy-plugin.git password_policy

# 更新依賴
bundle install

# 重新啟動服務
sudo systemctl restart redmine
```

### 2. 設定丟失

**症狀：**
- 升級後插件設定被重置
- 需要重新配置

**解決方案：**
```bash
# 備份設定
bundle exec rails runner "puts Setting.plugin_password_policy.to_json" > password_policy_settings.json

# 恢復設定
bundle exec rails runner "Setting.plugin_password_policy = JSON.parse(File.read('password_policy_settings.json'))"
```

## 開發環境問題

### 1. 開發環境配置

**症狀：**
- 開發環境中插件無法正常工作
- 測試失敗

**解決方案：**
```bash
# 設置開發環境
cp config/database.yml.example config/database.yml

# 創建開發資料庫
bundle exec rake db:create
bundle exec rake db:migrate

# 載入測試數據
bundle exec rake db:test:prepare
```

### 2. 測試環境問題

**症狀：**
- 測試無法運行
- 測試結果不準確

**解決方案：**
```bash
# 設置測試環境
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=test bundle exec rake db:test:prepare

# 運行測試
bundle exec rake test:plugins:password_policy
```

## 聯繫支援

如果以上解決方案都無法解決您的問題，請：

1. **收集信息**：
   - Redmine 版本
   - Ruby 版本
   - Rails 版本
   - 作業系統版本
   - 錯誤日誌

2. **提交 Issue**：
   - 前往 [GitHub Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
   - 提供詳細的問題描述和重現步驟

3. **聯繫開發者**：
   - Email: bluer1211@gmail.com
   - 主題: [TROUBLESHOOTING] 問題描述

## 預防措施

### 1. 定期備份

```bash
# 備份插件設定
bundle exec rails runner "puts Setting.plugin_password_policy.to_json" > backup/password_policy_settings_$(date +%Y%m%d).json

# 備份插件文件
tar -czf backup/password_policy_$(date +%Y%m%d).tar.gz plugins/password_policy/
```

### 2. 監控和日誌

```bash
# 設置日誌輪轉
sudo logrotate -f /etc/logrotate.d/redmine

# 監控插件狀態
bundle exec rails runner "puts 'Plugin status: ' + (Setting.plugin_password_policy ? 'Enabled' : 'Disabled')"
```

### 3. 定期更新

```bash
# 檢查更新
cd plugins/password_policy
git fetch origin
git log HEAD..origin/main --oneline

# 更新插件
git pull origin main
bundle install
sudo systemctl restart redmine
```
