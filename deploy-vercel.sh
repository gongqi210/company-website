#!/bin/bash
set -e

echo "=== AI Tech Company 官网 Vercel 部署脚本 ==="
echo "工作目录: $(pwd)"
echo "部署时间: $(date -u '+%Y-%m-%d %H:%M UTC')"

# 检查 Vercel 认证
if [ -z "$VERCEL_TOKEN" ]; then
    echo "❌ 错误: VERCEL_TOKEN 环境变量未设置"
    echo "请设置 VERCEL_TOKEN 环境变量，或通过以下方式提供:"
    echo "export VERCEL_TOKEN=your_vercel_token_here"
    echo "或执行交互式登录: vercel login"
    exit 1
fi

echo "✅ Vercel 令牌可用 (长度: ${#VERCEL_TOKEN})"

# 使用令牌认证 Vercel CLI
echo "正在认证 Vercel CLI..."
vercel --token "$VERCEL_TOKEN" whoami
if [ $? -ne 0 ]; then
    echo "❌ Vercel 认证失败，请检查令牌有效性"
    exit 1
fi
echo "✅ Vercel 认证成功"

# 部署到生产环境
echo "正在部署到 Vercel 生产环境..."
DEPLOY_OUTPUT=$(vercel --token "$VERCEL_TOKEN" --prod --yes 2>&1)
DEPLOY_EXIT_CODE=$?

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    # 提取部署 URL
    DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o "https://[a-zA-Z0-9.-]*\.vercel\.app" | head -1)
    if [ -n "$DEPLOY_URL" ]; then
        echo "✅ 官网部署成功!"
        echo "🔗 官网 URL: $DEPLOY_URL"
        
        # 保存 URL 到文件供 CMO 使用
        echo "$DEPLOY_URL" > .deployed-url.txt
        echo "📄 部署 URL 已保存至: .deployed-url.txt"
        
        # 输出供 CMO 使用
        echo ""
        echo "=== 部署完成 ==="
        echo "官网 URL: $DEPLOY_URL"
        echo "请将此 URL 提供给 CMO 进行社交媒体宣传。"
        echo "如需配置自定义域名，请执行: vercel --token \$VERCEL_TOKEN domains add aitechcompany.com"
    else
        echo "⚠️  部署成功但无法提取 URL，请检查输出:"
        echo "$DEPLOY_OUTPUT"
    fi
else
    echo "❌ 部署失败，退出码: $DEPLOY_EXIT_CODE"
    echo "错误输出:"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi

exit 0