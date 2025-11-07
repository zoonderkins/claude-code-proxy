# 日誌自動清理說明

## 📋 功能概述

啟動腳本現在包含**自動日誌管理**功能，會自動歸檔和清理日誌檔案，保留最近 3 天的日誌。

## 🔄 自動清理機制

### 1. 啟動時自動歸檔
每次執行 `start` 或 `restart` 時：
```bash
./start-all-proxies.sh start
```

會自動：
- 將目前日誌檔案歸檔為 `*.log.時間戳記` 格式
- 建立新的日誌檔案
- 清理超過 3 天的歸檔日誌

### 2. 日誌檔案格式

```
logs/
├── Kimi-K2.log                      # 目前執行日誌
├── Kimi-K2.log.20251104_003516     # 歸檔日誌（3 天後自動刪除）
├── Kimi-K2.log.20251103_120000     # 舊的歸檔日誌
└── ...
```

## 📝 日誌保留策略

- **目前日誌**: 持續寫入，重啟時歸檔
- **歸檔日誌**: 保留 **3 天**
- **過期日誌**: 自動刪除（超過 3 天）

## 🛠️ 手動操作

### 手動清理日誌
```bash
./start-all-proxies.sh clean-logs
```

### 修改保留天數
編輯 `start-all-proxies.sh` 檔案：
```bash
# 找到這一行並修改天數
LOG_RETENTION_DAYS=3  # 改為你想要的天數，如 7
```

## ⏰ 設定定時清理（推薦）

執行以下命令設定 Cron Job，每天凌晨 2:00 自動清理：

```bash
./setup-log-cleanup-cron.sh
```

這會新增一個 cron 任務，無需手動介入。

### 查看 Cron 任務
```bash
crontab -l
```

### 刪除 Cron 任務
```bash
crontab -e
# 刪除包含 "start-all-proxies.sh clean-logs" 的行
```

## 📊 查看清理日誌

如果設定了 Cron Job，清理記錄會儲存在：
```bash
tail -f logs/cleanup-cron.log
```

## 💡 最佳實踐

1. **正常使用**：無需關心日誌清理，腳本會自動處理
2. **定期檢查**：偶爾查看日誌目錄大小
   ```bash
   du -sh logs/
   ```
3. **除錯時**：如需保留更多日誌，修改 `LOG_RETENTION_DAYS`
4. **設定 Cron**：執行 `./setup-log-cleanup-cron.sh` 實現完全自動化

## 🔍 故障排查

### 查看有多少歸檔日誌
```bash
ls -lh logs/*.log.* | wc -l
```

### 查看最舊的日誌
```bash
ls -lt logs/*.log.* | tail -n 5
```

### 手動刪除所有歸檔日誌
```bash
rm logs/*.log.*
```

### 檢查磁碟空間
```bash
df -h
du -sh logs/
```

## ⚙️ 技術細節

- 使用 `find` 命令的 `-mtime` 參數檢查檔案修改時間
- 基於檔案的最後修改時間（而非建立時間）
- 時間戳記格式：`YYYYMMDD_HHMMSS`
- 僅清理 `*.log.*` 格式的檔案，不會刪除目前日誌

## ✅ 總結

**開箱即用**：每次啟動都會自動清理過期日誌
**彈性設定**：可自訂保留天數
**可選自動化**：可設定 Cron Job 定期清理
**安全可靠**：只刪除歸檔檔案，不影響執行中的日誌
