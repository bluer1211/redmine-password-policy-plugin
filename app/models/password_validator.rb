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

  # 預編譯正則表達式，提升效能
  UPPERCASE_REGEX = /[A-Z]/.freeze
  LOWERCASE_REGEX = /[a-z]/.freeze
  NUMBERS_REGEX = /\d/.freeze
  REPETITIVE_CHARS_REGEX = /(.)\1{2,}/.freeze

  # 配置驗證常數
  MIN_LENGTH_RANGE = (1..50).freeze
  MAX_LENGTH = 1000

  def validate_each(record, attribute, value)
    return if value.blank?
    
    begin
      # 安全性檢查：確保輸入是字串
      value = value.to_s.strip
      
      # 記錄驗證開始
      Rails.logger.debug "Password validation started for #{record.class.name}##{record.id || 'new'}"
      
      # 檢查輸入長度限制（防止過長輸入）
      if value.length > MAX_LENGTH
        record.errors.add(attribute, :too_long, count: MAX_LENGTH)
        Rails.logger.warn "Password too long (#{value.length} chars) for #{record.class.name}##{record.id || 'new'}"
        return
      end
      
      settings = Setting.plugin_password_policy
      return unless settings # 如果沒有設定，跳過驗證
      
      # 檢查插件是否啟用
      unless settings['enabled']
        Rails.logger.debug "Password Policy Plugin is disabled, skipping validation"
        return
      end
      
      # 驗證設定
      validate_settings(settings)
      
      # 執行驗證檢查
      perform_validations(record, attribute, value, settings)
      
      # 記錄驗證完成
      Rails.logger.info "Password validation completed for #{record.class.name}##{record.id || 'new'}"
      
    rescue => e
      Rails.logger.error "Password validation error for #{record.class.name}##{record.id || 'new'}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      record.errors.add(attribute, :validation_error)
    end
  end

  private

  def validate_settings(settings)
    # 驗證最小長度設定
    min_length = settings['min_length'].to_i
    unless MIN_LENGTH_RANGE.include?(min_length)
      Rails.logger.warn "Invalid min_length setting: #{min_length}, using default: 8"
      settings['min_length'] = 8
    end
  end

  def perform_validations(record, attribute, value, settings)
    # 檢查最小長度
    if settings['min_length'].to_i > 0 && value.length < settings['min_length'].to_i
      record.errors.add(attribute, :too_short, count: settings['min_length'])
      Rails.logger.debug "Password too short (#{value.length} chars) for #{record.class.name}##{record.id || 'new'}"
    end
    
    # 檢查大寫字母
    if settings['require_uppercase'] && !value.match(UPPERCASE_REGEX)
      record.errors.add(attribute, :must_contain_uppercase)
      Rails.logger.debug "Password missing uppercase for #{record.class.name}##{record.id || 'new'}"
    end
    
    # 檢查小寫字母
    if settings['require_lowercase'] && !value.match(LOWERCASE_REGEX)
      record.errors.add(attribute, :must_contain_lowercase)
      Rails.logger.debug "Password missing lowercase for #{record.class.name}##{record.id || 'new'}"
    end
    
    # 檢查數字
    if settings['require_numbers'] && !value.match(NUMBERS_REGEX)
      record.errors.add(attribute, :must_contain_numbers)
      Rails.logger.debug "Password missing numbers for #{record.class.name}##{record.id || 'new'}"
    end
    
    # 檢查特殊字符（使用更精確的驗證）
    if settings['require_special_chars'] && !SPECIAL_CHARS.any? { |char| value.include?(char) }
      record.errors.add(attribute, :must_contain_special_chars)
      Rails.logger.debug "Password missing special characters for #{record.class.name}##{record.id || 'new'}"
    end
    
    # 檢查連續字符（使用更高效的匹配）
    if settings['prevent_sequential_chars']
      if contains_sequential_chars?(value)
        record.errors.add(attribute, :contains_sequential_chars)
        Rails.logger.debug "Password contains sequential characters for #{record.class.name}##{record.id || 'new'}"
      end
    end
    
    # 檢查連續鍵盤位置字符
    if settings['prevent_keyboard_patterns']
      if contains_keyboard_patterns?(value)
        record.errors.add(attribute, :contains_keyboard_patterns)
        Rails.logger.debug "Password contains keyboard patterns for #{record.class.name}##{record.id || 'new'}"
      end
    end
    
    # 檢查重複字符
    if settings['prevent_repetitive_chars']
      if value.match(REPETITIVE_CHARS_REGEX)
        record.errors.add(attribute, :contains_repetitive_chars)
        Rails.logger.debug "Password contains repetitive characters for #{record.class.name}##{record.id || 'new'}"
      end
    end
    
    # 檢查常見密碼
    if settings['prevent_common_passwords']
      if COMMON_PASSWORDS.include?(value.downcase)
        record.errors.add(attribute, :is_common_password)
        Rails.logger.debug "Password is common password for #{record.class.name}##{record.id || 'new'}"
      end
    end
  end

  def contains_sequential_chars?(value)
    value_downcase = value.downcase
    SEQUENTIAL_PATTERNS.any? { |pattern| value_downcase.include?(pattern.downcase) }
  end

  def contains_keyboard_patterns?(value)
    value_downcase = value.downcase
    KEYBOARD_PATTERNS.any? { |pattern| value_downcase.include?(pattern.downcase) }
  end

  # 計算密碼強度（1-5級）
  def self.calculate_password_strength(password)
    return 0 if password.blank?
    
    strength = 0
    
    # 長度檢查
    strength += 1 if password.length >= 8
    strength += 1 if password.length >= 12
    
    # 字符類型檢查
    strength += 1 if password.match(UPPERCASE_REGEX)  # 大寫字母
    strength += 1 if password.match(LOWERCASE_REGEX)  # 小寫字母
    strength += 1 if password.match(NUMBERS_REGEX)     # 數字
    strength += 1 if SPECIAL_CHARS.any? { |char| password.include?(char) }  # 特殊字符
    
    # 額外安全檢查
    strength += 1 if password.length >= 16 && password.match(UPPERCASE_REGEX) && password.match(LOWERCASE_REGEX) && password.match(NUMBERS_REGEX) && SPECIAL_CHARS.any? { |char| password.include?(char) }
    
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

  # 新增：獲取詳細錯誤訊息和改進建議
  def self.detailed_error_message(error_type, value = nil)
    case error_type
    when :too_short
      "密碼長度不足。建議：使用至少8個字符的密碼"
    when :too_long
      "密碼長度過長。建議：使用不超過1000個字符的密碼"
    when :must_contain_uppercase
      "密碼必須包含大寫字母。建議：添加至少一個大寫字母（如A-Z）"
    when :must_contain_lowercase
      "密碼必須包含小寫字母。建議：添加至少一個小寫字母（如a-z）"
    when :must_contain_numbers
      "密碼必須包含數字。建議：添加至少一個數字（如0-9）"
    when :must_contain_special_chars
      "密碼必須包含特殊字符。建議：添加至少一個特殊字符（如!@#$%^&*）"
    when :contains_sequential_chars
      "密碼不能包含連續字符。建議：避免使用123456、abcdef等連續字符"
    when :contains_keyboard_patterns
      "密碼不能包含鍵盤模式。建議：避免使用1qaz2wsx等鍵盤位置模式"
    when :contains_repetitive_chars
      "密碼不能包含重複字符。建議：避免使用aaa、111等重複字符"
    when :is_common_password
      "不能使用常見密碼。建議：選擇更獨特和複雜的密碼"
    else
      "密碼不符合安全要求。建議：使用包含大小寫字母、數字和特殊字符的複雜密碼"
    end
  end
end 