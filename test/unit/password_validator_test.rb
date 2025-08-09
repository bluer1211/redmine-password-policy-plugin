require File.expand_path('../../../test_helper', __FILE__)

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
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'mypassword123456')
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

    @validator.validate_each(@record, :password, 'mypassword1qaz2wsx')
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
      'prevent_keyboard_patterns' => false,
      'prevent_repetitive_chars' => true
    })

    @validator.validate_each(@record, :password, 'mypasswordaaa')
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

  # 新增的邊界條件測試
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

  def test_password_with_extreme_length
    Setting.stubs(:plugin_password_policy).returns({
      'min_length' => 50,
      'require_uppercase' => false,
      'require_lowercase' => false,
      'require_numbers' => false,
      'require_special_chars' => false,
      'prevent_common_passwords' => false,
      'prevent_sequential_chars' => false,
      'prevent_repetitive_chars' => false
    })

    @validator.validate_each(@record, :password, 'short')
    assert_includes @record.errors[:password], '密碼長度不足，至少需要 50 個字符'
  end

  def test_password_with_special_characters_edge_cases
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

    # 測試包含特殊字符的密碼
    @validator.validate_each(@record, :password, 'password!')
    assert_empty @record.errors[:password]

    # 測試不包含特殊字符的密碼
    @validator.validate_each(@record, :password, 'password123')
    assert_includes @record.errors[:password], '密碼必須包含至少一個特殊字符'
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

  def test_password_with_unicode_characters
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

    # 測試包含 Unicode 字符的密碼
    unicode_password = '密碼123'
    @validator.validate_each(@record, :password, unicode_password)
    assert_empty @record.errors[:password]
  end

  def test_password_with_whitespace
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

    # 測試包含空白字符的密碼
    password_with_spaces = '  password123  '
    @validator.validate_each(@record, :password, password_with_spaces)
    assert_empty @record.errors[:password]
  end
end 