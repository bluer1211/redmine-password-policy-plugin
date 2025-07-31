# 密碼政策插件測試指南

## 🧪 測試目的

本指南幫助您測試密碼政策插件的各項功能，特別是驗證錯誤訊息是否正確顯示繁體中文。

## 🔧 測試前準備

1. **確認插件已啟用**：
   - 登入 Redmine 管理員帳號
   - 進入「管理」→「設定」→「插件」
   - 確認「Password Policy Plugin」已啟用

2. **配置插件設定**：
   - 點擊「Password Policy Plugin」的「配置」
   - 啟用所有密碼檢查選項
   - 點擊「儲存」

## 📋 測試案例

### 1. 測試密碼長度要求

**測試密碼**：`short`
**預期結果**：顯示繁體中文錯誤訊息「密碼長度不足，至少需要 8 個字符」

**測試步驟**：
1. 進入「管理」→「用戶」
2. 點擊「新增用戶」
3. 填寫用戶資訊，密碼設為 `short`
4. 點擊「建立」
5. 檢查錯誤訊息

### 2. 測試大寫字母要求

**測試密碼**：`mypassword123`
**預期結果**：顯示繁體中文錯誤訊息「密碼必須包含至少一個大寫字母」

**測試步驟**：
1. 新增用戶或修改現有用戶密碼
2. 使用密碼 `mypassword123`
3. 檢查錯誤訊息

### 3. 測試小寫字母要求

**測試密碼**：`MYPASSWORD123`
**預期結果**：顯示繁體中文錯誤訊息「密碼必須包含至少一個小寫字母」

### 4. 測試數字要求

**測試密碼**：`MyPassword`
**預期結果**：顯示繁體中文錯誤訊息「密碼必須包含至少一個數字」

### 5. 測試特殊字符要求

**測試密碼**：`MyPassword123`
**預期結果**：顯示繁體中文錯誤訊息「密碼必須包含至少一個特殊字符」

### 6. 測試常見密碼阻止

**測試密碼**：`password`
**預期結果**：顯示繁體中文錯誤訊息「不能使用常見的密碼」

### 7. 測試連續字符阻止

**測試密碼**：`MyPass123456`
**預期結果**：顯示繁體中文錯誤訊息「密碼不能包含連續字符（如123456、abcdef等）」

### 8. 測試鍵盤模式阻止 ⭐

**測試密碼**：`MyPass1qaz2wsx`
**預期結果**：顯示繁體中文錯誤訊息「密碼不能包含連續鍵盤位置字符（如1qaz2wsx、#EDC$RFV等）」

**其他鍵盤模式測試**：
- `MyPass@wsx#edc` - 特殊字符鍵盤模式
- `MyPass!@#$%^&*()` - 特殊字符順序
- `MyPassq1w2e3r4` - 字母數字交替模式

### 9. 測試重複字符阻止

**測試密碼**：`MyPassaaa123`
**預期結果**：顯示繁體中文錯誤訊息「密碼不能包含重複字符（如aaa、111等）」

## ✅ 正確的錯誤訊息範例

### 繁體中文錯誤訊息
```
密碼長度不足，至少需要 8 個字符
密碼必須包含至少一個大寫字母
密碼必須包含至少一個小寫字母
密碼必須包含至少一個數字
密碼必須包含至少一個特殊字符
密碼不能包含連續字符（如123456、abcdef等）
密碼不能包含連續鍵盤位置字符（如1qaz2wsx、#EDC$RFV等）
密碼不能包含重複字符（如aaa、111等）
不能使用常見的密碼
```

### 英文錯誤訊息
```
Password is too short (minimum is 8 characters)
Password must contain at least one uppercase letter
Password must contain at least one lowercase letter
Password must contain at least one number
Password must contain at least one special character
Password cannot contain sequential characters (e.g., 123456, abcdef)
Password cannot contain keyboard pattern characters (e.g., 1qaz2wsx, #EDC$RFV)
Password cannot contain repetitive characters (e.g., aaa, 111)
Cannot use common passwords
```

## 🚨 問題排查

### 如果錯誤訊息顯示英文或 "translation missing"

1. **檢查語言設定**：
   - 確認 Redmine 語言設定為「繁體中文」
   - 進入「我的帳號」→「偏好設定」→「語言」

2. **重新啟動 Redmine**：
   ```bash
   docker-compose restart redmine
   ```

3. **清除瀏覽器快取**：
   - 按 Ctrl+F5 強制重新載入頁面
   - 或清除瀏覽器快取和 Cookie

4. **檢查語言文件**：
   - 確認 `config/locales/zh-TW.yml` 文件存在
   - 確認翻譯鍵路徑正確

### 如果插件功能不工作

1. **檢查插件設定**：
   - 確認所有檢查選項都已啟用
   - 確認設定已儲存

2. **檢查日誌**：
   ```bash
   docker-compose logs redmine --tail=20
   ```

3. **重新安裝插件**：
   - 刪除插件目錄
   - 重新複製插件文件
   - 重啟 Redmine

## 🎯 成功測試的標誌

✅ **所有錯誤訊息都顯示繁體中文**
✅ **沒有 "translation missing" 錯誤**
✅ **密碼驗證功能正常工作**
✅ **設定頁面顯示正確**

## 📞 支援

如果測試中遇到問題：

1. 檢查 Redmine 日誌文件
2. 確認插件設定是否正確
3. 參考 `INSTALLATION.md` 和 `KEYBOARD_PATTERNS.md` 文件
4. 確認所有文件都已正確更新

---

**完成所有測試後，您的密碼政策插件就完全正常工作了！** 🎉 