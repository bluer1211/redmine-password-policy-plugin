module PasswordPolicyHooks
  class Hooks < Redmine::Hook::ViewListener
    # 在用戶模型載入後加入密碼驗證
    def self.after_plugins_loaded
      User.class_eval do
        validates :password, password: true, if: :password_required?
        
        private
        
        def password_required?
          new_record? || password.present?
        end
      end
    end
  end
end 