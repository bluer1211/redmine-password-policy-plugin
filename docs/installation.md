# 安裝指南

## 系統需求

- **Redmine 6.0.0** 或更高版本 (推薦 6.0.6)
- **Ruby 3.0** 或更高版本 (推薦 3.3.9)
- **Rails 6.0** 或更高版本 (推薦 7.2.2.1)

## 安裝方法

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

## 驗證安裝

1. **檢查插件狀態**
   - 前往「管理」→「設定」→「插件」
   - 確認「Password Policy Plugin」顯示為「已啟用」

2. **測試密碼政策**
   - 嘗試創建新用戶或修改現有用戶密碼
   - 使用弱密碼（如 `password123`）測試驗證功能

## 故障排除

### 常見問題

1. **插件無法載入**
   - 檢查 Redmine 版本是否支援
   - 確認 Ruby 和 Rails 版本
   - 查看 Redmine 日誌文件

2. **密碼驗證不生效**
   - 確認插件已啟用
   - 檢查設定是否正確
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

## 下一步

安裝完成後，請查看 [配置說明](configuration.md) 了解如何設定密碼政策。
