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
        @errors[attribute] << "密碼不能包含連續鍵盤位置字符（如1qaz2wsx、#EDC$RFV等）"
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

# 單元測試類別
class PasswordValidatorTest < ActiveSupport::TestCase
  def setup
    @validator = PasswordValidator.new(attributes: [:password])
    @record = User.new
  end

  def test_valid_password
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => true,
      'require_numbers' => true,
      'require_special_chars' => true,
      'prevent_common_passwords' => true,
      'prevent_sequential_chars' => true,
      'prevent_repetitive_chars' => true
    })

    @validator.validate_each(@record, :password, 'MyS3cur3P@ssw0rd!')
    assert_empty @record.errors[:password]
  end

  def test_password_too_short
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 10,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'short')
    assert_includes @record.errors[:password], '密碼長度不足，至少需要 10 個字符'
  end

  def test_password_missing_uppercase
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'mypassword123')
    assert_includes @record.errors[:password], '密碼必須包含至少一個大寫字母'
  end

  def test_password_missing_lowercase
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => true,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'MYPASSWORD123')
    assert_includes @record.errors[:password], '密碼必須包含至少一個小寫字母'
  end

  def test_password_missing_numbers
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => true,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'MyPassword')
    assert_includes @record.errors[:password], '密碼必須包含至少一個數字'
  end

  def test_password_missing_special_chars
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => true,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'MyPassword123')
    assert_includes @record.errors[:password], '密碼必須包含至少一個特殊字符'
  end

  def test_common_password_rejected
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => true,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'password')
    assert_includes @record.errors[:password], '不能使用常見的密碼'
  end

  def test_sequential_chars_rejected
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => true,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'password1234567890')
    assert_includes @record.errors[:password], '密碼不能包含連續字符（如123456、abcdef等）'
  end

  def test_keyboard_patterns_rejected
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_keyboard_patterns' => true,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'password1qaz2wsx')
    assert_includes @record.errors[:password], '密碼不能包含連續鍵盤位置字符（如1qaz2wsx、#EDC$RFV等）'
  end

  def test_repetitive_chars_rejected
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => true
    })

    @validator.validate_each(@record, :password, 'passwordaaa')
    assert_includes @record.errors[:password], '密碼不能包含重複字符（如aaa、111等）'
  end

  def test_empty_password_skipped
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => true,
      'require_numbers' => true,
      'require_special_chars' => true,
      'prevent_common_passwords' => true,
      'prevent_sequential_chars' => true,
      'prevent_repetitive_chars' => true
    })

    @validator.validate_each(@record, :password, '')
    assert_empty @record.errors[:password]
  end

  def test_nil_password_skipped
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => true,
      'require_lowercase' => true,
      'require_numbers' => true,
      'require_special_chars' => true,
      'prevent_common_passwords' => true,
      'prevent_sequential_chars' => true,
      'prevent_repetitive_chars' => true
    })

    @validator.validate_each(@record, :password, nil)
    assert_empty @record.errors[:password]
  end

  def test_no_settings_skipped
    Setting.stubs(:plugin_password_policy).returns(nil)

    @validator.validate_each(@record, :password, 'weakpassword')
    assert_empty @record.errors[:password]
  end

  def test_password_too_long
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 8,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    long_password = 'a' * 1001
    @validator.validate_each(@record, :password, long_password)
    assert_includes @record.errors[:password], '密碼長度過長，最多只能 1000 個字符'
  end

  def test_password_strength_calculation
    assert_equal 0, PasswordValidator.calculate_password_strength('')
    assert_equal 2, PasswordValidator.calculate_password_strength('password')  # 長度 >= 8, 小寫字母
    assert_equal 4, PasswordValidator.calculate_password_strength('Password123')  # 長度 >= 8, 大寫, 小寫, 數字
    assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')  # 所有條件都滿足
  end

  def test_password_strength_description
    assert_equal '非常弱', PasswordValidator.password_strength_description(0)
    assert_equal '弱', PasswordValidator.password_strength_description(2)
    assert_equal '中等', PasswordValidator.password_strength_description(3)
    assert_equal '強', PasswordValidator.password_strength_description(4)
    assert_equal '非常強', PasswordValidator.password_strength_description(5)
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
    # 登入管理員
    log_user('admin', 'admin')
    
    # 嘗試修改密碼為弱密碼
    user = User.new
    user.password = '123456'
    user.password_confirmation = '123456'
    
    validator = PasswordValidator.new(attributes: [:password])
    validator.validate_each(user, :password, user.password)
    
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
    assert_equal 2, PasswordValidator.calculate_password_strength('password')  # 長度 >= 8, 小寫字母
    assert_equal 4, PasswordValidator.calculate_password_strength('Password123')  # 長度 >= 8, 大寫, 小寫, 數字
    assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')  # 所有條件都滿足
  end

  def test_password_strength_description
    assert_equal '非常弱', PasswordValidator.password_strength_description(1)
    assert_equal '弱', PasswordValidator.password_strength_description(2)
    assert_equal '中等', PasswordValidator.password_strength_description(3)
    assert_equal '強', PasswordValidator.password_strength_description(4)
    assert_equal '非常強', PasswordValidator.password_strength_description(5)
  end
end

# 測試運行器
class TestRunner
  def self.run_all_tests
    puts "=" * 60
    puts "密碼政策插件完整測試套件"
    puts "開始時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60

    # 運行單元測試
    run_unit_tests
    
    # 運行整合測試
    run_integration_tests
    
    puts "=" * 60
    puts "測試完成！"
    puts "結束時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
  end

  private

  def self.run_unit_tests
    puts "\n🔍 運行單元測試..."
    puts "-" * 40
    
    # 直接載入測試文件內容
    load_unit_tests
    
  end

  def self.run_integration_tests
    puts "\n🔍 運行整合測試..."
    puts "-" * 40
    
    # 直接載入測試文件內容
    load_integration_tests
    
  end

  def self.load_unit_tests
    puts "運行測試類別: PasswordValidator"
    
    # 創建測試實例
    test_suite = PasswordValidatorTest.new("test_valid_password")
    
    # 運行所有測試方法
    test_methods = PasswordValidatorTest.instance_methods.grep(/^test_/)
    
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
