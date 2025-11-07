#!/bin/bash

# 測試 Go Claude Code Proxy 與 Claude CLI

echo "🧪 測試 Go Claude Code Proxy (GLM-4.6) 與 Claude CLI"
echo "=================================================="
echo ""

# 設置環境變數
export ANTHROPIC_BASE_URL=http://localhost:8090
export ANTHROPIC_API_KEY=dummy
export ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

echo "📝 環境變數設置："
echo "   ANTHROPIC_BASE_URL: $ANTHROPIC_BASE_URL"
echo "   ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY"
echo "   ANTHROPIC_MODEL: $ANTHROPIC_MODEL"
echo ""

# 測試簡單的請求
echo "1️⃣ 測試簡單請求..."
echo "請用中文說 Hello，只需要回答一句話即可" | claude 2>&1 | head -30

echo ""
echo "✅ 測試完成！"

