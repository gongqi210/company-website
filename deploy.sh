#!/bin/bash
set -e

echo "=== 公司官网部署脚本 ==="
echo "工作目录: $(pwd)"

# 检查GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误: GITHUB_TOKEN 环境变量未设置"
    echo "请设置 GITHUB_TOKEN 环境变量，或通过以下方式提供:"
    echo "export GITHUB_TOKEN=your_token_here"
    exit 1
fi

echo "✅ GitHub令牌可用 (长度: ${#GITHUB_TOKEN})"

# 使用令牌认证GitHub CLI
echo "正在认证GitHub CLI..."
echo "$GITHUB_TOKEN" | gh auth login --with-token
if [ $? -ne 0 ]; then
    echo "❌ GitHub认证失败"
    exit 1
fi
echo "✅ GitHub认证成功"

# 创建仓库
REPO_NAME="company-website"
echo "正在创建仓库: $REPO_NAME"
gh repo create "$REPO_NAME" --public --push --source=. --remote=origin
if [ $? -ne 0 ]; then
    echo "❌ 仓库创建失败"
    exit 1
fi
echo "✅ 仓库创建成功"

# 配置GitHub Pages
echo "正在配置GitHub Pages..."
gh api -X POST "/repos/$(gh api user | jq -r .login)/$REPO_NAME/pages" \
    -f source='{"branch":"main","path":"/"}' \
    --silent
if [ $? -ne 0 ]; then
    echo "⚠️  Pages配置可能已存在或需要手动配置"
fi

# 获取Pages URL
echo "获取部署URL..."
sleep 5  # 等待Pages配置
PAGES_URL="https://$(gh api user | jq -r .login).github.io/$REPO_NAME"
echo "✅ 官网部署完成!"
echo "🔗 官网URL: $PAGES_URL"
echo "📊 GitHub Pages状态: https://github.com/$(gh api user | jq -r .login)/$REPO_NAME/settings/pages"

# 输出供CMO使用
echo ""
echo "=== 部署完成 ==="
echo "官网URL: $PAGES_URL"
echo "请将此URL提供给CMO进行社交媒体宣传。"

exit 0
