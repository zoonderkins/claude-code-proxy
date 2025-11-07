#!/usr/bin/env python3
"""測試 Python 版本的 header 轉換"""

import os
from dotenv import load_dotenv

# 載入環境變數
load_dotenv('.env-requesty-glm')

# 模擬 Python 版本的 header 轉換
def get_custom_headers_python():
    """Python 版本的 header 轉換邏輯"""
    custom_headers = {}
    env_vars = dict(os.environ)
    
    for env_key, env_value in env_vars.items():
        if env_key.startswith('CUSTOM_HEADER_'):
            header_name = env_key[14:]  # Remove 'CUSTOM_HEADER_' prefix
            if header_name:
                # Convert underscores to hyphens for HTTP header format
                header_name = header_name.replace('_', '-')
                custom_headers[header_name] = env_value
    
    return custom_headers

# 模擬 Go 版本的 header 轉換（修復後）
def get_custom_headers_go():
    """Go 版本的 header 轉換邏輯（修復後）"""
    custom_headers = {}
    env_vars = dict(os.environ)
    
    def to_title_case(s):
        """將 header 名稱轉換為標準的 HTTP Header 格式"""
        parts = s.split('-')
        return '-'.join(part.capitalize() for part in parts if part)
    
    for env_key, env_value in env_vars.items():
        if env_key.startswith('CUSTOM_HEADER_'):
            header_name = env_key[14:]  # Remove 'CUSTOM_HEADER_' prefix
            if header_name:
                # Convert underscores to hyphens
                header_name = header_name.replace('_', '-')
                # Title case
                header_name = to_title_case(header_name)
                custom_headers[header_name] = env_value
    
    return custom_headers

print("🔍 對比 Python 和 Go 的 Header 轉換")
print("=" * 60)
print()

python_headers = get_custom_headers_python()
print("Python 版本轉換結果:")
for key, value in python_headers.items():
    print(f"  {key}: {value}")

print()

go_headers = get_custom_headers_go()
print("Go 版本轉換結果（修復後）:")
for key, value in go_headers.items():
    print(f"  {key}: {value}")

print()
print("差異:")
if python_headers == go_headers:
    print("  ✅ 完全相同")
else:
    print("  ❌ 有差異:")
    all_keys = set(python_headers.keys()) | set(go_headers.keys())
    for key in sorted(all_keys):
        py_val = python_headers.get(key, "❌ 缺少")
        go_val = go_headers.get(key, "❌ 缺少")
        if py_val != go_val:
            print(f"    {key}:")
            print(f"      Python: {py_val}")
            print(f"      Go:     {go_val}")

