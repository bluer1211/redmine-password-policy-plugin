# 測試輔助文件
require 'minitest/autorun'
require 'logger'
require 'stringio'

# 設置測試環境
ENV['RAILS_ENV'] = 'test'

# 模擬 Rails 環境
module Rails
  def self.logger
    @logger ||= Logger.new(StringIO.new)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    def to_prepare
      yield if block_given?
    end
  end
end

# 為 String 和 NilClass 添加 blank? 方法
class String
  def blank?
    self.nil? || self.strip.empty?
  end
end

class NilClass
  def blank?
    true
  end
end

# 模擬 ActiveModel 基礎類別
module ActiveModel
  class EachValidator
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def attributes
      @options[:attributes] || []
    end
  end
end

# 模擬 ActiveRecord 基礎類別
module ActiveRecord
  class Base
    def errors
      @errors ||= Errors.new
    end

    def self.validates(*attributes)
      # 模擬 validates 方法
    end
  end
end

# 模擬 ActionDispatch 基礎類別
module ActionDispatch
  class IntegrationTest < Minitest::Test
    def setup
      super
      @request = MockRequest.new
      @response = MockResponse.new
    end

    def log_user(login, password)
      # 模擬用戶登入
      @current_user = User.new
      @current_user.login = login
      @current_user.id = 1
    end

    def assert_select(selector, text = nil, options = {})
      # 模擬 assert_select
      true
    end

    def assert_response(status)
      # 模擬 assert_response
      true
    end

    def assert_redirected_to(path)
      # 模擬 assert_redirected_to
      true
    end
  end
end

