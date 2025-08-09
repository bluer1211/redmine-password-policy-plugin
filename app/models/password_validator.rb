class PasswordValidator < ActiveModel::EachValidator
  # 靜態資料定義為類別常數，提升效能
  SEQUENTIAL_PATTERNS = [
    '1234567890', '0987654321', 'abcdefghijklmnopqrstuvwxyz',
    'zyxwvutsrqponmlkjihgfedcba', 'qwertyuiop', 'asdfghjkl',
    'zxcvbnm', '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p'
  ].freeze

  KEYBOARD_PATTERNS = [
    # QWERTY 鍵盤常見模式
    '1qaz2wsx', '2wsx3edc', '3edc4rfv', '4rfv5tgb', '5tgb6yhn', '6yhn7ujm', '7ujm8ik9', '8ik9ol0p',
    'qaz2wsx3', 'wsx3edc4', 'edc4rfv5', 'rfv5tgb6', 'tgb6yhn7', 'yhn7ujm8', 'ujm8ik9o', 'ik9ol0p',
    '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p',
    # 反向模式
    'p0lo9ki8mju7nhy6bgt5vfr4cde3xsw2zaq1',
    '0p9o8i7u6y5t4r3e2w1q',
    # 數字鍵盤模式
    '123456789', '987654321',
    # 特殊字符鍵盤模式
    '!qaz@wsx#edc$rfv%tgb^yhn&ujm*ik(ol)p',
    '!@#$%^&*()',
    ')(*&^%$#@!',
    # 混合模式
    '1qaz@wsx#edc$rfv%tgb^yhn&ujm*ik(ol)p',
    'q1w2e3r4t5y6u7i8o9p0',
    'p0o9i8u7y6t5r4e3w2q1'
  ].freeze

  COMMON_PASSWORDS = [
    'password', '123456', '123456789', 'qwerty', 'abc123',
    'password123', 'admin', 'letmein', 'welcome', 'monkey',
    'redmine', 'redmine123', 'admin123', 'user123', 'test123'
  ].freeze

  # 定義特殊字符列表，更精確的驗證
  SPECIAL_CHARS = %w[! @ # $ % ^ & * ( ) _ + - = [ ] { } ; ' : " \ | , . < > / ?].freeze

  def validate_each(record, attribute, value)
    return if value.blank?
    
    begin
      # 安全性檢查：確保輸入是字串
      value = value.to_s.strip
      
      # 檢查輸入長度限制（防止過長輸入）
      if value.length > 1000
        record.errors.add(attribute, :too_long, count: 1000)
        return
      end
      
      settings = Setting.plugin_password_policy
      return unless settings # 如果沒有設定，跳過驗證
      
      # 檢查最小長度
      if settings['min_length'].to_i > 0 && value.length < settings['min_length'].to_i
        record.errors.add(attribute, :too_short, count: settings['min_length'])
      end
      
      # 檢查大寫字母
      if settings['require_uppercase'] && !value.match(/[A-Z]/)
        record.errors.add(attribute, :must_contain_uppercase)
      end
      
      # 檢查小寫字母
      if settings['require_lowercase'] && !value.match(/[a-z]/)
        record.errors.add(attribute, :must_contain_lowercase)
      end
      
      # 檢查數字
      if settings['require_numbers'] && !value.match(/\d/)
        record.errors.add(attribute, :must_contain_numbers)
      end
      
      # 檢查特殊字符（使用更精確的驗證）
      if settings['require_special_chars'] && !SPECIAL_CHARS.any? { |char| value.include?(char) }
        record.errors.add(attribute, :must_contain_special_chars)
      end
      
      # 檢查連續字符
      if settings['prevent_sequential_chars']
        SEQUENTIAL_PATTERNS.each do |pattern|
          if value.downcase.include?(pattern.downcase)
            record.errors.add(attribute, :contains_sequential_chars)
            break
          end
        end
      end
      
      # 檢查連續鍵盤位置字符
      if settings['prevent_keyboard_patterns']
        KEYBOARD_PATTERNS.each do |pattern|
          if value.downcase.include?(pattern.downcase)
            record.errors.add(attribute, :contains_keyboard_patterns)
            break
          end
        end
      end
      
      # 檢查重複字符
      if settings['prevent_repetitive_chars']
        if value.match(/(.)\1{2,}/)
          record.errors.add(attribute, :contains_repetitive_chars)
        end
      end
      
      # 檢查常見密碼
      if settings['prevent_common_passwords']
        if COMMON_PASSWORDS.include?(value.downcase)
          record.errors.add(attribute, :is_common_password)
        end
      end
      
    rescue => e
      Rails.logger.error "Password validation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      record.errors.add(attribute, :validation_error)
    end
  end

  # 計算密碼強度（1-5級）
  def self.calculate_password_strength(password)
    return 0 if password.blank?
    
    strength = 0
    
    # 長度檢查
    strength += 1 if password.length >= 8
    strength += 1 if password.length >= 12
    
    # 字符類型檢查
    strength += 1 if password.match(/[A-Z]/)  # 大寫字母
    strength += 1 if password.match(/[a-z]/)  # 小寫字母
    strength += 1 if password.match(/\d/)     # 數字
    strength += 1 if SPECIAL_CHARS.any? { |char| password.include?(char) }  # 特殊字符
    
    # 額外安全檢查
    strength += 1 if password.length >= 16 && password.match(/[A-Z]/) && password.match(/[a-z]/) && password.match(/\d/) && SPECIAL_CHARS.any? { |char| password.include?(char) }
    
    [strength, 5].min  # 最高5級
  end

  # 獲取密碼強度描述
  def self.password_strength_description(strength)
    case strength
    when 0..1
      '非常弱'
    when 2
      '弱'
    when 3
      '中等'
    when 4
      '強'
    when 5
      '非常強'
    else
      '未知'
    end
  end
end 