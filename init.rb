require 'redmine'

Redmine::Plugin.register :password_policy do
  name 'Password Policy Plugin'
  author 'Jason Liu (bluer1211)'
  description 'Enforces password policy rules for Redmine users'
  version '1.0.0'
  url 'https://github.com/bluer1211/redmine-password-policy-plugin'
  author_url 'https://github.com/bluer1211'
  
  # 設定設定頁面
  settings default: {
    'min_length' => 8,
    'require_uppercase' => true,
    'require_lowercase' => true,
    'require_numbers' => true,
    'require_special_chars' => true,
    'prevent_common_passwords' => true,
    'prevent_sequential_chars' => true,
    'prevent_keyboard_patterns' => true,
    'prevent_repetitive_chars' => true
  }, partial: 'settings/password_policy_settings'
end

# 在插件載入後初始化
Rails.configuration.to_prepare do
  # 載入插件組件
  require File.expand_path('../lib/password_policy_hooks', __FILE__)
  require File.expand_path('../app/models/password_validator', __FILE__)
  
  # 初始化鉤子
  PasswordPolicyHooks::Hooks.after_plugins_loaded
end 