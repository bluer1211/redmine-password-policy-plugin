# 密碼政策工具類別
module PasswordPolicyUtils
  # 密碼強度評估工具
  class StrengthEvaluator
    # 計算密碼強度分數（0-100）
    def self.calculate_score(password)
      return 0 if password.blank?
      
      score = 0
      
      # 長度分數（最高25分）
      score += [password.length * 2, 25].min
      
      # 字符類型分數（最高25分）
      score += 5 if password.match(/[A-Z]/)  # 大寫字母
      score += 5 if password.match(/[a-z]/)  # 小寫字母
      score += 5 if password.match(/\d/)     # 數字
      score += 5 if password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)  # 特殊字符
      
      # 複雜度分數（最高25分）
      score += 10 if password.length >= 12
      score += 10 if password.match(/[A-Z]/) && password.match(/[a-z]/) && password.match(/\d/) && password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      score += 5 if password.length >= 16
      
      # 唯一性分數（最高25分）
      unique_chars = password.chars.uniq.length
      score += [unique_chars * 2, 25].min
      
      [score, 100].min
    end
    
    # 獲取強度等級描述
    def self.get_strength_level(score)
      case score
      when 0..20
        { level: 'very_weak', description: '非常弱', color: '#ff4444' }
      when 21..40
        { level: 'weak', description: '弱', color: '#ff8800' }
      when 41..60
        { level: 'medium', description: '中等', color: '#ffaa00' }
      when 61..80
        { level: 'strong', description: '強', color: '#00aa00' }
      when 81..100
        { level: 'very_strong', description: '非常強', color: '#008800' }
      else
        { level: 'unknown', description: '未知', color: '#999999' }
      end
    end
  end
  
  # 密碼建議生成器
  class SuggestionGenerator
    # 生成密碼建議
    def self.generate_suggestions(password, errors = [])
      suggestions = []
      
      # 基於錯誤生成建議
      errors.each do |error|
        case error
        when :too_short
          suggestions << "增加密碼長度到至少8個字符"
        when :must_contain_uppercase
          suggestions << "添加至少一個大寫字母（如A-Z）"
        when :must_contain_lowercase
          suggestions << "添加至少一個小寫字母（如a-z）"
        when :must_contain_numbers
          suggestions << "添加至少一個數字（如0-9）"
        when :must_contain_special_chars
          suggestions << "添加至少一個特殊字符（如!@#$%^&*）"
        when :contains_sequential_chars
          suggestions << "避免使用連續字符（如123456、abcdef）"
        when :contains_keyboard_patterns
          suggestions << "避免使用鍵盤位置模式（如1qaz、WSX、3edc、147、qwe等）。這些模式容易被猜測。"
        when :contains_repetitive_chars
          suggestions << "避免使用重複字符（如aaa、111）"
        when :is_common_password
          suggestions << "選擇更獨特和複雜的密碼"
        end
      end
      
      # 基於密碼強度生成建議
      score = StrengthEvaluator.calculate_score(password)
      if score < 40
        suggestions << "考慮使用更複雜的密碼組合"
      end
      
      suggestions.uniq
    end
    
    # 生成強密碼範例
    def self.generate_examples
      [
        "MyS3cur3P@ssw0rd!",
        "N3wS3cur3P@ssw0rd!",
        "C0mpl3xP@ssw0rd!",
        "S3cur3P@ssw0rd2024!",
        "V3ryS3cur3P@ssw0rd!"
      ]
    end
  end
  
  # 配置驗證器
  class ConfigValidator
    # 驗證插件配置
    def self.validate_config(settings)
      errors = []
      
      # 驗證啟用設定
      unless [true, false, '1', '0', 1, 0].include?(settings['enabled'])
        errors << "enabled 必須是布林值"
      end
      
      # 驗證最小長度
      min_length = settings['min_length'].to_i
      if min_length < 1 || min_length > 50
        errors << "最小長度必須在1-50之間"
      end
      
      # 驗證布林值設定
      boolean_settings = [
        'require_uppercase',
        'require_lowercase', 
        'require_numbers',
        'require_special_chars',
        'prevent_common_passwords',
        'prevent_sequential_chars',
        'prevent_keyboard_patterns',
        'prevent_repetitive_chars'
      ]
      
      boolean_settings.each do |setting|
        unless [true, false, '1', '0', 1, 0].include?(settings[setting])
          errors << "#{setting} 必須是布林值"
        end
      end
      
      errors
    end
    
    # 清理配置
    def self.clean_config(settings)
      cleaned = settings.dup
      
      # 清理啟用設定
      cleaned['enabled'] = cleaned['enabled'].to_s == 'true' || cleaned['enabled'].to_s == '1'
      
      # 清理最小長度
      min_length = cleaned['min_length'].to_i
      cleaned['min_length'] = [[min_length, 1].max, 50].min
      
      # 清理布林值
      boolean_settings = [
        'require_uppercase',
        'require_lowercase', 
        'require_numbers',
        'require_special_chars',
        'prevent_common_passwords',
        'prevent_sequential_chars',
        'prevent_keyboard_patterns',
        'prevent_repetitive_chars'
      ]
      
      boolean_settings.each do |setting|
        cleaned[setting] = cleaned[setting].to_s == 'true' || cleaned[setting].to_s == '1'
      end
      
      cleaned
    end
    
    # 檢查插件是否啟用
    def self.enabled?
      settings = Setting.plugin_password_policy
      return false unless settings
      settings['enabled'].to_s == 'true' || settings['enabled'].to_s == '1'
    end
  end
end
