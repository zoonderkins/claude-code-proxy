#!/usr/bin/env python3
"""檢查 OpenAI SDK 發送的 HTTP headers"""

import httpx
from openai import AsyncOpenAI
import asyncio
import json

# 自定義 transport 來攔截請求
class LoggingTransport(httpx.AsyncHTTPTransport):
    async def handle_async_request(self, request):
        print("=" * 80)
        print("📤 OpenAI SDK 發送的請求:")
        print(f"URL: {request.url}")
        print(f"Method: {request.method}")
        print("\n📋 Headers:")
        for key, value in request.headers.items():
            # 隱藏 API key
            if key.lower() == 'authorization':
                print(f"  {key}: Bearer ***...")
            else:
                print(f"  {key}: {value}")
        print("=" * 80)
        print()
        
        # 繼續正常請求
        return await super().handle_async_request(request)

async def test_openai_headers():
    import os
    from dotenv import load_dotenv

    # 載入環境變數
    load_dotenv()

    # 創建帶有自定義 transport 的客戶端
    custom_headers = {
        "User-Agent": "Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)",
        "Accept": "application/json"
    }

    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        raise ValueError("OPENAI_API_KEY environment variable is required")

    base_url = os.getenv('OPENAI_BASE_URL', 'https://api.openai.com/v1')

    client = AsyncOpenAI(
        api_key=api_key,
        base_url=base_url,
        http_client=httpx.AsyncClient(
            transport=LoggingTransport(),
            timeout=30.0
        ),
        default_headers=custom_headers
    )

    try:
        # 發送測試請求
        model = os.getenv('BIG_MODEL', 'gpt-4o')
        print(f"🚀 發送測試請求到 {base_url}...")
        print(f"📦 使用模型: {model}")
        response = await client.chat.completions.create(
            model=model,
            messages=[
                {"role": "user", "content": "Hello"}
            ],
            max_tokens=10
        )
        print(f"✅ 請求成功！")
        print(f"Response: {response.choices[0].message.content}")
    except Exception as e:
        print(f"❌ 請求失敗: {e}")
        print()

if __name__ == "__main__":
    print("🔍 檢查 OpenAI Python SDK 發送的 HTTP Headers")
    print()
    asyncio.run(test_openai_headers())

