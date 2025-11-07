# 代理啟動腳本使用說明

## 快速開始

```bash
# 啟動所有代理
./start-all-proxies.sh

# 或明確使用 start 命令
./start-all-proxies.sh start
```

## 所有命令

### 1. 啟動所有代理
```bash
./start-all-proxies.sh start
```
- 自動檢查連接埠占用
- 如果連接埠被占用，會提示是否終止占用程序
- 背景執行所有代理
- 顯示啟動狀態
- **自動顯示每個代理設定的模型資訊**

### 2. 停止所有代理
```bash
./start-all-proxies.sh stop
```
- 優雅停止所有正在執行的代理
- 清理 PID 檔案
- 釋放占用的連接埠

### 3. 重啟所有代理
```bash
./start-all-proxies.sh restart
```
- 等同於先 stop 再 start

### 4. 查看狀態
```bash
./start-all-proxies.sh status
```
- 顯示所有代理的執行狀態
- 顯示 PID 和連接埠資訊
- 顯示日誌檔案位置
- **即時顯示每個代理設定的模型和 API 位址**

### 5. 清理日誌
```bash
./start-all-proxies.sh clean-logs
```
- 手動清理超過 3 天的日誌檔案
- 自動在每次 start/restart 時執行

## 代理設定

腳本會啟動以下三個代理實例：

| 名稱 | 連接埠 | 模型 | 設定檔 |
|------|------|------|----------|
| Kimi-K2 | 8081 | Kimi-K2-Instruct-0905 | .env-requesty-kimi-k2 |
| GLM-4.6 | 8082 | GLM-4.6 | .env-requesty-glm |
| MiniMax-M2 | 8083 | MiniMax-M2 | .env-requesty-minimax-m2 |

## 啟動輸出範例

啟動腳本會自動顯示每個代理設定的模型資訊：

```
================================
啟動代理: GLM-4.6
連接埠: 8082
設定: .env-requesty-glm
================================
正在啟動...
✓ 代理 GLM-4.6 已成功啟動 (PID: 12345)
  日誌: logs/GLM-4.6.log
  PID 檔案: pids/GLM-4.6.pid
正在取得模型設定...
  模型設定:
    BIG (opus): glm-4.6
    MIDDLE (sonnet): glm-4.6
    SMALL (haiku): glm-4-mini
```

查看狀態時也會顯示模型資訊：

```bash
$ ./start-all-proxies.sh status

================================
代理服務狀態
================================

GLM-4.6 (連接埠 8082):
  ✓ 執行中 (PID: 12345)
  日誌: logs/GLM-4.6.log
  模型設定:
    BIG (opus): glm-4.6
    MIDDLE (sonnet): glm-4.6
    SMALL (haiku): glm-4-mini
  API URL: https://open.bigmodel.cn/api/paas/v4
```

## 日誌管理

### 自動日誌清理

腳本會自動管理日誌檔案：

1. **每次啟動時自動歸檔**：舊的 `.log` 檔案會被重新命名為 `.log.時間戳記`
2. **自動清理過期日誌**：超過 3 天的歸檔日誌會被自動刪除
3. **手動清理**：可以隨時執行 `./start-all-proxies.sh clean-logs`

### 設定定時清理（可選）

執行以下命令設定每天凌晨 2:00 自動清理日誌：

```bash
./setup-log-cleanup-cron.sh
```

這會新增一個 cron job，每天自動執行日誌清理。

### 查看即時日誌
```bash
# 查看某個代理的即時日誌
tail -f logs/Kimi-K2.log
tail -f logs/GLM-4.6.log
tail -f logs/MiniMax-M2.log

# 查看所有代理日誌（新終端機視窗）
tail -f logs/*.log
```

### 查看歷史日誌
```bash
# 查看最近 50 行
tail -n 50 logs/Kimi-K2.log

# 查看完整日誌
cat logs/Kimi-K2.log
```

## 使用代理

啟動成功後，可以透過以下方式使用代理：

