require 'redmine'

# =============================================================================
# Password Policy Plugin - 密碼策略插件
# =============================================================================
# 此插件為 Redmine 提供強化的密碼安全策略
# 支援多種密碼驗證規則和自定義配置
# =============================================================================

Redmine::Plugin.register :password_policy do
  # 插件基本信息
  name 'Password Policy Plugin'
  author 'Jason Liu (bluer1211)'
  description 'Enforces password policy rules for Redmine users'
  version '2.1.3'
  url 'https://github.com/bluer1211/redmine-password-policy-plugin'
  author_url 'https://github.com/bluer1211'
  
  # 版本要求
  requires_redmine version_or_higher: '6.0.0'
  
  # 插件設定配置
  settings default: {
    # 基本開關
    'enabled' => true,
    
    # 密碼長度要求
    'min_length' => 8,
    
    # 字元類型要求
    'require_uppercase' => true,      # 大寫字母
    'require_lowercase' => true,      # 小寫字母
    'require_numbers' => true,        # 數字
    'require_special_chars' => true,  # 特殊字元
    
    # 安全模式檢查
    'prevent_common_passwords' => true,     # 防止常見密碼
    'prevent_sequential_chars' => true,     # 防止連續字元
    'prevent_keyboard_patterns' => true,    # 防止鍵盤模式
    'prevent_repetitive_chars' => true      # 防止重複字元
  }, partial: 'settings/password_policy_settings'
end

# =============================================================================
# 插件初始化
# =============================================================================
Rails.configuration.to_prepare do
  initialize_password_policy_plugin
end

# 確保在應用程式啟動時也執行初始化
begin
  if Rails.env.development? || Rails.env.production?
    # 延遲初始化，等待 Rails 完全載入
    Rails.application.config.after_initialize do
      initialize_password_policy_plugin
    end
  end
rescue => e
  Rails.logger.error "Password Policy Plugin: 啟動時初始化失敗 - #{e.message}"
end

# =============================================================================
# 主要初始化函數
# =============================================================================
def initialize_password_policy_plugin
  begin
    # 載入插件組件
    load_plugin_components
    
    # 初始化鉤子系統
    initialize_hooks
    
    # 驗證和清理設定
    validate_and_clean_settings
    
    Rails.logger.info "Password Policy Plugin: 插件初始化完成"
    
  rescue => e
    log_initialization_error(e)
  end
end

# =============================================================================
# 載入插件組件
# =============================================================================
def load_plugin_components
  plugin_root = File.expand_path('..', __FILE__)
  
  # 載入核心組件
  require File.join(plugin_root, 'lib', 'password_policy_hooks')
  require File.join(plugin_root, 'app', 'models', 'password_validator')
  require File.join(plugin_root, 'lib', 'password_policy_utils')
  
  Rails.logger.debug "Password Policy Plugin: 組件載入完成"
end

# =============================================================================
# 初始化鉤子系統
# =============================================================================
def initialize_hooks
  PasswordPolicyHooks::Hooks.after_plugins_loaded
  Rails.logger.debug "Password Policy Plugin: 鉤子系統初始化完成"
end

# =============================================================================
# 驗證和清理設定
# =============================================================================
def validate_and_clean_settings
  settings = Setting.plugin_password_policy
  return unless settings
  
  # 驗證配置
  errors = PasswordPolicyUtils::ConfigValidator.validate_config(settings)
  
  if errors.any?
    log_config_validation_warnings(errors)
    clean_configuration(settings)
  end
  
  Rails.logger.info "Password Policy Plugin: 設定驗證完成"
rescue => e
  Rails.logger.error "Password Policy Plugin: 設定驗證失敗 - #{e.message}"
end

# =============================================================================
# 清理配置
# =============================================================================
def clean_configuration(settings)
  cleaned_settings = PasswordPolicyUtils::ConfigValidator.clean_config(settings)
  Setting.plugin_password_policy = cleaned_settings
  Rails.logger.info "Password Policy Plugin: 配置已自動清理"
end

# =============================================================================
# 日誌記錄函數
# =============================================================================
def log_initialization_error(error)
  Rails.logger.error "Password Policy Plugin: 初始化失敗 - #{error.message}"
  Rails.logger.error error.backtrace.join("\n")
end

def log_config_validation_warnings(errors)
  Rails.logger.warn "Password Policy Plugin: 配置驗證發現問題: #{errors.join(', ')}"
end 