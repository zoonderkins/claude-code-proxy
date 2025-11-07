#!/bin/bash

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_SCRIPT="$SCRIPT_DIR/start-all-proxies.sh"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}設定日誌自動清理 Cron Job${NC}"
echo -e "${BLUE}================================${NC}"
echo

# 檢查腳本是否存在
if [ ! -f "$CLEANUP_SCRIPT" ]; then
    echo -e "${RED}錯誤: 找不到腳本 $CLEANUP_SCRIPT${NC}"
    exit 1
fi

# Cron job 設定（每天凌晨 2 點執行）
CRON_TIME="0 2 * * *"
CRON_JOB="$CRON_TIME cd $SCRIPT_DIR && $CLEANUP_SCRIPT clean-logs >> $SCRIPT_DIR/logs/cleanup-cron.log 2>&1"

echo -e "${YELLOW}將新增以下 Cron Job:${NC}"
echo "$CRON_JOB"
echo
echo "這將在每天凌晨 2:00 自動清理超過 3 天的日誌"
echo

# 檢查是否已存在相同的 cron job
if crontab -l 2>/dev/null | grep -q "$CLEANUP_SCRIPT clean-logs"; then
    echo -e "${YELLOW}偵測到已存在的日誌清理 Cron Job${NC}"
    read -p "是否替換現有的 Cron Job? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消操作"
        exit 0
    fi
    # 刪除舊的 cron job
    crontab -l 2>/dev/null | grep -v "$CLEANUP_SCRIPT clean-logs" | crontab -
fi

# 新增 cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ Cron Job 已成功新增${NC}"
echo

echo -e "${BLUE}目前的 Cron Jobs:${NC}"
crontab -l | grep "$CLEANUP_SCRIPT" || echo "無相關 Cron Job"
echo

echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}設定完成！${NC}"
echo -e "${BLUE}================================${NC}"
echo
echo "日誌將在每天凌晨 2:00 自動清理"
echo "清理日誌位置: $SCRIPT_DIR/logs/cleanup-cron.log"
echo
echo "其他有用的命令:"
echo "  查看所有 Cron Jobs:     crontab -l"
echo "  刪除所有 Cron Jobs:     crontab -r"
echo "  編輯 Cron Jobs:         crontab -e"
echo "  手動清理日誌:           $CLEANUP_SCRIPT clean-logs"
echo
