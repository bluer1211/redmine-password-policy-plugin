#!/usr/bin/env ruby
# Redmine 安全檢查腳本
# 用於檢查 Redmine 系統中的潛在安全問題

require 'fileutils'
require 'json'

class RedmineSecurityChecker
  def initialize
    @issues = []
    @warnings = []
    @recommendations = []
  end

  def run_all_checks
    puts "🔍 開始 Redmine 安全檢查..."
    puts "=" * 50

    check_user_permissions
    check_project_settings
    check_attachments
    check_wiki_pages
    check_issues
    check_system_settings
    check_logs

    generate_report
  end

  private

  def check_user_permissions
    puts "\n👥 檢查使用者權限..."
    
    # 檢查管理員帳號
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
  end

  def check_project_settings
    puts "📁 檢查專案設定..."
    
    # 檢查公開專案
    public_projects = Project.where(is_public: true)
    @recommendations << "發現 #{public_projects.count} 個公開專案，請確認不包含機敏資料"

    # 檢查私人專案
    private_projects = Project.where(is_public: false)
    puts "  私人專案數量: #{private_projects.count}"
  end

  def check_attachments
    puts "📎 檢查附件..."
    
    # 檢查附件大小
    large_attachments = Attachment.where('filesize > ?', 10.megabytes)
    if large_attachments.count > 0
      @warnings << "發現 #{large_attachments.count} 個超過 10MB 的附件"
    end

    # 檢查附件類型
    suspicious_extensions = ['.exe', '.bat', '.cmd', '.com', '.pif', '.scr', '.vbs']
    suspicious_attachments = Attachment.where("filename LIKE ?", "%#{suspicious_extensions.join('%')}%")
    if suspicious_attachments.count > 0
      @issues << "發現 #{suspicious_extachments.count} 個可疑檔案類型附件"
    end
  end

  def check_wiki_pages
    puts "📝 檢查 Wiki 頁面..."
    
    # 檢查包含敏感關鍵字的 Wiki 頁面
    sensitive_keywords = ['password', '密碼', '帳號', 'account', 'ip', 'IP', 'ftp', 'FTP', '身份證', '信用卡']
    
    sensitive_keywords.each do |keyword|
      wiki_pages = WikiPage.joins(:content).where("wiki_contents.text LIKE ?", "%#{keyword}%")
      if wiki_pages.count > 0
        @issues << "Wiki 頁面中包含關鍵字 '#{keyword}' 的頁面: #{wiki_pages.count} 個"
      end
    end
  end

  def check_issues
    puts "🎯 檢查議題..."
    
    # 檢查包含敏感關鍵字的議題
    sensitive_keywords = ['password', '密碼', '帳號', 'account', 'ip', 'IP', 'ftp', 'FTP', '身份證', '信用卡']
    
    sensitive_keywords.each do |keyword|
      issues = Issue.where("subject LIKE ? OR description LIKE ?", "%#{keyword}%", "%#{keyword}%")
      if issues.count > 0
        @warnings << "議題中包含關鍵字 '#{keyword}' 的議題: #{issues.count} 個"
      end
    end
  end

  def check_system_settings
    puts "⚙️ 檢查系統設定..."
    
    # 檢查 HTTPS 設定
    if Setting.protocol != 'https'
      @issues << "建議啟用 HTTPS 協議"
    end

    # 檢查會話超時設定
    session_timeout = Setting.session_lifetime.to_i
    if session_timeout == 0 || session_timeout > 24.hours
      @warnings << "建議設定合理的會話超時時間（建議 4-8 小時）"
    end

    # 檢查密碼政策設定
    password_policy = Setting.plugin_password_policy
    if password_policy.nil?
      @recommendations << "建議啟用密碼政策插件"
    end
  end

  def check_logs
    puts "📋 檢查系統日誌..."
    
    # 檢查錯誤日誌
    log_file = Rails.root.join('log', 'production.log')
    if File.exist?(log_file)
      recent_errors = `tail -n 1000 #{log_file} | grep -i "error\|exception" | wc -l`.strip.to_i
      if recent_errors > 10
        @warnings << "最近日誌中發現 #{recent_errors} 個錯誤，建議檢查"
      end
    end

    # 檢查登入失敗記錄
    failed_logins = `tail -n 1000 #{log_file} | grep -i "failed login\|authentication failed" | wc -l`.strip.to_i
    if failed_logins > 5
      @warnings << "發現 #{failed_logins} 次登入失敗記錄，建議檢查是否有攻擊嘗試"
    end
  end

  def generate_report
    puts "\n" + "=" * 50
    puts "📊 安全檢查報告"
    puts "=" * 50

    if @issues.empty? && @warnings.empty? && @recommendations.empty?
      puts "✅ 未發現安全問題"
    else
      unless @issues.empty?
        puts "\n🚨 嚴重問題 (#{@issues.count}):"
        @issues.each_with_index do |issue, index|
          puts "  #{index + 1}. #{issue}"
        end
      end

      unless @warnings.empty?
        puts "\n⚠️ 警告 (#{@warnings.count}):"
        @warnings.each_with_index do |warning, index|
          puts "  #{index + 1}. #{warning}"
        end
      end

      unless @recommendations.empty?
        puts "\n💡 建議 (#{@recommendations.count}):"
        @recommendations.each_with_index do |recommendation, index|
          puts "  #{index + 1}. #{recommendation}"
        end
      end
    end

    puts "\n📅 檢查時間: #{Time.current}"
    puts "🔍 檢查項目: 8 項"
    puts "📈 安全評分: #{calculate_security_score}"
  end

  def calculate_security_score
    total_issues = @issues.count * 3 + @warnings.count * 2 + @recommendations.count
    score = 100 - total_issues * 5
    score = [score, 0].max
    score = [score, 100].min
    
    case score
    when 90..100
      "優秀 (#{score}/100)"
    when 70..89
      "良好 (#{score}/100)"
    when 50..69
      "一般 (#{score}/100)"
    else
      "需要改善 (#{score}/100)"
    end
  end
end

# 執行檢查
if __FILE__ == $0
  checker = RedmineSecurityChecker.new
  checker.run_all_checks
end 