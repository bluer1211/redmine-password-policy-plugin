#!/usr/bin/env ruby
# 密碼政策插件測試執行腳本
# 用法: ruby run_tests.rb [選項]

require_relative 'test_helper'

# 測試執行器
class TestExecutor
  def initialize
    @test_results = []
    @start_time = Time.now
  end

  def run_all_tests
    puts "=" * 80
    puts "🔐 密碼政策插件完整測試套件"
    puts "=" * 80
    puts "開始時間: #{@start_time.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "測試環境: Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM})"
    puts "=" * 80

    # 運行所有測試
    run_integration_tests
    
    # 生成報告
    generate_report
    
    puts "=" * 80
    puts "測試完成！"
    puts "結束時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "總耗時: #{Time.now - @start_time} 秒"
    puts "=" * 80
  end

  private

  def run_integration_tests
    puts "\n🔍 運行整合測試..."
    puts "-" * 60
    
    test_suite = PasswordPolicyIntegrationTest.new("test_user_registration_with_weak_password")
    test_methods = PasswordPolicyIntegrationTest.instance_methods.grep(/^test_/)
    
    puts "發現 #{test_methods.length} 個測試方法"
    puts "-" * 60
    
    test_methods.each_with_index do |method_name, index|
      begin
        puts "[#{index + 1}/#{test_methods.length}] 運行 #{method_name}..."
        
        test_suite.setup if test_suite.respond_to?(:setup)
        start_time = Time.now
        test_suite.send(method_name)
        end_time = Time.now
        
        duration = (end_time - start_time) * 1000 # 轉換為毫秒
        test_suite.teardown if test_suite.respond_to?(:teardown)
        
        @test_results << {
          method: method_name,
          status: :passed,
          duration: duration,
          error: nil
        }
        
        puts "  ✅ #{method_name} (#{duration.round(2)}ms)"
        
      rescue => e
        duration = Time.now - start_time rescue 0
        @test_results << {
          method: method_name,
          status: :failed,
          duration: duration * 1000,
          error: e.message
        }
        
        puts "  ❌ #{method_name} - 失敗: #{e.message}"
        puts "     #{e.backtrace.first}"
      end
    end
  end

  def generate_report
    puts "\n📊 測試報告"
    puts "-" * 60
    
    total_tests = @test_results.length
    passed_tests = @test_results.count { |r| r[:status] == :passed }
    failed_tests = @test_results.count { |r| r[:status] == :failed }
    
    puts "總測試數: #{total_tests}"
    puts "通過測試: #{passed_tests} ✅"
    puts "失敗測試: #{failed_tests} ❌"
    puts "成功率: #{(passed_tests.to_f / total_tests * 100).round(2)}%"
    
    if failed_tests > 0
      puts "\n❌ 失敗的測試:"
      @test_results.select { |r| r[:status] == :failed }.each do |result|
        puts "  - #{result[:method]}: #{result[:error]}"
      end
    end
    
    puts "\n⏱️  效能統計:"
    durations = @test_results.map { |r| r[:duration] }
    avg_duration = durations.sum / durations.length
    max_duration = durations.max
    min_duration = durations.min
    
    puts "  平均執行時間: #{avg_duration.round(2)}ms"
    puts "  最長執行時間: #{max_duration.round(2)}ms"
    puts "  最短執行時間: #{min_duration.round(2)}ms"
    
    # 生成詳細報告
    generate_detailed_report
  end

  def generate_detailed_report
    report_file = File.join(File.dirname(__FILE__), 'test_results.txt')
    
    File.open(report_file, 'w', encoding: 'UTF-8') do |f|
      f.puts "密碼政策插件測試報告"
      f.puts "=" * 50
      f.puts "生成時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "測試環境: Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM})"
      f.puts ""
      
      f.puts "測試統計:"
      total_tests = @test_results.length
      passed_tests = @test_results.count { |r| r[:status] == :passed }
      failed_tests = @test_results.count { |r| r[:status] == :failed }
      
      f.puts "  總測試數: #{total_tests}"
      f.puts "  通過測試: #{passed_tests}"
      f.puts "  失敗測試: #{failed_tests}"
      f.puts "  成功率: #{(passed_tests.to_f / total_tests * 100).round(2)}%"
      f.puts ""
      
      f.puts "詳細結果:"
      @test_results.each do |result|
        status_icon = result[:status] == :passed ? "✅" : "❌"
        f.puts "  #{status_icon} #{result[:method]} (#{result[:duration].round(2)}ms)"
        if result[:error]
          f.puts "    錯誤: #{result[:error]}"
        end
      end
      
      f.puts ""
      f.puts "效能統計:"
      durations = @test_results.map { |r| r[:duration] }
      avg_duration = durations.sum / durations.length
      max_duration = durations.max
      min_duration = durations.min
      
      f.puts "  平均執行時間: #{avg_duration.round(2)}ms"
      f.puts "  最長執行時間: #{max_duration.round(2)}ms"
      f.puts "  最短執行時間: #{min_duration.round(2)}ms"
    end
    
    puts "\n📄 詳細報告已生成: #{report_file}"
  end
end

# 主執行邏輯
if __FILE__ == $0
  executor = TestExecutor.new
  executor.run_all_tests
end
