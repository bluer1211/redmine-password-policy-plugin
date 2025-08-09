require File.expand_path('../../test_helper', __FILE__)

class PasswordPolicyIntegrationTest < ActionDispatch::IntegrationTest
  fixtures :users, :roles, :projects, :members, :member_roles

  def setup
    @admin_user = users(:users_001)  # admin user
    @regular_user = users(:users_002)  # regular user
    @project = projects(:projects_001)
    
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
    post '/users', params: {
      user: {
        login: 'testuser',
        firstname: 'Test',
        lastname: 'User',
        email: 'testuser@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
    
    assert_response :success
    assert_select '.error', /不能使用常見的密碼/
  end

  def test_user_registration_with_strong_password
    # 測試用戶註冊時使用強密碼
    post '/users', params: {
      user: {
        login: 'testuser2',
        firstname: 'Test',
        lastname: 'User2',
        email: 'testuser2@example.com',
        password: 'MyS3cur3P@ssw0rd!',
        password_confirmation: 'MyS3cur3P@ssw0rd!'
      }
    }
    
    assert_response :redirect
    assert_redirected_to '/users'
  end

  def test_password_change_with_weak_password
    # 登入管理員
    log_user('admin', 'admin')
    
    # 嘗試修改密碼為弱密碼
    put "/users/#{@regular_user.id}", params: {
      user: {
        password: '123456',
        password_confirmation: '123456'
      }
    }
    
    assert_response :success
    assert_select '.error', /密碼長度不足/
  end

  def test_password_change_with_strong_password
    # 登入管理員
    log_user('admin', 'admin')
    
    # 修改密碼為強密碼
    put "/users/#{@regular_user.id}", params: {
      user: {
        password: 'N3wS3cur3P@ssw0rd!',
        password_confirmation: 'N3wS3cur3P@ssw0rd!'
      }
    }
    
    assert_response :redirect
    assert_redirected_to "/users/#{@regular_user.id}"
  end

  def test_password_policy_settings_page
    # 登入管理員
    log_user('admin', 'admin')
    
    # 訪問插件設定頁面
    get '/settings/plugin/password_policy'
    assert_response :success
    assert_select 'h2', /密碼政策/
    assert_select 'input[name="settings[min_length]"]'
    assert_select 'input[name="settings[require_uppercase]"]'
    assert_select 'input[name="settings[enabled]"]'
  end

  def test_password_policy_settings_update
    # 登入管理員
    log_user('admin', 'admin')
    
    # 更新密碼政策設定
    put '/settings/plugin/password_policy', params: {
      settings: {
        enabled: '1',
        min_length: 10,
        require_uppercase: '1',
        require_lowercase: '1',
        require_numbers: '1',
        require_special_chars: '1',
        prevent_common_passwords: '1',
        prevent_sequential_chars: '1',
        prevent_keyboard_patterns: '1',
        prevent_repetitive_chars: '1'
      }
    }
    
    assert_response :redirect
    assert_redirected_to '/settings/plugin/password_policy'
    
    # 驗證設定已更新
    updated_settings = Setting.plugin_password_policy
    assert_equal true, updated_settings['enabled']
    assert_equal 10, updated_settings['min_length']
    assert_equal true, updated_settings['require_uppercase']
  end

  def test_password_strength_calculation
    # 測試密碼強度計算
    assert_equal 0, PasswordValidator.calculate_password_strength('')
    assert_equal 0, PasswordValidator.calculate_password_strength(nil)
    assert_equal 1, PasswordValidator.calculate_password_strength('password')
    assert_equal 2, PasswordValidator.calculate_password_strength('password123')
    assert_equal 3, PasswordValidator.calculate_password_strength('Password123')
    assert_equal 4, PasswordValidator.calculate_password_strength('Password123!')
    assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')
  end

  def test_password_strength_description
    # 測試密碼強度描述
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
    # 停用密碼政策
    Setting.plugin_password_policy = {
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
    post '/users', params: {
      user: {
        login: 'testuser3',
        firstname: 'Test',
        lastname: 'User3',
        email: 'testuser3@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
    
    # 由於插件被停用，應該不會有密碼驗證錯誤
    assert_response :redirect
  end

  def test_plugin_enabled_performs_validation
    # 重新啟用密碼政策
    Setting.plugin_password_policy = {
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

    # 嘗試使用弱密碼，應該有驗證錯誤
    post '/users', params: {
      user: {
        login: 'testuser4',
        firstname: 'Test',
        lastname: 'User4',
        email: 'testuser4@example.com',
        password: 'weakpassword',
        password_confirmation: 'weakpassword'
      }
    }
    
    assert_response :success
    assert_select '.error', /密碼必須包含至少一個大寫字母/
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
    assert_equal true, cleaned['enabled']  # 應該被轉換為布林值
    assert_equal 50, cleaned['min_length']  # 應該被限制在最大值
    assert_equal false, cleaned['require_uppercase']  # 應該被轉換為布林值
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
    post '/users', params: {
      user: {
        login: 'testuser5',
        firstname: 'Test',
        lastname: 'User5',
        email: 'testuser5@example.com',
        password: long_password,
        password_confirmation: long_password
      }
    }
    
    assert_response :success
    assert_select '.error', /密碼長度過長/
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
    unicode_password = '密碼123'
    post '/users', params: {
      user: {
        login: 'testuser6',
        firstname: 'Test',
        lastname: 'User6',
        email: 'testuser6@example.com',
        password: unicode_password,
        password_confirmation: unicode_password
      }
    }
    
    assert_response :redirect
  end

  private

  def log_user(login, password)
    post '/login', params: { username: login, password: password }
  end
end
