# 快速開始指南

快速部署多個 Claude Code 代理服務，使用 Requesty.ai 作為統一路由存取不同的 LLM 提供商。

## 📋 系統需求

- **Python**: 3.9 或更高版本（支援 3.9, 3.10, 3.11, 3.12, 3.13）
- **套件管理器**: UV（推薦）或 pip
- **Requesty.ai API 金鑰**: 取得自 [Requesty.ai](https://requesty.ai)

## 🚀 3 步驟快速啟動

### 步驟 1: 安裝依賴

```bash
# 使用 UV（推薦）
uv sync

# 或使用 pip
pip install -r requirements.txt
```

### 步驟 2: 設定 API 金鑰

所有代理都使用 **Requesty.ai** 作為統一路由，只需一個 API 金鑰即可存取多個提供商。

#### Kimi-K2 (連接埠 8081)
```bash
cp .env.example .env-requesty-kimi-k2
nano .env-requesty-kimi-k2
```
設定內容：
```bash
# Requesty.ai API Key（所有代理共用）
OPENAI_API_KEY="sk-your-requesty-api-key"
OPENAI_BASE_URL="https://router.requesty.ai/v1"

# Kimi 模型設定（透過 Requesty.ai 路由）
BIG_MODEL="groq/moonshotai/Kimi-K2-Instruct-0905"
MIDDLE_MODEL="groq/moonshotai/Kimi-K2-Instruct-0905"
SMALL_MODEL="groq/moonshotai/Kimi-K2-Instruct-0905"

# 連接埠設定
PORT="8081"

# 必要的自訂 Headers（避免 403 錯誤）
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"

# 客戶端驗證（可選）
ANTHROPIC_API_KEY="dummy"
```

#### GLM-4.6 (連接埠 8082)
```bash
cp .env.example .env-requesty-glm
nano .env-requesty-glm
```
設定內容：
```bash
# Requesty.ai API Key（所有代理共用）
OPENAI_API_KEY="sk-your-requesty-api-key"
OPENAI_BASE_URL="https://router.requesty.ai/v1"

# GLM 模型設定（透過 Requesty.ai 路由）
BIG_MODEL="zai/GLM-4.6"
MIDDLE_MODEL="zai/GLM-4.6"
SMALL_MODEL="zai/GLM-4.6"

# 連接埠設定
PORT="8082"

# 必要的自訂 Headers（避免 403 錯誤）
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"

# 客戶端驗證（可選）
ANTHROPIC_API_KEY="dummy"
```

#### Gemini 2.5 Flash (連接埠 8084)
```bash
cp .env.example .env-requesty-gemini
nano .env-requesty-gemini
```
設定內容：
```bash
# Requesty.ai API Key（所有代理共用）
OPENAI_API_KEY="sk-your-requesty-api-key"
OPENAI_BASE_URL="https://router.requesty.ai/v1"

# Gemini 模型設定（透過 Requesty.ai 路由）
BIG_MODEL="google/gemini-2.5-flash"
MIDDLE_MODEL="google/gemini-2.5-flash"
SMALL_MODEL="google/gemini-2.5-flash"

# 連接埠設定
PORT="8084"

# 必要的自訂 Headers（避免 403 錯誤）
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"

# 客戶端驗證（可選）
ANTHROPIC_API_KEY="dummy"
```

#### MiniMax-M2 (連接埠 8083)
```bash
cp .env.example .env-requesty-minimax-m2
nano .env-requesty-minimax-m2
```
設定內容：
```bash
# Requesty.ai API Key（所有代理共用）
OPENAI_API_KEY="sk-your-requesty-api-key"
OPENAI_BASE_URL="https://router.requesty.ai/v1"

# MiniMax 模型設定（透過 Requesty.ai 路由）
BIG_MODEL="minimaxi/MiniMax-M2"
MIDDLE_MODEL="minimaxi/MiniMax-M2"
SMALL_MODEL="minimaxi/MiniMax-M2"

# 連接埠設定
PORT="8083"

# 必要的自訂 Headers（避免 403 錯誤）
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"

# 客戶端驗證（可選）
ANTHROPIC_API_KEY="dummy"
```

### 步驟 3: 啟動代理服務

#### 方式 1: 使用啟動腳本（推薦）

`start-all-proxies.sh` 已預設設定為啟動所有代理：

```bash
# 檢查腳本設定
cat start-all-proxies.sh | grep "PROXIES="
# 應該看到：
# PROXIES=(
#     "8081:.env-requesty-kimi-k2:Kimi-K2"
#     "8082:.env-requesty-glm:GLM-4.6"
#     "8083:.env-requesty-minimax-m2:MiniMax-M2"
#     "8084:.env-requesty-gemini:Gemini-2.5-Flash"
# )

# 啟動所有代理
./start-all-proxies.sh start

# 查看狀態（會顯示每個代理的模型設定）
./start-all-proxies.sh status
```

#### 方式 2: 手動啟動單一代理

```bash
# 啟動 GLM-4.6 代理
python start_proxy.py --env .env-requesty-glm

# 啟動 Kimi-K2 代理
python start_proxy.py --env .env-requesty-kimi-k2

# 啟動 Gemini 代理
python start_proxy.py --env .env-requesty-gemini

# 啟動 MiniMax 代理
python start_proxy.py --env .env-requesty-minimax-m2
```

## 🎯 使用代理

啟動成功後，選擇要使用的代理並設定環境變數：

### 使用 GLM-4.6 (連接埠 8082)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8082
export ANTHROPIC_API_KEY=dummy
claude
```

### 使用 Kimi-K2 (連接埠 8081)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8081
export ANTHROPIC_API_KEY=dummy
claude
```

### 使用 Gemini (連接埠 8084)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8084
export ANTHROPIC_API_KEY=dummy
claude
```

### 使用 MiniMax (連接埠 8083)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8083
export ANTHROPIC_API_KEY=dummy
claude
```

## 🧪 測試設定

### 健康檢查
```bash
# 檢查所有代理（會顯示實際模型設定）
curl http://localhost:8081/health | jq
curl http://localhost:8082/health | jq
curl http://localhost:8083/health | jq
curl http://localhost:8084/health | jq
```

健康檢查回應範例：
```json
{
  "status": "healthy",
  "timestamp": "2025-11-08T10:30:00.123456",
  "server": {
    "host": "0.0.0.0",
    "port": 8082
  },
  "models": {
    "big_model": "zai/GLM-4.6",
    "middle_model": "zai/GLM-4.6",
    "small_model": "zai/GLM-4.6"
  },
  "api_status": {
    "openai_api_configured": true,
    "api_key_valid": true,
    "client_api_key_validation": true,
    "openai_base_url": "https://router.requesty.ai/v1"
  }
}
```

### 快速測試
```bash
# 測試 GLM-4.6
curl -X POST http://localhost:8082/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: dummy" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

## 📋 Requesty.ai 模型路由表

所有代理都使用 Requesty.ai 作為統一路由，實際的模型格式：

| 服務名稱 | 連接埠 | Requesty.ai 模型路徑 | 環境設定檔 |
|---------|--------|---------------------|-----------|
| Kimi-K2 | 8081 | `groq/moonshotai/Kimi-K2-Instruct-0905` | .env-requesty-kimi-k2 |
| GLM-4.6 | 8082 | `zai/GLM-4.6` | .env-requesty-glm |
| MiniMax-M2 | 8083 | `minimaxi/MiniMax-M2` | .env-requesty-minimax-m2 |
| Gemini 2.5 | 8084 | `google/gemini-2.5-flash` | .env-requesty-gemini |

**注意：** 所有代理使用相同的 Requesty.ai API 金鑰，只需設定一次即可。

## 🔧 管理命令

```bash
# 啟動所有代理
./start-all-proxies.sh start

# 停止所有代理
./start-all-proxies.sh stop

# 重新啟動所有代理
./start-all-proxies.sh restart

# 查看代理狀態（顯示實際模型設定和 API URL）
./start-all-proxies.sh status

# 清理舊日誌（超過 3 天）
./start-all-proxies.sh clean-logs
```

## 📊 查看日誌

```bash
# 即時查看日誌
tail -f logs/GLM-4.6.log
tail -f logs/Kimi-K2.log
tail -f logs/MiniMax-M2.log
tail -f logs/Gemini-2.5-Flash.log

# 查看所有代理日誌
tail -f logs/*.log
```

## 🐛 Debug 模式

需要詳細日誌時，在環境設定檔中設定：
```bash
LOG_LEVEL="DEBUG"
```

然後重啟對應的代理。

## ⚙️ 重要設定說明

### 必要的自訂 Headers

Requesty.ai 需要特定的 HTTP Headers 來避免 403 錯誤：

```bash
# 這兩個 Header 必須設定
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"
```

### API 金鑰說明

- **OPENAI_API_KEY**: 設定為你的 Requesty.ai API 金鑰（所有代理共用）
- **ANTHROPIC_API_KEY**: 設定為 `dummy` 即可（用於 Claude Code 客戶端驗證）

### 連接埠分配

確保每個代理使用不同的連接埠避免衝突：
- Kimi-K2: 8081
- GLM-4.6: 8082
- MiniMax-M2: 8083
- Gemini 2.5: 8084

## 🔗 Requesty.ai 模型格式

Requesty.ai 使用特殊的模型路徑格式：`provider/vendor/model-name`

範例：
- `groq/moonshotai/Kimi-K2-Instruct-0905` - Moonshot AI 的 Kimi 模型
- `zai/GLM-4.6` - 智譜 AI 的 GLM 模型
- `google/gemini-2.5-flash` - Google 的 Gemini 模型
- `minimaxi/MiniMax-M2` - MiniMax 的模型

完整的可用模型列表請參考 [Requesty.ai 文檔](https://requesty.ai)。

## 💡 提示

- ✅ 所有代理使用同一個 Requesty.ai API 金鑰
- ✅ 必須設定自訂 Headers 避免 403 錯誤
- ✅ 每個代理使用不同的連接埠
- ✅ 定期清理日誌檔案（自動保留 3 天）
- ✅ 使用 `status` 命令檢查所有服務是否正常
- ✅ 日誌檔案位於 `logs/` 目錄

## 🚨 故障排查

### 403 Forbidden 錯誤

如果遇到 403 錯誤，確認已設定必要的 Headers：
```bash
CUSTOM_HEADER_USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeProxy/1.0)"
CUSTOM_HEADER_ACCEPT="application/json"
```

### 連接埠被佔用

```bash
# 查看佔用連接埠的程序
lsof -i :8081
lsof -i :8082
lsof -i :8083
lsof -i :8084

# 或使用腳本自動處理
./start-all-proxies.sh start
# 腳本會自動詢問是否終止佔用程序
```

### API 金鑰無效

確認你的 Requesty.ai API 金鑰有效：
```bash
# 檢查健康狀態
curl http://localhost:8082/health | jq '.api_status'
```

## 🔗 更多資訊

- 完整文件：參閱 [README.md](README.md)
- 啟動腳本說明：參閱 [START_PROXIES.md](START_PROXIES.md)
- 專案設定：參閱 [CLAUDE.md](CLAUDE.md)

---

現在你可以透過 Requesty.ai 統一路由使用多個 LLM 提供商與 Claude Code 一起工作了！🎉
