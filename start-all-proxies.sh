#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 設定
PROXIES=(
    "8081:.env-requesty-kimi-k2:Kimi-K2"
    "8082:.env-requesty-glm:GLM-4.6"
    "8083:.env-requesty-minimax-m2:MiniMax-M2"
    "8084:.env-requesty-gemini:Gemini-2.5-Flash"
)

# Python 命令偵測（優先使用 uv）
PYTHON_CMD="python"
if command -v uv >/dev/null 2>&1; then
    PYTHON_CMD="uv run python"
    echo -e "${GREEN}使用 UV 執行 Python${NC}"
fi

# 日誌目錄
LOG_DIR="logs"
mkdir -p "$LOG_DIR"

# PID 檔案目錄
PID_DIR="pids"
mkdir -p "$PID_DIR"

# 日誌保留天數
LOG_RETENTION_DAYS=3

# 清理舊日誌
cleanup_old_logs() {
    echo -e "${YELLOW}清理超過 ${LOG_RETENTION_DAYS} 天的舊日誌...${NC}"

    # 清理舊的日誌檔案
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +${LOG_RETENTION_DAYS} -delete 2>/dev/null

    # 統計刪除的檔案數
    local old_logs=$(find "$LOG_DIR" -name "*.log.*" -type f -mtime +${LOG_RETENTION_DAYS} 2>/dev/null | wc -l)

    if [ $old_logs -eq 0 ]; then
        echo -e "${GREEN}✓ 沒有需要清理的舊日誌${NC}"
    else
        echo -e "${GREEN}✓ 已清理 $old_logs 個舊日誌檔案${NC}"
    fi
}

# 歸檔目前日誌
archive_current_logs() {
    local timestamp=$(date +%Y%m%d_%H%M%S)

    for proxy_config in "${PROXIES[@]}"; do
        IFS=':' read -r port env_file name <<< "$proxy_config"
        local log_file="$LOG_DIR/${name}.log"

        if [ -f "$log_file" ] && [ -s "$log_file" ]; then
            local archive_file="$LOG_DIR/${name}.log.${timestamp}"
            mv "$log_file" "$archive_file"
            echo -e "${GREEN}已歸檔: ${name}.log → ${name}.log.${timestamp}${NC}"
        fi
    done
}

# 檢查連接埠是否被佔用
check_port() {
    local port=$1
    lsof -ti:$port >/dev/null 2>&1
}

# 終止佔用連接埠的處理程序
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port)
    if [ -n "$pid" ]; then
        echo -e "${YELLOW}連接埠 $port 被處理程序 $pid 佔用，正在終止...${NC}"
        kill -9 $pid
        sleep 1
        if check_port $port; then
            echo -e "${RED}無法終止連接埠 $port 上的處理程序${NC}"
            return 1
        else
            echo -e "${GREEN}已成功終止連接埠 $port 上的處理程序${NC}"
        fi
    fi
    return 0
}

# 取得代理健康資訊
get_proxy_health() {
    local port=$1
    local max_retries=5
    local retry_delay=2

    for i in $(seq 1 $max_retries); do
        local health_response=$(curl -s http://localhost:$port/health 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$health_response" ]; then
            echo "$health_response"
            return 0
        fi
        sleep $retry_delay
    done
    return 1
}

# 啟動單一代理
start_proxy() {
    local port=$1
    local env_file=$2
    local name=$3

    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}啟動代理: $name${NC}"
    echo -e "${BLUE}連接埠: $port${NC}"
    echo -e "${BLUE}設定: $env_file${NC}"
    echo -e "${BLUE}================================${NC}"

    # 檢查環境檔案是否存在
    if [ ! -f "$env_file" ]; then
        echo -e "${RED}錯誤: 環境檔案 $env_file 不存在${NC}"
        return 1
    fi

    # 檢查連接埠
    if check_port $port; then
        echo -e "${YELLOW}警告: 連接埠 $port 已被佔用${NC}"
        read -p "是否終止佔用處理程序並繼續? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if ! kill_port $port; then
                return 1
            fi
        else
            echo -e "${RED}跳過代理 $name 的啟動${NC}"
            return 1
        fi
    fi

    # 日誌檔案
    local log_file="$LOG_DIR/${name}.log"
    local pid_file="$PID_DIR/${name}.pid"

    # 啟動代理
    echo -e "${GREEN}正在啟動...${NC}"
    nohup $PYTHON_CMD start_proxy.py --env="$env_file" > "$log_file" 2>&1 &
    local pid=$!
    echo $pid > "$pid_file"

    # 等待啟動
    sleep 2

    # 檢查是否成功啟動
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 代理 $name 已成功啟動 (PID: $pid)${NC}"
        echo -e "${GREEN}  日誌: $log_file${NC}"
        echo -e "${GREEN}  PID檔案: $pid_file${NC}"

        # 取得健康檢查資訊
        echo -e "${YELLOW}正在取得模型設定...${NC}"
        local health_info=$(get_proxy_health $port)
        if [ $? -eq 0 ]; then
            # 使用 jq 解析 JSON，如果沒有 jq 則直接顯示原始 JSON
            if command -v jq >/dev/null 2>&1; then
                local big_model=$(echo "$health_info" | jq -r '.models.big_model // "N/A"')
                local middle_model=$(echo "$health_info" | jq -r '.models.middle_model // "N/A"')
                local small_model=$(echo "$health_info" | jq -r '.models.small_model // "N/A"')
                echo -e "${GREEN}  模型設定:${NC}"
                echo -e "${GREEN}    BIG (opus): $big_model${NC}"
                echo -e "${GREEN}    MIDDLE (sonnet): $middle_model${NC}"
                echo -e "${GREEN}    SMALL (haiku): $small_model${NC}"
            else
                echo -e "${YELLOW}  提示: 安裝 jq 以獲得更好的顯示效果${NC}"
                echo -e "${GREEN}  Health: $health_info${NC}"
            fi
        else
            echo -e "${YELLOW}  警告: 無法取得健康檢查資訊，但服務已啟動${NC}"
        fi

        return 0
    else
        echo -e "${RED}✗ 代理 $name 啟動失敗${NC}"
        echo -e "${RED}  請查看日誌: $log_file${NC}"
        rm -f "$pid_file"
        return 1
    fi
}

