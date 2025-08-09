require 'redmine'

Redmine::Plugin.register :password_policy do
  name 'Password Policy Plugin'
  author 'Jason Liu (bluer1211)'
  description 'Enforces password policy rules for Redmine users'
  version '2.0.0'
  url 'https://github.com/bluer1211/redmine-password-policy-plugin'
  author_url 'https://github.com/bluer1211'
  
  # 支援 Redmine 6.0.6
  requires_redmine version_or_higher: '6.0.0'
  
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
  begin
    # 載入插件組件
    require File.expand_path('../lib/password_policy_hooks', __FILE__)
    require File.expand_path('../app/models/password_validator', __FILE__)
    
    # 初始化鉤子
    PasswordPolicyHooks::Hooks.after_plugins_loaded
    
    Rails.logger.info "Password Policy Plugin: 插件初始化完成"
  rescue => e
    Rails.logger.error "Password Policy Plugin: 初始化失敗 - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end 