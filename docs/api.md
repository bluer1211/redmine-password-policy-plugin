# API 文檔

## 概述

Redmine Password Policy Plugin 提供了完整的密碼驗證 API，可以幫助開發者集成密碼政策功能到自己的應用中。

## 核心類別

### PasswordValidator

主要的密碼驗證器類別，繼承自 `ActiveModel::EachValidator`。

#### 類別方法

##### `calculate_password_strength(password)`

計算密碼強度等級（1-5級）。

**參數：**
- `password` (String) - 要計算強度的密碼

**返回值：**
- `Integer` - 密碼強度等級（0-5）

**範例：**
```ruby
strength = PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')
# => 5
```

##### `password_strength_description(strength)`

獲取密碼強度描述。

**參數：**
- `strength` (Integer) - 密碼強度等級

**返回值：**
- `String` - 強度描述

**範例：**
```ruby
description = PasswordValidator.password_strength_description(5)
# => "非常強"
```

#### 實例方法

##### `validate_each(record, attribute, value)`

驗證密碼是否符合政策要求。

**參數：**
- `record` (ActiveRecord::Base) - 要驗證的記錄
- `attribute` (Symbol) - 屬性名稱
- `value` (String) - 密碼值

**範例：**
```ruby
validator = PasswordValidator.new(attributes: [:password])
validator.validate_each(user, :password, 'MyPassword123!')
```

## 配置 API

### 獲取插件設定

```ruby
settings = Setting.plugin_password_policy
```

**返回值：**
```ruby
{
  'min_length' => 8,
  'require_uppercase' => true,
  'require_lowercase' => true,
  'require_numbers' => true,
  'require_special_chars' => true,
  'prevent_common_passwords' => true,
  'prevent_sequential_chars' => true,
  'prevent_keyboard_patterns' => true,
  'prevent_repetitive_chars' => true
}
```

### 更新插件設定

```ruby
Setting.plugin_password_policy = {
  'min_length' => 10,
  'require_uppercase' => true,
  'require_lowercase' => true,
  'require_numbers' => true,
  'require_special_chars' => true,
  'prevent_common_passwords' => true,
  'prevent_sequential_chars' => true,
  'prevent_keyboard_patterns' => true,
  'prevent_repetitive_chars' => true
}
```

## 使用範例

### 基本驗證

```ruby
class User < ActiveRecord::Base
  validates :password, password: true, if: :password_required?
  
  private
  
  def password_required?
    new_record? || password.present?
  end
end
```

### 自定義驗證

```ruby
class CustomPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    # 使用插件設定
    settings = Setting.plugin_password_policy
    return unless settings
    
    # 自定義驗證邏輯
    if settings['min_length'].to_i > 0 && value.length < settings['min_length'].to_i
      record.errors.add(attribute, :too_short, count: settings['min_length'])
    end
  end
end
```

### 密碼強度檢查

```ruby
class PasswordStrengthChecker
  def self.check_strength(password)
    strength = PasswordValidator.calculate_password_strength(password)
    description = PasswordValidator.password_strength_description(strength)
    
    {
      strength: strength,
      description: description,
      is_strong: strength >= 4
    }
  end
end

# 使用範例
result = PasswordStrengthChecker.check_strength('MyS3cur3P@ssw0rd!')
# => { strength: 5, description: "非常強", is_strong: true }
```

## 錯誤訊息

### 錯誤類型

| 錯誤類型 | 描述 | 範例 |
|----------|------|------|
| `too_short` | 密碼長度不足 | "密碼長度不足，至少需要 8 個字符" |
| `too_long` | 密碼長度過長 | "密碼長度過長，最多只能 1000 個字符" |
| `must_contain_uppercase` | 缺少大寫字母 | "密碼必須包含至少一個大寫字母" |
| `must_contain_lowercase` | 缺少小寫字母 | "密碼必須包含至少一個小寫字母" |
| `must_contain_numbers` | 缺少數字 | "密碼必須包含至少一個數字" |
| `must_contain_special_chars` | 缺少特殊字符 | "密碼必須包含至少一個特殊字符" |
| `contains_sequential_chars` | 包含連續字符 | "密碼不能包含連續字符（如123456、abcdef等）" |
| `contains_keyboard_patterns` | 包含鍵盤模式 | "密碼不能包含連續鍵盤位置字符（如1qaz2wsx、#EDC$RFV等）" |
| `contains_repetitive_chars` | 包含重複字符 | "密碼不能包含重複字符（如aaa、111等）" |
| `is_common_password` | 常見密碼 | "不能使用常見的密碼" |
| `validation_error` | 驗證錯誤 | "密碼驗證失敗" |

### 獲取錯誤訊息

```ruby
user = User.new(password: 'weak')
user.valid?

user.errors[:password].each do |error|
  puts error
end
```

## 常數

### 特殊字符列表

```ruby
PasswordValidator::SPECIAL_CHARS
# => ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", "-", "=", "[", "]", "{", "}", ";", "'", ":", "\"", "\\", "|", ",", ".", "<", ">", "/", "?"]
```

### 常見密碼列表

```ruby
PasswordValidator::COMMON_PASSWORDS
# => ["password", "123456", "123456789", "qwerty", "abc123", ...]
```

### 連續字符模式

```ruby
PasswordValidator::SEQUENTIAL_PATTERNS
# => ["1234567890", "0987654321", "abcdefghijklmnopqrstuvwxyz", ...]
```

### 鍵盤模式

```ruby
PasswordValidator::KEYBOARD_PATTERNS
# => ["1qaz2wsx", "2wsx3edc", "3edc4rfv", ...]
```

## 最佳實踐

### 1. 錯誤處理

```ruby
begin
  validator = PasswordValidator.new(attributes: [:password])
  validator.validate_each(user, :password, password)
rescue => e
  Rails.logger.error "Password validation error: #{e.message}"
  user.errors.add(:password, :validation_error)
end
```

### 2. 效能優化

```ruby
# 使用常數而不是重複創建
SPECIAL_CHARS = PasswordValidator::SPECIAL_CHARS

# 快取設定
@password_settings ||= Setting.plugin_password_policy
```

### 3. 測試

```ruby
# 測試密碼強度
def test_password_strength
  assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')
  assert_equal '非常強', PasswordValidator.password_strength_description(5)
end
```

## 版本相容性

- **Redmine 6.0.6+**：完全支援
- **Rails 6.0+**：完全支援
- **Ruby 3.0+**：完全支援

## 支援

如果您在使用 API 時遇到問題，請：

1. 查看 [故障排除指南](troubleshooting.md)
2. 檢查 [GitHub Issues](https://github.com/bluer1211/redmine-password-policy-plugin/issues)
3. 聯繫開發者：bluer1211@gmail.com