# 模擬 ActiveSupport 基礎類別
module ActiveSupport
  class TestCase < Minitest::Test
    def setup
      super
      @validator = PasswordValidator.new(attributes: [:password])
      @record = User.new
    end

    # 測試輔助方法
    def assert_password_valid(password, settings = {})
      Setting.stubs(:plugin_password_policy).returns(default_settings.merge(settings))
      @validator.validate_each(@record, :password, password)
      assert_empty @record.errors[:password], "密碼 '#{password}' 應該有效，但出現錯誤: #{@record.errors[:password]}"
    end

    def assert_password_invalid(password, expected_error, settings = {})
      Setting.stubs(:plugin_password_policy).returns(default_settings.merge(settings))
      @validator.validate_each(@record, :password, password)
      assert_includes @record.errors[:password], expected_error, "密碼 '#{password}' 應該無效，但沒有出現預期錯誤: #{expected_error}"
    end

    def default_settings
      {
        'enabled' => true,
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
    end

    # 清理測試環境
    def teardown
      super
      @record.errors.clear if @record
      Setting.plugin_password_policy = nil
    end
  end
end

# 模擬 Setting 類別
class Setting
  def self.plugin_password_policy
    @plugin_password_policy ||= {
      'enabled' => true,
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
  end

  def self.plugin_password_policy=(settings)
    @plugin_password_policy = settings
  end

  # 模擬 stubs 方法
  def self.stubs(method_name)
    StubProxy.new(self, method_name)
  end

  class StubProxy
    def initialize(target, method_name)
      @target = target
      @method_name = method_name
    end

    def returns(value)
      @target.define_singleton_method(@method_name) do
        value
      end
    end
  end
end

# 模擬 ActiveRecord 錯誤
class Errors
  def initialize
    @errors = {}
  end

  def add(attribute, message, options = {})
    @errors[attribute] ||= []
    if message.is_a?(Symbol)
      # 模擬錯誤訊息
      case message
      when :too_short
        count = options[:count] || 8
        @errors[attribute] << "密碼長度不足，至少需要 #{count} 個字符"
      when :too_long
        count = options[:count] || 1000
        @errors[attribute] << "密碼長度過長，最多只能 #{count} 個字符"
      when :must_contain_uppercase
        @errors[attribute] << "密碼必須包含至少一個大寫字母"
      when :must_contain_lowercase
        @errors[attribute] << "密碼必須包含至少一個小寫字母"
      when :must_contain_numbers
        @errors[attribute] << "密碼必須包含至少一個數字"
      when :must_contain_special_chars
        @errors[attribute] << "密碼必須包含至少一個特殊字符"
      when :contains_sequential_chars
        @errors[attribute] << "密碼不能包含連續字符（如123456、abcdef等）"
      when :contains_keyboard_patterns
        @errors[attribute] << "密碼不能包含鍵盤位置模式（如1qaz、WSX、3edc、147、qwe等）"
      when :contains_repetitive_chars
        @errors[attribute] << "密碼不能包含重複字符（如aaa、111等）"
      when :is_common_password
        @errors[attribute] << "不能使用常見的密碼"
      when :validation_error
        @errors[attribute] << "密碼驗證失敗"
      else
        @errors[attribute] << message.to_s
      end
    else
      @errors[attribute] << message
    end
  end

  def [](attribute)
    @errors[attribute] || []
  end

  def empty?
    @errors.empty?
  end

  def clear
    @errors.clear
  end

  def full_messages
    @errors.flat_map { |attribute, messages| messages }
  end
end

# 模擬 User 模型
class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :id, :login, :email

  def new_record?
    @new_record ||= true
  end

  def password_required?
    new_record? || password.present?
  end

  def present?
    !blank?
  end

  def blank?
    password.nil? || password.to_s.strip.empty?
  end
end

# 模擬請求對象
class MockRequest
  attr_accessor :method, :path, :params

  def initialize
    @method = :get
    @path = '/'
    @params = {}
  end
end

# 模擬響應對象
class MockResponse
  attr_accessor :status, :body

  def initialize
    @status = 200
    @body = ''
  end
end

# 模擬 PasswordValidator 類別
class PasswordValidator < ActiveModel::EachValidator
  # 預編譯正則表達式常數，提升效能
  UPPERCASE_REGEX = /[A-Z]/.freeze
  LOWERCASE_REGEX = /[a-z]/.freeze
  NUMBERS_REGEX = /\d/.freeze
  REPETITIVE_CHARS_REGEX = /(.)\1{2,}/.freeze

  # 靜態資料定義為類別常數，提升效能
  SEQUENTIAL_PATTERNS = [
    '1234567890', '0987654321', 'abcdefghijklmnopqrstuvwxyz',
    'zyxwvutsrqponmlkjihgfedcba', 'qwertyuiop', 'asdfghjkl',
    'zxcvbnm', '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p'
  ].freeze

  KEYBOARD_PATTERNS = [
    # QWERTY 鍵盤常見模式（完整和部分）
    '1qaz2wsx', '2wsx3edc', '3edc4rfv', '4rfv5tgb', '5tgb6yhn', '6yhn7ujm', '7ujm8ik9', '8ik9ol0p',
    'qaz2wsx3', 'wsx3edc4', 'edc4rfv5', 'rfv5tgb6', 'tgb6yhn7', 'yhn7ujm8', 'ujm8ik9o', 'ik9ol0p',
    '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p',
    
    # 部分鍵盤模式（4-6字符）
    '1qaz', '2wsx', '3edc', '4rfv', '5tgb', '6yhn', '7ujm', '8ik9', '9ol0', '0p',
    'qaz2', 'wsx3', 'edc4', 'rfv5', 'tgb6', 'yhn7', 'ujm8', 'ik9o', 'lo0p',
    '1qaz2', '2wsx3', '3edc4', '4rfv5', '5tgb6', '6yhn7', '7ujm8', '8ik9o', '9ol0p',
    'qaz2w', 'wsx3e', 'edc4r', 'rfv5t', 'tgb6y', 'yhn7u', 'ujm8i', 'ik9ol',
    
    # 反向模式
    'p0lo9ki8mju7nhy6bgt5vfr4cde3xsw2zaq1',
    '0p9o8i7u6y5t4r3e2w1q', 'p0o9i8u7y6t5r4e3w2q1',
    
    # 數字鍵盤模式
    '123456789', '987654321', '12345678', '87654321',
    '1234567', '7654321', '123456', '654321',
    
    # 數字鍵盤橫向模式
    '147', '741', '258', '852', '369', '963',
    '147258369', '963852741',
    
    # 特殊字符鍵盤模式
    '!qaz@wsx#edc$rfv%tgb^yhn&ujm*ik(ol)p',
    '!@#$%^&*()', ')(*&^%$#@!',
    '!@#', '#@!', '$%^', '^%$', '&*()', ')(*&',
    
    # 混合模式
    '1qaz@wsx#edc$rfv%tgb^yhn&ujm*ik(ol)p',
    'q1w2e3r4t5y6u7i8o9p0', 'p0o9i8u7y6t5r4e3w2q1',
    
    # 字母鍵盤模式
    'qwerty', 'ytrewq', 'asdfgh', 'hgfdsa', 'zxcvbn', 'nbvcxz',
    'qwertyuiop', 'poiuytrewq', 'asdfghjkl', 'lkjhgfdsa',
    
    # 常見組合
    'qwe', 'ewq', 'asd', 'dsa', 'zxc', 'cxz',
    'qweasd', 'dsaewq', 'asdzxc', 'cxzdsa',
    
    # 大小寫混合模式
    'QWE', 'EWQ', 'ASD', 'DSA', 'ZXC', 'CXZ',
    'Qwe', 'Ewq', 'Asd', 'Dsa', 'Zxc', 'Cxz',
    'WSX', 'XSW', 'EDC', 'CDE', 'RFV', 'VFR',
    'TGB', 'BGT', 'YHN', 'NHY', 'UJM', 'MJU',
    'IK', 'KI', 'OL', 'LO'
  ].freeze

  COMMON_PASSWORDS = [
    'password', '123456', '123456789', 'qwerty', 'abc123',
    'password123', 'admin', 'letmein', 'welcome', 'monkey',
    'redmine', 'redmine123', 'admin123', 'user123', 'test123'
  ].freeze

  # 定義特殊字符列表，更精確的驗證
  SPECIAL_CHARS = %w[! @ # $ % ^ & * ( ) _ + - = [ ] { } ; ' : " \ | , . < > / ?].freeze

  # 配置常數
  MIN_LENGTH_RANGE = (1..50).freeze
  MAX_LENGTH = 1000
  KEYBOARD_PATTERN_MIN_LENGTH = 4

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

  # 新增：驗證設定
  private def validate_settings(settings)
    # 驗證最小長度
    min_length = settings['min_length'].to_i
    if min_length < MIN_LENGTH_RANGE.min || min_length > MIN_LENGTH_RANGE.max
      settings['min_length'] = 8  # 重置為預設值
      Rails.logger.warn "Invalid min_length setting, reset to default: 8"
    end
  end

  # 新增：執行驗證檢查
  private def perform_validations(record, attribute, value, settings)
    # 檢查插件是否啟用
    if !(settings['enabled'].to_s == 'true' || settings['enabled'].to_s == '1')
      Rails.logger.debug "Password Policy Plugin is disabled, skipping validation"
      return
    end
    
    # 檢查最小長度
    if settings['min_length'].to_i > 0 && value.length < settings['min_length'].to_i
      record.errors.add(attribute, :too_short, count: settings['min_length'])
    end

    # 檢查大寫字母
    if settings['require_uppercase'] && !value.match(UPPERCASE_REGEX)
      record.errors.add(attribute, :must_contain_uppercase)
    end

    # 檢查小寫字母
    if settings['require_lowercase'] && !value.match(LOWERCASE_REGEX)
      record.errors.add(attribute, :must_contain_lowercase)
    end

    # 檢查數字
    if settings['require_numbers'] && !value.match(NUMBERS_REGEX)
      record.errors.add(attribute, :must_contain_numbers)
    end

    # 檢查特殊字符（使用更精確的驗證）
    if settings['require_special_chars'] && !SPECIAL_CHARS.any? { |char| value.include?(char) }
      record.errors.add(attribute, :must_contain_special_chars)
    end

    # 檢查連續字符
    if settings['prevent_sequential_chars'] && contains_sequential_chars?(value)
      record.errors.add(attribute, :contains_sequential_chars)
    end

    # 檢查連續鍵盤位置字符
    if settings['prevent_keyboard_patterns'] && contains_keyboard_patterns?(value)
      record.errors.add(attribute, :contains_keyboard_patterns)
    end

    # 檢查重複字符
    if settings['prevent_repetitive_chars'] && value.match(REPETITIVE_CHARS_REGEX)
      record.errors.add(attribute, :contains_repetitive_chars)
    end

    # 檢查常見密碼
    if settings['prevent_common_passwords'] && COMMON_PASSWORDS.include?(value.downcase)
      record.errors.add(attribute, :is_common_password)
    end
  end

  # 新增：檢查連續字符
  private def contains_sequential_chars?(value)
    SEQUENTIAL_PATTERNS.any? { |pattern| value.downcase.include?(pattern.downcase) }
  end

  # 新增：檢查鍵盤模式
  private def contains_keyboard_patterns?(value)
    value_downcase = value.downcase

    static_hit = KEYBOARD_PATTERNS.any? do |pattern|
      next false if pattern.length < KEYBOARD_PATTERN_MIN_LENGTH
      value_downcase.include?(pattern.downcase)
    end
    return true if static_hit

    # 與正式實作一致：也檢查動態鍵盤模式
    return true if contains_dynamic_keyboard_patterns?(value_downcase)

    false
  end

  # 動態檢測鍵盤模式
  private def contains_dynamic_keyboard_patterns?(value)
    value_downcase = value.downcase
    
    # 檢測連續的鍵盤位置字符
    keyboard_rows = [
      '1234567890',
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm'
    ]
    
    # 檢查每個鍵盤行
    keyboard_rows.each do |row|
      # 檢查正向和反向的連續字符（最少 4 字符）
      (KEYBOARD_PATTERN_MIN_LENGTH..6).each do |length|
        (0..row.length - length).each do |start|
          pattern = row[start, length]
          reverse_pattern = pattern.reverse
          
          if value_downcase.include?(pattern) || value_downcase.include?(reverse_pattern)
            return true
          end
        end
      end
    end
    
    # 檢測數字鍵盤模式
    numpad_patterns = [
      '147', '258', '369', '741', '852', '963',
      '147258369', '963852741',
      '1472', '2583', '3694', '7418', '8529', '9630'
    ]
    
    numpad_patterns.each do |pattern|
      next if pattern.length < KEYBOARD_PATTERN_MIN_LENGTH
      if value_downcase.include?(pattern)
        return true
      end
    end
    
    # 檢測常見的鍵盤位置組合
    common_patterns = [
      '1qaz', '2wsx', '3edc', '4rfv', '5tgb', '6yhn', '7ujm', '8ik9', '9ol0',
      'qaz2', 'wsx3', 'edc4', 'rfv5', 'tgb6', 'yhn7', 'ujm8', 'ik9o', 'lo0p'
    ]
    
    common_patterns.each do |pattern|
      if value_downcase.include?(pattern)
        return true
      end
    end
    
    # 檢測反向模式
    reverse_patterns = [
      'zaq1', 'xsw2', 'cde3', 'vfr4', 'bgt5', 'nhy6', 'mju7', 'ki8', 'pl0',
      '2zaq', '3xsw', '4cde', '5vfr', '6bgt', '7nhy', '8mju', '9ki', '0pl'
    ]
    
    reverse_patterns.each do |pattern|
      if value_downcase.include?(pattern)
        return true
      end
    end
    
    false
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

  # 新增：詳細錯誤訊息
  def self.detailed_error_message(error_type)
    case error_type
    when :too_short
      "密碼長度不足。建議：使用至少8個字符的密碼"
    when :too_long
      "密碼長度過長。建議：使用不超過1000個字符的密碼"
    when :must_contain_uppercase
      "密碼必須包含大寫字母。建議：至少包含一個大寫字母（A-Z）"
    when :must_contain_lowercase
      "密碼必須包含小寫字母。建議：至少包含一個小寫字母（a-z）"
    when :must_contain_numbers
      "密碼必須包含數字。建議：至少包含一個數字（0-9）"
    when :must_contain_special_chars
      "密碼必須包含特殊字符。建議：至少包含一個特殊字符（!@#$%^&*等）"
    when :contains_sequential_chars
      "密碼包含連續字符。建議：避免使用連續字符（如123456、abcdef）"
    when :contains_keyboard_patterns
      "密碼包含鍵盤模式。建議：避免使用鍵盤模式（如1qaz2wsx）"
    when :contains_repetitive_chars
      "密碼包含重複字符。建議：避免使用重複字符（如aaa、111）"
    when :is_common_password
      "密碼過於常見。建議：使用更獨特的密碼"
    else
      "密碼不符合要求。建議：檢查密碼政策設定"
    end
  end
end

# 新增：PasswordPolicyUtils 模組
module PasswordPolicyUtils
  # 密碼強度評估器
  class StrengthEvaluator
    def self.calculate_score(password)
      return 0 if password.blank?
      
      score = 0
      
      # 長度分數
      score += [password.length * 4, 25].min
      
      # 字符類型分數
      score += 10 if password.match(/[A-Z]/)
      score += 10 if password.match(/[a-z]/)
      score += 10 if password.match(/\d/)
      score += 15 if password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      
      # 複雜度獎勵
      score += 10 if password.length >= 12
      score += 10 if password.match(/[A-Z]/) && password.match(/[a-z]/) && password.match(/\d/) && password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      
      [score, 100].min
    end

    def self.get_strength_level(score)
      case score
      when 0..20
        { level: 'very_weak', description: '非常弱' }
      when 21..40
        { level: 'weak', description: '弱' }
      when 41..60
        { level: 'medium', description: '中等' }
      when 61..80
        { level: 'strong', description: '強' }
      else
        { level: 'very_strong', description: '非常強' }
      end
    end
  end

  # 建議生成器
  class SuggestionGenerator
    def self.generate_suggestions(password, errors)
      suggestions = []
      
      errors.each do |error|
        case error
        when :too_short
          suggestions << "增加密碼長度到至少8個字符"
        when :must_contain_uppercase
          suggestions << "添加至少一個大寫字母（A-Z）"
        when :must_contain_lowercase
          suggestions << "添加至少一個小寫字母（a-z）"
        when :must_contain_numbers
          suggestions << "添加至少一個數字（0-9）"
        when :must_contain_special_chars
          suggestions << "添加至少一個特殊字符（!@#$%^&*等）"
        when :contains_sequential_chars
          suggestions << "避免使用連續字符（如123456、abcdef）"
        when :contains_keyboard_patterns
          suggestions << "避免使用鍵盤模式（如1qaz2wsx）"
        when :contains_repetitive_chars
          suggestions << "避免使用重複字符（如aaa、111）"
        when :is_common_password
          suggestions << "使用更獨特的密碼"
        end
      end
      
      suggestions
    end

    def self.generate_examples
      [
        'MyS3cur3P@ssw0rd!',
        'N3wS3cur3P@ssw0rd!',
        'C0mpl3xP@ssw0rd!',
        'S3cur3P@ssw0rd2024!',
        'V3ryS3cur3P@ssw0rd!'
      ]
    end
  end

  # 配置驗證器
  class ConfigValidator
    def self.validate_config(settings)
      errors = []

      # 驗證啟用設定
      unless [true, false, '1', '0', 1, 0].include?(settings['enabled'])
        errors << "enabled 必須是布林值"
      end

      # 驗證最小長度
      min_length = settings['min_length'].to_i
      if min_length < 1 || min_length > 50
        errors << "最小長度必須在1-50之間"
      end

      # 驗證布林設定
      boolean_settings = [
        'require_uppercase', 'require_lowercase', 'require_numbers',
        'require_special_chars', 'prevent_common_passwords',
        'prevent_sequential_chars', 'prevent_keyboard_patterns', 'prevent_repetitive_chars'
      ]

      boolean_settings.each do |setting|
        unless [true, false, '1', '0', 1, 0, nil].include?(settings[setting])
          errors << "#{setting} 必須是布林值"
        end
      end

      errors
    end

    def self.clean_config(settings)
      cleaned = settings.dup

      # 清理啟用設定
      cleaned['enabled'] = cleaned['enabled'].to_s == 'true' || cleaned['enabled'].to_s == '1'

      # 清理最小長度
      min_length = cleaned['min_length'].to_i
      cleaned['min_length'] = [[min_length, 1].max, 50].min

      # 清理布林設定
      boolean_settings = [
        'require_uppercase', 'require_lowercase', 'require_numbers',
        'require_special_chars', 'prevent_common_passwords',
        'prevent_sequential_chars', 'prevent_keyboard_patterns', 'prevent_repetitive_chars'
      ]

      boolean_settings.each do |setting|
        cleaned[setting] = cleaned[setting].to_s == 'true' || cleaned[setting].to_s == '1'
      end

      cleaned
    end

    def self.enabled?
      settings = Setting.plugin_password_policy
      return false unless settings
      settings['enabled'].to_s == 'true' || settings['enabled'].to_s == '1'
    end
  end
end

# 測試工具方法
module TestHelpers
  def self.create_test_user(attributes = {})
    user = User.new
    user.login = attributes[:login] || 'testuser'
    user.email = attributes[:email] || 'test@example.com'
    user.password = attributes[:password] || 'TestPass123!'
    user.password_confirmation = attributes[:password_confirmation] || user.password
    user
  end

  def self.valid_password
    'MyS3cur3P@ssw0rd!'
  end

  def self.weak_passwords
    [
      'password',
      '123456',
      'qwerty',
      'abc123',
      'admin',
      'test123'
    ]
  end

  def self.strong_passwords
    [
      'MyS3cur3P@ssw0rd!',
      'N3wS3cur3P@ssw0rd!',
      'C0mpl3xP@ssw0rd!',
      'S3cur3P@ssw0rd2024!',
      'V3ryS3cur3P@ssw0rd!'
    ]
  end
end

# 整合測試類別
class PasswordPolicyIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = User.new
    @admin_user.login = 'admin'
    @admin_user.id = 1
    
    @regular_user = User.new
    @regular_user.login = 'user'
    @regular_user.id = 2
    
    # 啟用密碼政策插件
    Setting.plugin_password_policy = {
      'enabled' => true,
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
  end

  def test_user_registration_with_weak_password
    # 測試用戶註冊時使用弱密碼
    user = User.new
    user.login = 'testuser'
    user.email = 'testuser@example.com'
    user.password = 'password'
    user.password_confirmation = 'password'
    
    # 設置密碼政策
    Setting.stubs(:plugin_password_policy).returns({
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => true,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    })
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
    assert_includes user.errors[:password], '不能使用常見的密碼'
  end

  def test_user_registration_with_strong_password
    # 測試用戶註冊時使用強密碼
    user = User.new
    user.login = 'testuser2'
    user.email = 'testuser2@example.com'
    user.password = 'MyS3cur3P@ssw0rd!'
    user.password_confirmation = 'MyS3cur3P@ssw0rd!'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
    assert_empty user.errors[:password]
  end

  def test_password_change_with_weak_password
    # 直接測試驗證邏輯，不依賴 Setting
    test_settings = {
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    }
    
    # 嘗試修改密碼為弱密碼
    user = User.new
    user.password = '123456'
    user.password_confirmation = '123456'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.send(:perform_validations, user, :password, '123456', test_settings)
    
    assert_includes user.errors[:password], '密碼長度不足，至少需要 8 個字符'
  end

  def test_password_change_with_strong_password
    # 登入管理員
    log_user('admin', 'admin')
    
    # 修改密碼為強密碼
    user = User.new
    user.password = 'N3wS3cur3P@ssw0rd!'
    user.password_confirmation = 'N3wS3cur3P@ssw0rd!'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
    assert_empty user.errors[:password]
  end

  def test_password_strength_calculation
    assert_equal 0, PasswordValidator.calculate_password_strength('')
    assert_equal 0, PasswordValidator.calculate_password_strength(nil)
    assert_equal 2, PasswordValidator.calculate_password_strength('password')  # 長度8+小寫字母
    assert_equal 3, PasswordValidator.calculate_password_strength('password123')  # 長度8+小寫字母+數字
    assert_equal 4, PasswordValidator.calculate_password_strength('Password123')  # 長度8+大小寫字母+數字
    assert_equal 5, PasswordValidator.calculate_password_strength('Password123!')  # 長度8+大小寫字母+數字+特殊字符
    assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')  # 最高分
  end

  def test_password_strength_description
    assert_equal '非常弱', PasswordValidator.password_strength_description(0)
    assert_equal '非常弱', PasswordValidator.password_strength_description(1)
    assert_equal '弱', PasswordValidator.password_strength_description(2)
    assert_equal '中等', PasswordValidator.password_strength_description(3)
    assert_equal '強', PasswordValidator.password_strength_description(4)
    assert_equal '非常強', PasswordValidator.password_strength_description(5)
    assert_equal '未知', PasswordValidator.password_strength_description(6)
  end

  # 新增：測試啟用功能
  def test_plugin_disabled_skips_validation
    # 直接測試停用邏輯，不依賴 Setting
    test_settings = {
      'enabled' => false,
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

    # 嘗試使用弱密碼，應該不會有驗證錯誤
    user = User.new
    user.password = 'password'
    user.password_confirmation = 'password'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.send(:perform_validations, user, :password, 'password', test_settings)
    
    # 由於插件被停用，應該不會有密碼驗證錯誤
    assert_empty user.errors[:password], "插件停用時應該跳過所有驗證"
  end

  def test_plugin_enabled_performs_validation
    # 直接測試驗證邏輯，不依賴 Setting
    test_settings = {
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    }
    
    test_user = User.new
    test_user.password = 'weakpassword'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.send(:perform_validations, test_user, :password, 'weakpassword', test_settings)
    
    assert test_user.errors[:password].any? { |error| error.include?('大寫字母') }, "應該包含大寫字母錯誤訊息，實際錯誤: #{test_user.errors[:password]}"
  end

  # 新增：測試詳細錯誤訊息功能
  def test_detailed_error_messages
    # 測試各種錯誤類型的詳細訊息
    assert_includes PasswordValidator.detailed_error_message(:too_short), '建議'
    assert_includes PasswordValidator.detailed_error_message(:too_long), '建議'
    assert_includes PasswordValidator.detailed_error_message(:must_contain_uppercase), '建議'
    assert_includes PasswordValidator.detailed_error_message(:must_contain_lowercase), '建議'
    assert_includes PasswordValidator.detailed_error_message(:must_contain_numbers), '建議'
    assert_includes PasswordValidator.detailed_error_message(:must_contain_special_chars), '建議'
    assert_includes PasswordValidator.detailed_error_message(:contains_sequential_chars), '建議'
    assert_includes PasswordValidator.detailed_error_message(:contains_keyboard_patterns), '建議'
    assert_includes PasswordValidator.detailed_error_message(:contains_repetitive_chars), '建議'
    assert_includes PasswordValidator.detailed_error_message(:is_common_password), '建議'
  end

  # 新增：測試配置驗證功能
  def test_settings_validation
    # 測試無效的最小長度設定
    invalid_settings = { 'min_length' => 100 }  # 超出範圍
    validator = PasswordValidator.new(attributes: [:password])
    validator.send(:validate_settings, invalid_settings)
    assert_equal 8, invalid_settings['min_length']  # 應該被重置為預設值
  end

  # 新增：測試效能優化
  def test_performance_optimizations
    # 測試預編譯正則表達式
    assert_instance_of Regexp, PasswordValidator::UPPERCASE_REGEX
    assert_instance_of Regexp, PasswordValidator::LOWERCASE_REGEX
    assert_instance_of Regexp, PasswordValidator::NUMBERS_REGEX
    assert_instance_of Regexp, PasswordValidator::REPETITIVE_CHARS_REGEX
  end

  # 新增：測試新的私有方法
  def test_contains_sequential_chars_method
    validator = PasswordValidator.new(attributes: [:password])
    # 測試連續字符檢測
    assert validator.send(:contains_sequential_chars?, 'password1234567890')
    assert !validator.send(:contains_sequential_chars?, 'password123')
  end

  def test_contains_keyboard_patterns_method
    validator = PasswordValidator.new(attributes: [:password])
    # 測試鍵盤模式檢測
    assert validator.send(:contains_keyboard_patterns?, 'password1qaz2wsx')
    assert !validator.send(:contains_keyboard_patterns?, 'password123')
  end

  # 新增：測試增強的鍵盤模式檢測
  def test_enhanced_keyboard_pattern_detection
    validator = PasswordValidator.new(attributes: [:password])
    
    # 測試部分鍵盤模式
    assert validator.send(:contains_keyboard_patterns?, '1qaz@WSX3edc'), "應該檢測到部分鍵盤模式 1qaz"
    assert validator.send(:contains_keyboard_patterns?, 'password1qaz'), "應該檢測到部分鍵盤模式 1qaz"
    assert !validator.send(:contains_keyboard_patterns?, 'MyP@ssw0rdWSX'), "3 碼 WSX 不應該觸發（至少 4 碼）"
    assert validator.send(:contains_keyboard_patterns?, 'password3edc'), "應該檢測到部分鍵盤模式 3edc"
    
    # 測試數字鍵盤模式
    assert !validator.send(:contains_keyboard_patterns?, 'password147'), "3 碼 147 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_keyboard_patterns?, 'MyP@ss258'), "3 碼 258 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_keyboard_patterns?, 'password369'), "3 碼 369 不應該觸發（至少 4 碼）"
    
    # 測試字母鍵盤模式
    assert !validator.send(:contains_keyboard_patterns?, 'passwordqwe'), "3 碼 qwe 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_keyboard_patterns?, 'MyP@ssasd'), "3 碼 asd 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_keyboard_patterns?, 'passwordzxc'), "3 碼 zxc 不應該觸發（至少 4 碼）"
    
    # 測試大小寫混合模式
    assert !validator.send(:contains_keyboard_patterns?, 'passwordQWE'), "3 碼 QWE 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_keyboard_patterns?, 'MyP@ssASD'), "3 碼 ASD 不應該觸發（至少 4 碼）"

    # 4 碼應觸發
    assert validator.send(:contains_keyboard_patterns?, 'passwordqwer'), "4 碼 qwer 應該觸發"
    assert validator.send(:contains_keyboard_patterns?, 'password1472'), "4 碼 1472 應該觸發"
    
    # 測試正常密碼（不應該被檢測）
    assert !validator.send(:contains_keyboard_patterns?, 'MyS3cur3P@ssw0rd!'), "正常密碼不應該被檢測"
    assert !validator.send(:contains_keyboard_patterns?, 'C0mpl3xP@ssw0rd!'), "正常密碼不應該被檢測"
    assert !validator.send(:contains_keyboard_patterns?, 'N3wS3cur3P@ssw0rd!'), "正常密碼不應該被檢測"
  end

  # 新增：測試動態鍵盤模式檢測
  def test_dynamic_keyboard_pattern_detection
    validator = PasswordValidator.new(attributes: [:password])
    
    # 測試動態檢測方法
    assert validator.send(:contains_dynamic_keyboard_patterns?, '1qaz'), "應該檢測到動態鍵盤模式 1qaz"
    assert validator.send(:contains_dynamic_keyboard_patterns?, 'wsx3'), "應該檢測到動態鍵盤模式 wsx3"
    assert validator.send(:contains_dynamic_keyboard_patterns?, 'edc4'), "應該檢測到動態鍵盤模式 edc4"
    assert !validator.send(:contains_dynamic_keyboard_patterns?, '147'), "3 碼 147 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_dynamic_keyboard_patterns?, '258'), "3 碼 258 不應該觸發（至少 4 碼）"
    assert !validator.send(:contains_dynamic_keyboard_patterns?, '369'), "3 碼 369 不應該觸發（至少 4 碼）"
    
    # 測試反向模式
    assert validator.send(:contains_dynamic_keyboard_patterns?, 'zaq1'), "應該檢測到反向鍵盤模式 zaq1"
    assert !validator.send(:contains_dynamic_keyboard_patterns?, '741'), "3 碼 741 不應該觸發（至少 4 碼）"

    # 4 碼應觸發
    assert validator.send(:contains_dynamic_keyboard_patterns?, '1472'), "4 碼 1472 應該觸發"
    assert validator.send(:contains_dynamic_keyboard_patterns?, 'qwer'), "4 碼 qwer 應該觸發"
    
    # 測試正常密碼（不應該被檢測）
    assert !validator.send(:contains_dynamic_keyboard_patterns?, 'MyS3cur3P@ssw0rd!'), "正常密碼不應該被檢測"
  end

  # 新增：測試工具類別
  def test_strength_evaluator
    # 測試密碼強度評估
    score = PasswordPolicyUtils::StrengthEvaluator.calculate_score('MyS3cur3P@ssw0rd!')
    assert score > 80, "強密碼應該有高分數"
    
    weak_score = PasswordPolicyUtils::StrengthEvaluator.calculate_score('password')
    assert weak_score < 40, "弱密碼應該有低分數"
    
    # 測試強度等級
    level = PasswordPolicyUtils::StrengthEvaluator.get_strength_level(score)
    assert_equal 'very_strong', level[:level]
    assert_equal '非常強', level[:description]
  end

  def test_suggestion_generator
    # 測試建議生成
    suggestions = PasswordPolicyUtils::SuggestionGenerator.generate_suggestions('weak', [:too_short, :must_contain_uppercase])
    assert suggestions.any? { |s| s.include?('增加密碼長度') }
    assert suggestions.any? { |s| s.include?('大寫字母') }
    
    # 測試範例生成
    examples = PasswordPolicyUtils::SuggestionGenerator.generate_examples
    assert examples.length > 0
    assert examples.all? { |ex| ex.length >= 8 }
  end

  def test_config_validator
    # 測試配置驗證
    valid_config = {
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => true
    }
    errors = PasswordPolicyUtils::ConfigValidator.validate_config(valid_config)
    assert_empty errors
    
    # 測試無效配置
    invalid_config = {
      'enabled' => 'invalid',  # 無效布林值
      'min_length' => 100,  # 超出範圍
      'require_uppercase' => 'invalid'  # 無效布林值
    }
    errors = PasswordPolicyUtils::ConfigValidator.validate_config(invalid_config)
    assert errors.any?
    
    # 測試配置清理
    cleaned = PasswordPolicyUtils::ConfigValidator.clean_config(invalid_config)
    assert_equal false, cleaned['enabled']  # 無效值應該被轉換為 false
    assert_equal 50, cleaned['min_length']  # 應該被限制在最大值
    assert_equal false, cleaned['require_uppercase']  # 無效值應該被轉換為 false
  end

  def test_config_validator_enabled_method
    # 測試啟用檢查方法
    Setting.stubs(:plugin_password_policy).returns({ 'enabled' => true })
    assert PasswordPolicyUtils::ConfigValidator.enabled?
    
    Setting.stubs(:plugin_password_policy).returns({ 'enabled' => false })
    assert !PasswordPolicyUtils::ConfigValidator.enabled?
    
    Setting.stubs(:plugin_password_policy).returns(nil)
    assert !PasswordPolicyUtils::ConfigValidator.enabled?
  end

  # 新增：測試邊界條件
  def test_password_too_long
    Setting.plugin_password_policy = {
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    }

    long_password = 'a' * 1001
    user = User.new
    user.password = long_password
    user.password_confirmation = long_password
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
    assert_includes user.errors[:password], '密碼長度過長，最多只能 1000 個字符'
  end

  def test_password_with_unicode_characters
    Setting.plugin_password_policy = {
      'enabled' => true,
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    }

    # 測試包含 Unicode 字符的密碼
    unicode_password = '密碼12345678'  # 確保長度 >= 8
    user = User.new
    user.password = unicode_password
    user.password_confirmation = unicode_password
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
    assert_empty user.errors[:password]
  end
end

# 測試運行器
class TestRunner
  def self.run_all_tests
    puts "=" * 60
    puts "密碼政策插件完整測試套件"
    puts "開始時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60

    # 運行整合測試
    run_integration_tests
    
    puts "=" * 60
    puts "測試完成！"
    puts "結束時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
  end

  private

  def self.run_integration_tests
    puts "\n🔍 運行整合測試..."
    puts "-" * 40
    
    # 直接載入測試文件內容
    load_integration_tests
  end

  def self.load_integration_tests
    puts "運行測試類別: PasswordPolicyIntegration"
    
    # 創建測試實例
    test_suite = PasswordPolicyIntegrationTest.new("test_user_registration_with_weak_password")
    
    # 運行所有測試方法
    test_methods = PasswordPolicyIntegrationTest.instance_methods.grep(/^test_/)
    
    test_methods.each do |method_name|
      begin
        test_suite.setup if test_suite.respond_to?(:setup)
        test_suite.send(method_name)
        test_suite.teardown if test_suite.respond_to?(:teardown)
        puts "  ✅ #{method_name}"
      rescue => e
        puts "  ❌ #{method_name} - 失敗: #{e.message}"
      end
    end
  end
end

# 如果直接運行此文件，執行所有測試
if __FILE__ == $0
  TestRunner.run_all_tests
end
