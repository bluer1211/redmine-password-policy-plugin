#!/bin/bash

# Password Policy Plugin v2.1.2 - Git 準備腳本
# 用於準備上傳到 GitHub

echo "🚀 Password Policy Plugin v2.1.2 - Git 準備"
echo "=============================================="

# 檢查是否在正確的目錄
if [ ! -f "init.rb" ]; then
    echo "❌ 錯誤: 請在 password_policy 插件目錄中運行此腳本"
    exit 1
fi

echo "✅ 當前目錄: $(pwd)"

# 初始化 Git 倉庫（如果不存在）
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 倉庫..."
    git init
    echo "✅ Git 倉庫已初始化"
else
    echo "✅ Git 倉庫已存在"
fi

# 添加所有文件
echo "📁 添加文件到 Git..."
git add .

# 檢查狀態
echo "📊 Git 狀態:"
git status

# 提交變更
echo "💾 提交變更..."
git commit -m "Release v2.1.2: Fix password validator loading and enhance keyboard pattern detection

- 🐛 Fix password validator loading issue
- 🔧 Improve plugin initialization mechanism  
- 🛡️ Enhance keyboard pattern detection algorithm
- ✅ Fix continuous keyboard password blocking
- 📊 Add detailed logging
- 🧪 Pass all keyboard pattern password tests

Tested passwords that are now properly blocked:
- !QAZ2wsx3edc, %TGByhnujm, #EDC$RFVtgb
- ！QAZedc%TGB, $RFV%TGBujm, #EDC%TGBik
- ！QAZwsxedc

100% blocking rate achieved for keyboard pattern passwords."

echo "✅ 變更已提交"

# 顯示提交信息
echo "📝 最新提交:"
git log --oneline -1

echo ""
echo "🎉 Git 準備完成！"
echo ""
echo "下一步操作:"
echo "1. 在 GitHub 上創建倉庫: redmine-password-policy-plugin"
echo "2. 添加遠程倉庫:"
echo "   git remote add origin https://github.com/bluer1211/redmine-password-policy-plugin.git"
echo "3. 推送到 GitHub:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "4. 創建 Release v2.1.2"
echo ""
echo "📋 準備文件:"
echo "- README.md (已更新)"
echo "- RELEASE_v2.1.2.md (發布說明)"
echo "- FIXES_SUMMARY.md (修復總結)"
echo "- GITHUB_READY_CHECKLIST.md (準備清單)"
echo ""
echo "🚀 準備上傳到 GitHub！"
