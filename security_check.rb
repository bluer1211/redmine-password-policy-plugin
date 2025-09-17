#!/usr/bin/env ruby
# =============================================================================
# Redmine Security Checker - Redmine 安全檢查腳本
# =============================================================================
# 此腳本用於檢查 Redmine 系統中的潛在安全問題
# 包括使用者權限、專案設定、附件安全等
# =============================================================================

require 'fileutils'
require 'json'

# =============================================================================
# Redmine 安全檢查器
# =============================================================================
class RedmineSecurityChecker
  # 初始化檢查器
  def initialize
    @issues = []           # 嚴重問題
    @warnings = []         # 警告
    @recommendations = []  # 建議
    @check_time = Time.now
  end

  # 執行所有安全檢查
  def run_all_checks
    display_header
    run_security_checks
    generate_report
  end

  private

  # =============================================================================
  # 顯示檢查標題
  # =============================================================================
  def display_header
    puts "🔍 Redmine 安全檢查開始..."
    puts "=" * 60
    puts "檢查時間: #{@check_time.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "Redmine 版本: #{Redmine::VERSION}"
    puts "=" * 60
  end

  # =============================================================================
  # 執行所有安全檢查項目
  # =============================================================================
  def run_security_checks
    check_user_permissions
    check_project_settings
    check_attachments
    check_wiki_pages
    check_issues
    check_system_settings
    check_logs
    check_password_policy
  end

  # =============================================================================
  # 檢查使用者權限
  # =============================================================================
  def check_user_permissions
    puts "\n👥 檢查使用者權限..."
    
    # 檢查管理員帳號數量
    admin_users = User.where(admin: true)
    if admin_users.count > 3
      @warnings << "管理員帳號數量過多 (#{admin_users.count} 個)"
    end

    # 檢查最近登入的管理員
    recent_admin_logins = admin_users.where('last_login_on > ?', 30.days.ago)
    if recent_admin_logins.count == 0
      @warnings << "最近 30 天內沒有管理員登入記錄"
    end

    # 檢查非活躍使用者
    inactive_users = User.where('last_login_on < ?', 90.days.ago).where(admin: false)
    if inactive_users.count > 0
      @recommendations << "建議清理 #{inactive_users.count} 個非活躍使用者帳號"
    end

    # 檢查密碼過期的使用者
    check_password_expiration
  end

  # =============================================================================
  # 檢查密碼過期
  # =============================================================================
  def check_password_expiration
    # 檢查是否有密碼過期的使用者
    expired_users = User.where('password_changed_on < ?', 90.days.ago)
    if expired_users.count > 0
      @warnings << "發現 #{expired_users.count} 個密碼超過 90 天未更新的使用者"
    end
  end

  # =============================================================================
  # 檢查專案設定
  # =============================================================================
  def check_project_settings
    puts "📁 檢查專案設定..."
    
    # 檢查公開專案
    public_projects = Project.where(is_public: true)
    if public_projects.count > 0
      @recommendations << "發現 #{public_projects.count} 個公開專案，請確認不包含機敏資料"
    end

    # 檢查私人專案
    private_projects = Project.where(is_public: false)
    puts "  私人專案數量: #{private_projects.count}"
  end

  # =============================================================================
  # 檢查附件安全
  # =============================================================================
  def check_attachments
    puts "📎 檢查附件..."
    
    # 檢查大檔案附件
    large_attachments = Attachment.where('filesize > ?', 10.megabytes)
    if large_attachments.count > 0
      @warnings << "發現 #{large_attachments.count} 個超過 10MB 的附件"
    end

    # 檢查可疑檔案類型
    check_suspicious_attachments
  end

  # =============================================================================
  # 檢查可疑附件
  # =============================================================================
  def check_suspicious_attachments
    suspicious_extensions = ['.exe', '.bat', '.cmd', '.com', '.pif', '.scr', '.vbs', '.js']
    suspicious_attachments = Attachment.where("filename LIKE ?", "%#{suspicious_extensions.join('%')}%")
    
    if suspicious_attachments.count > 0
      @issues << "發現 #{suspicious_attachments.count} 個可疑檔案類型附件"
    end
  end

  # =============================================================================
  # 檢查 Wiki 頁面
  # =============================================================================
  def check_wiki_pages
    puts "📝 檢查 Wiki 頁面..."
    
    # 檢查包含敏感關鍵字的 Wiki 頁面
    sensitive_keywords = [
      'password', '密碼', '帳號', 'account', 'ip', 'IP', 
      'ftp', 'FTP', '身份證', '信用卡', 'credit', 'card'
    ]
    
    sensitive_keywords.each do |keyword|
      wiki_pages = WikiPage.joins(:content).where("wiki_contents.text LIKE ?", "%#{keyword}%")
      if wiki_pages.count > 0
        @issues << "Wiki 頁面中包含關鍵字 '#{keyword}' 的頁面: #{wiki_pages.count} 個"
      end
    end
  end

  # =============================================================================
  # 檢查議題
  # =============================================================================
  def check_issues
    puts "🎯 檢查議題..."
    
    # 檢查包含敏感關鍵字的議題
    sensitive_keywords = ['password', '密碼', '帳號', 'account', 'ip', 'IP']
    
    sensitive_keywords.each do |keyword|
      issues = Issue.where("subject LIKE ? OR description LIKE ?", "%#{keyword}%", "%#{keyword}%")
      if issues.count > 0
        @warnings << "議題中包含關鍵字 '#{keyword}' 的議題: #{issues.count} 個"
      end
    end
  end

  # =============================================================================
  # 檢查系統設定
  # =============================================================================
  def check_system_settings
    puts "⚙️ 檢查系統設定..."
    
    # 檢查密碼政策設定
    check_password_policy_settings
    
    # 檢查會話設定
    check_session_settings
  end

  # =============================================================================
  # 檢查密碼政策設定
  # =============================================================================
  def check_password_policy_settings
    settings = Setting.plugin_password_policy
    
    if settings && settings['enabled']
      puts "  ✅ 密碼政策插件已啟用"
      
      # 檢查最小密碼長度
      min_length = settings['min_length'] || 8
      if min_length < 8
        @warnings << "密碼最小長度設定過短 (#{min_length})"
      end
      
      # 檢查是否啟用所有安全選項
      security_options = [
        'require_uppercase', 'require_lowercase', 'require_numbers', 
        'require_special_chars', 'prevent_common_passwords'
      ]
      
      disabled_options = security_options.select { |opt| !settings[opt] }
      if disabled_options.any?
        @warnings << "以下安全選項未啟用: #{disabled_options.join(', ')}"
      end
    else
      @issues << "密碼政策插件未啟用"
    end
  end

  # =============================================================================
  # 檢查會話設定
  # =============================================================================
  def check_session_settings
    session_timeout = Setting.session_lifetime || 0
    
    if session_timeout == 0
      @warnings << "會話超時未設定，建議設定適當的超時時間"
    elsif session_timeout > 24.hours
      @warnings << "會話超時時間過長 (#{session_timeout / 1.hour} 小時)"
    end
  end

  # =============================================================================
  # 檢查日誌
  # =============================================================================
  def check_logs
    puts "📋 檢查日誌..."
    
    # 檢查最近的錯誤日誌
    log_file = Rails.root.join('log', 'production.log')
    if File.exist?(log_file)
      recent_errors = `tail -n 1000 #{log_file} | grep -i "error\|exception" | wc -l`.strip.to_i
      if recent_errors > 10
        @warnings << "最近日誌中發現 #{recent_errors} 個錯誤"
      end
    end
  end

  # =============================================================================
  # 生成檢查報告
  # =============================================================================
  def generate_report
    puts "\n" + "=" * 60
    puts "📊 安全檢查報告"
    puts "=" * 60
    
    display_issues
    display_warnings
    display_recommendations
    display_summary
  end

  # =============================================================================
  # 顯示嚴重問題
  # =============================================================================
  def display_issues
    if @issues.any?
      puts "\n❌ 嚴重問題 (#{@issues.count} 個):"
      @issues.each_with_index do |issue, index|
        puts "  #{index + 1}. #{issue}"
      end
    else
      puts "\n✅ 未發現嚴重問題"
    end
  end

  # =============================================================================
  # 顯示警告
  # =============================================================================
  def display_warnings
    if @warnings.any?
      puts "\n⚠️ 警告 (#{@warnings.count} 個):"
      @warnings.each_with_index do |warning, index|
        puts "  #{index + 1}. #{warning}"
      end
    else
      puts "\n✅ 未發現警告"
    end
  end

  # =============================================================================
  # 顯示建議
  # =============================================================================
  def display_recommendations
    if @recommendations.any?
      puts "\n💡 建議 (#{@recommendations.count} 個):"
      @recommendations.each_with_index do |recommendation, index|
        puts "  #{index + 1}. #{recommendation}"
      end
    end
  end

  # =============================================================================
  # 顯示總結
  # =============================================================================
  def display_summary
    total_issues = @issues.count + @warnings.count
    
    puts "\n" + "=" * 60
    puts "📈 檢查總結"
    puts "=" * 60
    puts "嚴重問題: #{@issues.count} 個"
    puts "警告: #{@warnings.count} 個"
    puts "建議: #{@recommendations.count} 個"
    puts "總計: #{total_issues} 個問題"
    
    if total_issues == 0
      puts "\n🎉 恭喜！您的 Redmine 系統安全性良好！"
    elsif @issues.count == 0
      puts "\n⚠️ 系統基本安全，但建議處理上述警告和建議"
    else
      puts "\n🚨 請立即處理上述嚴重問題！"
    end
    
    puts "\n檢查完成時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end

# =============================================================================
# 主執行程序
# =============================================================================
if __FILE__ == $0
  begin
    checker = RedmineSecurityChecker.new
    checker.run_all_checks
  rescue => e
    puts "❌ 檢查過程中發生錯誤: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end 