### 使用 Kimi-K2 (連接埠 8081)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8081
export ANTHROPIC_API_KEY=dummy
claude
```

### 使用 GLM-4.6 (連接埠 8082)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8082
export ANTHROPIC_API_KEY=dummy
claude
```

### 使用 MiniMax-M2 (連接埠 8083)
```bash
export ANTHROPIC_BASE_URL=http://localhost:8083
export ANTHROPIC_API_KEY=dummy
claude
```

## 健康檢查

### 快速健康檢查

```bash
# 檢查代理是否正常執行
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health
```

### 健康檢查回傳資訊

`/health` endpoint 會回傳詳細的服務資訊，包括：

```json
{
  "status": "healthy",
  "timestamp": "2025-11-05T10:30:00.123456",
  "server": {
    "host": "0.0.0.0",
    "port": 8081
  },
  "models": {
    "big_model": "Kimi-K2-Instruct-0905",
    "middle_model": "Kimi-K2-Instruct-0905",
    "small_model": "Kimi-K2-Instruct-0905"
  },
  "api_status": {
    "openai_api_configured": true,
    "api_key_valid": true,
    "client_api_key_validation": false,
    "openai_base_url": "https://api.moonshot.cn/v1"
  }
}
```

**回傳欄位說明：**

- `server.port` - 目前服務執行的連接埠
- `models.big_model` - 處理 Claude opus 請求的模型
- `models.middle_model` - 處理 Claude sonnet 請求的模型
- `models.small_model` - 處理 Claude haiku 請求的模型
- `api_status.openai_base_url` - 實際連接的 API 位址

### 使用 jq 格式化輸出

```bash
# 查看特定連接埠的模型設定
curl -s http://localhost:8081/health | jq '.models'

# 查看所有連接埠的主模型
for port in 8081 8082 8083; do
  echo "Port $port:"
  curl -s http://localhost:$port/health | jq -r '.models.big_model'
done
```

## 故障排查

### 1. 啟動失敗
```bash
# 查看錯誤日誌
cat logs/Kimi-K2.log

# 檢查連接埠占用
lsof -i :8081
lsof -i :8082
lsof -i :8083
```

### 2. 連接埠被占用
腳本會自動檢測連接埠占用，並提示是否終止占用程序。
如果需要手動處理：
```bash
# 查找占用連接埠的程序
lsof -ti :8081

# 終止程序
kill $(lsof -ti :8081)
```

### 3. 檢查程序狀態
```bash
# 查看所有代理程序
ps aux | grep start_proxy.py

# 查看 PID 檔案
ls -la pids/
cat pids/Kimi-K2.pid
```

### 4. 手動清理
```bash
# 停止所有代理
./start-all-proxies.sh stop

# 清理 PID 檔案
rm -rf pids/

# 清理日誌檔案（謹慎操作）
rm -rf logs/
```

## 特性

✅ 自動檢測連接埠占用
✅ 支援 UV 和標準 Python 環境
✅ 彩色輸出，易於閱讀
✅ 獨立的日誌檔案管理
✅ **自動日誌歸檔和清理（保留 3 天）**
✅ PID 檔案追蹤
✅ 啟動驗證
✅ 完整的狀態監控
✅ 優雅的程序停止
✅ 可選的 Cron Job 定時清理

## 檔案結構

```
claude-code-proxy/
├── start-all-proxies.sh          # 主啟動腳本
├── setup-log-cleanup-cron.sh     # Cron 設定腳本
├── logs/                          # 日誌目錄
│   ├── Kimi-K2.log               # 目前日誌
│   ├── Kimi-K2.log.20250104_123456  # 歸檔日誌（3 天後自動刪除）
│   ├── GLM-4.6.log
│   ├── MiniMax-M2.log
│   └── cleanup-cron.log          # Cron 清理日誌
├── pids/                          # PID 檔案目錄
│   ├── Kimi-K2.pid
│   ├── GLM-4.6.pid
│   └── MiniMax-M2.pid
└── .env-requesty-*               # 環境設定檔
```
