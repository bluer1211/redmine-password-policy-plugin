require File.expand_path('../../test_helper', __FILE__)

class PasswordPolicyIntegrationTest < ActionDispatch::IntegrationTest
  fixtures :users, :roles, :projects, :members, :member_roles

  def setup
    @admin_user = users(:users_001)  # admin user
    @regular_user = users(:users_002)  # regular user
    @project = projects(:projects_001)
    
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
  end

  def test_password_policy_settings_update
    # 登入管理員
    log_user('admin', 'admin')
    
    # 更新密碼政策設定
    put '/settings/plugin/password_policy', params: {
      settings: {
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
    assert_equal 10, updated_settings['min_length']
    assert_equal true, updated_settings['require_uppercase']
  end

  def test_password_strength_calculation
    # 測試密碼強度計算
    assert_equal 0, PasswordValidator.calculate_password_strength('')
    assert_equal 1, PasswordValidator.calculate_password_strength('password')
    assert_equal 3, PasswordValidator.calculate_password_strength('Password123')
    assert_equal 5, PasswordValidator.calculate_password_strength('MyS3cur3P@ssw0rd!')
  end

  def test_password_strength_description
    # 測試密碼強度描述
    assert_equal '非常弱', PasswordValidator.password_strength_description(1)
    assert_equal '弱', PasswordValidator.password_strength_description(2)
    assert_equal '中等', PasswordValidator.password_strength_description(3)
    assert_equal '強', PasswordValidator.password_strength_description(4)
    assert_equal '非常強', PasswordValidator.password_strength_description(5)
  end

  private

  def log_user(login, password)
    post '/login', params: { username: login, password: password }
  end
end
