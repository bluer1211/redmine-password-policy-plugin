#!/usr/bin/env ruby
# 測試執行腳本（分流：stub / real integration）
# 用法:
#   ruby test/run_tests.rb
#   ruby test/run_tests.rb --stub-only
#   ruby test/run_tests.rb --integration-only

require 'open3'
require 'time'

class TestRunner
  Result = Struct.new(:name, :ok, :exit_code, :duration_s, :output)

  def initialize(args)
    @run_stub = !args.include?('--integration-only')
    @run_integration = !args.include?('--stub-only')
    @start = Time.now
    @results = []
  end

  def run
    banner

    run_stub_suite if @run_stub
    run_real_integration_suite if @run_integration

    summary
    write_report

    failed? ? exit(1) : exit(0)
  end

  private

  def banner
    puts '=' * 80
    puts '🔐 密碼政策插件測試套件（分流模式）'
    puts '=' * 80
    puts "開始時間: #{@start.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "測試環境: Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM})"
    puts "執行組別: #{[@run_stub ? 'stub' : nil, @run_integration ? 'integration' : nil].compact.join(' + ')}"
    puts '=' * 80
  end

  def run_stub_suite
    puts "\n🧪 [stub] 執行 test/test_helper.rb 內建測試..."
    cmd = 'ruby test/test_helper.rb'
    @results << run_cmd('stub suite', cmd)
  end

  def run_real_integration_suite
    puts "\n🔍 [integration] 執行 test/integration/password_policy_integration_test.rb ..."
    cmd = 'ruby test/integration/password_policy_integration_test.rb'
    @results << run_cmd('integration suite', cmd)
  end

  def run_cmd(name, cmd)
    started = Time.now
    out, status = Open3.capture2e(cmd)
    duration = Time.now - started

    puts "--- #{name} output ---"
    puts out
    puts "--- end #{name} output ---"

    ok = status.success?
    puts(ok ? "✅ #{name} 通過 (#{duration.round(3)}s)" : "❌ #{name} 失敗 (exit=#{status.exitstatus}, #{duration.round(3)}s)")

    Result.new(name, ok, status.exitstatus, duration, out)
  end

  def failed?
    @results.any? { |r| !r.ok }
  end

  def summary
    puts "\n📊 測試總結"
    puts '-' * 80
    @results.each do |r|
      icon = r.ok ? '✅' : '❌'
      puts "#{icon} #{r.name.ljust(18)} | exit=#{r.exit_code} | #{r.duration_s.round(3)}s"
    end

    passed = @results.count(&:ok)
    total = @results.size
    puts '-' * 80
    puts "通過: #{passed}/#{total}"
    puts "總耗時: #{(Time.now - @start).round(3)}s"
  end

  def write_report
    path = File.join(__dir__, 'test_results.txt')
    File.open(path, 'w:utf-8') do |f|
      f.puts '密碼政策插件測試報告（分流模式）'
      f.puts '=' * 60
      f.puts "開始時間: #{@start.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "結束時間: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts

      @results.each do |r|
        f.puts "[#{r.name}] #{r.ok ? 'PASS' : 'FAIL'}"
        f.puts "  exit_code: #{r.exit_code}"
        f.puts "  duration_s: #{r.duration_s.round(3)}"
        f.puts '  output:'
        safe_output = r.output.encode('UTF-8', invalid: :replace, undef: :replace, replace: '�')
        f.puts safe_output.lines.first(120).map { |line| "    #{line}" }
        f.puts
      end

      passed = @results.count(&:ok)
      total = @results.size
      f.puts "總結: #{passed}/#{total} 通過"
    end

    puts "\n📄 報告已寫入: #{path}"
  end
end

if __FILE__ == $0
  TestRunner.new(ARGV).run
end
