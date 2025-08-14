require 'redmine'

Redmine::Plugin.register :password_policy do
  name 'Password Policy Plugin'
  author 'Jason Liu (bluer1211)'
  description 'Enforces password policy rules for Redmine users'
  version '2.1.0'
  url 'https://github.com/bluer1211/redmine-password-policy-plugin'
  author_url 'https://github.com/bluer1211'
  
  # 支援 Redmine 6.0.6
  requires_redmine version_or_higher: '6.0.0'
  
  # 設定設定頁面
  settings default: {
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
  }, partial: 'settings/password_policy_settings'
end

# 在插件載入後初始化
Rails.configuration.to_prepare do
  begin
    # 載入插件組件
    require File.expand_path('../lib/password_policy_hooks', __FILE__)
    require File.expand_path('../app/models/password_validator', __FILE__)
    require File.expand_path('../lib/password_policy_utils', __FILE__)
    
    # 初始化鉤子
    PasswordPolicyHooks::Hooks.after_plugins_loaded
    
    # 驗證插件設定
    validate_plugin_settings
    
    Rails.logger.info "Password Policy Plugin: 插件初始化完成"
  rescue => e
    Rails.logger.error "Password Policy Plugin: 初始化失敗 - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end

# 新增：驗證插件設定
def validate_plugin_settings
  settings = Setting.plugin_password_policy
  return unless settings
  
  # 使用新的配置驗證器
  errors = PasswordPolicyUtils::ConfigValidator.validate_config(settings)
  
  if errors.any?
    Rails.logger.warn "Password Policy Plugin: 配置驗證發現問題: #{errors.join(', ')}"
    # 清理配置
    cleaned_settings = PasswordPolicyUtils::ConfigValidator.clean_config(settings)
    Setting.plugin_password_policy = cleaned_settings
    Rails.logger.info "Password Policy Plugin: 配置已自動清理"
  end
  
  Rails.logger.info "Password Policy Plugin: 設定驗證完成"
rescue => e
  Rails.logger.error "Password Policy Plugin: 設定驗證失敗 - #{e.message}"
end 