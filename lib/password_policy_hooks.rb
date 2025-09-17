module PasswordPolicyHooks
  class Hooks < Redmine::Hook::ViewListener
    # 在用戶模型載入後加入密碼驗證
    def self.after_plugins_loaded
      begin
        # 確保 User 模型存在
        if defined?(User)
          User.class_eval do
            # 移除現有的密碼驗證器（如果存在）
            _validators[:password]&.reject! { |v| v.class.name == 'PasswordValidator' }
            
            # 添加新的密碼驗證器
            validates :password, password: true, if: :password_required?
            
            private
            
            def password_required?
              new_record? || password.present?
            end
          end
          
          Rails.logger.info "Password Policy Plugin: 成功載入密碼驗證器到 User 模型"
          
          # 驗證驗證器是否正確載入
          if User.validators_on(:password).any? { |v| v.class.name == 'PasswordValidator' }
            Rails.logger.info "Password Policy Plugin: 密碼驗證器確認已載入"
          else
            Rails.logger.warn "Password Policy Plugin: 密碼驗證器載入失敗"
          end
        else
          Rails.logger.error "Password Policy Plugin: User 模型未定義"
        end
      rescue => e
        Rails.logger.error "Password Policy Plugin: 載入失敗 - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
end 