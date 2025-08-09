module PasswordPolicyHooks
  class Hooks < Redmine::Hook::ViewListener
    # 在用戶模型載入後加入密碼驗證
    def self.after_plugins_loaded
      begin
        User.class_eval do
          # 使用 Rails 6 相容的驗證語法
          validates :password, password: true, if: :password_required?
          
          private
          
          def password_required?
            new_record? || password.present?
          end
        end
        
        Rails.logger.info "Password Policy Plugin: 成功載入密碼驗證器"
      rescue => e
        Rails.logger.error "Password Policy Plugin: 載入失敗 - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
end 