# 停止所有代理
stop_all() {
    echo -e "${YELLOW}正在停止所有代理...${NC}"
    for proxy_config in "${PROXIES[@]}"; do
        IFS=':' read -r port env_file name <<< "$proxy_config"
        local pid_file="$PID_DIR/${name}.pid"

        if [ -f "$pid_file" ]; then
            local pid=$(cat "$pid_file")
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "${YELLOW}停止 $name (PID: $pid)...${NC}"
                kill $pid
                sleep 1
                if ps -p $pid > /dev/null 2>&1; then
                    echo -e "${YELLOW}強制終止 $name...${NC}"
                    kill -9 $pid
                fi
                echo -e "${GREEN}✓ $name 已停止${NC}"
            fi
            rm -f "$pid_file"
        fi

        # 同時檢查連接埠佔用
        if check_port $port; then
            kill_port $port
        fi
    done
}

# 顯示狀態
show_status() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}代理服務狀態${NC}"
    echo -e "${BLUE}================================${NC}"

    for proxy_config in "${PROXIES[@]}"; do
        IFS=':' read -r port env_file name <<< "$proxy_config"
        local pid_file="$PID_DIR/${name}.pid"

        echo -e "\n${YELLOW}$name (連接埠 $port):${NC}"

        if [ -f "$pid_file" ]; then
            local pid=$(cat "$pid_file")
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "  ${GREEN}✓ 執行中 (PID: $pid)${NC}"
                echo -e "  日誌: $LOG_DIR/${name}.log"

                # 取得健康檢查資訊
                local health_info=$(curl -s http://localhost:$port/health 2>/dev/null)
                if [ $? -eq 0 ] && [ -n "$health_info" ]; then
                    if command -v jq >/dev/null 2>&1; then
                        local big_model=$(echo "$health_info" | jq -r '.models.big_model // "N/A"')
                        local middle_model=$(echo "$health_info" | jq -r '.models.middle_model // "N/A"')
                        local small_model=$(echo "$health_info" | jq -r '.models.small_model // "N/A"')
                        local base_url=$(echo "$health_info" | jq -r '.api_status.openai_base_url // "N/A"')
                        echo -e "  ${GREEN}模型設定:${NC}"
                        echo -e "    BIG (opus): $big_model"
                        echo -e "    MIDDLE (sonnet): $middle_model"
                        echo -e "    SMALL (haiku): $small_model"
                        echo -e "  ${GREEN}API URL:${NC} $base_url"
                    else
                        # 沒有 jq，使用簡單的文字擷取
                        local big_model=$(echo "$health_info" | grep -o '"big_model"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
                        echo -e "  ${GREEN}主模型:${NC} ${big_model:-N/A}"
                    fi
                else
                    echo -e "  ${YELLOW}⚠ 無法取得模型資訊${NC}"
                fi
            else
                echo -e "  ${RED}✗ 已停止 (PID檔案存在但處理程序不存在)${NC}"
            fi
        else
            if check_port $port; then
                local pid=$(lsof -ti:$port)
                echo -e "  ${YELLOW}⚠ 連接埠被其他處理程序佔用 (PID: $pid)${NC}"
            else
                echo -e "  ${RED}✗ 未執行${NC}"
            fi
        fi
    done
    echo
}

# 主函式
main() {
    case "${1:-start}" in
        start)
            echo -e "${BLUE}================================${NC}"
            echo -e "${BLUE}啟動所有 Claude Code 代理${NC}"
            echo -e "${BLUE}================================${NC}"
            echo

            # 歸檔舊日誌
            archive_current_logs
            echo

            # 清理過期日誌
            cleanup_old_logs
            echo

            local success_count=0
            for proxy_config in "${PROXIES[@]}"; do
                IFS=':' read -r port env_file name <<< "$proxy_config"
                if start_proxy $port $env_file $name; then
                    ((success_count++))
                fi
                echo
            done

            echo -e "${BLUE}================================${NC}"
            echo -e "${BLUE}啟動完成: $success_count/${#PROXIES[@]} 個代理成功啟動${NC}"
            echo -e "${BLUE}================================${NC}"

            if [ $success_count -eq ${#PROXIES[@]} ]; then
                echo
                show_status
            fi
            ;;

        stop)
            stop_all
            ;;

        restart)
            stop_all
            sleep 2
            $0 start
            ;;

        status)
            show_status
            ;;

        clean-logs)
            cleanup_old_logs
            ;;

        *)
            echo "用法: $0 {start|stop|restart|status|clean-logs}"
            echo
            echo "命令說明:"
            echo "  start      - 啟動所有代理 (預設)"
            echo "  stop       - 停止所有代理"
            echo "  restart    - 重新啟動所有代理"
            echo "  status     - 查看所有代理狀態"
            echo "  clean-logs - 手動清理超過 ${LOG_RETENTION_DAYS} 天的日誌"
            echo
            echo "注意: start 和 restart 會自動歸檔目前日誌並清理過期日誌"
            exit 1
            ;;
    esac
}

main "$@"
