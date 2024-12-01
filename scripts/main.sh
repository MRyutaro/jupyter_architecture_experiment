#!/bin/bash

# JSONファイルのディレクトリを指定
KERNEL_DIR="/home/vscode/.local/share/jupyter/runtime"

# kernel-*.json ファイルを探す
KERNEL_FILE=$(find "$KERNEL_DIR" -name "kernel-*.json" | head -n 1)

# ファイルが存在しない場合のエラーハンドリング
if [ -z "$KERNEL_FILE" ]; then
    echo "Error: No kernel-*.json file found in $KERNEL_DIR"
    exit 1
fi

# jq コマンドでJSONデータを読み込む
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to proceed."
    exit 1
fi

# JSONファイルを変数として読み込む
shell_port=$(jq -r '.shell_port' "$KERNEL_FILE")
iopub_port=$(jq -r '.iopub_port' "$KERNEL_FILE")
stdin_port=$(jq -r '.stdin_port' "$KERNEL_FILE")
control_port=$(jq -r '.control_port' "$KERNEL_FILE")
hb_port=$(jq -r '.hb_port' "$KERNEL_FILE")
ip=$(jq -r '.ip' "$KERNEL_FILE")
key=$(jq -r '.key' "$KERNEL_FILE")
transport=$(jq -r '.transport' "$KERNEL_FILE")
signature_scheme=$(jq -r '.signature_scheme' "$KERNEL_FILE")
kernel_name=$(jq -r '.kernel_name' "$KERNEL_FILE")
jupyter_session=$(jq -r '.jupyter_session' "$KERNEL_FILE")

# JSONデータを表示
echo "==============================="
echo "Kernel File: $KERNEL_FILE"
echo "Shell Port: $shell_port"
echo "IOPub Port: $iopub_port"
echo "Stdin Port: $stdin_port"
echo "Control Port: $control_port"
echo "Heartbeat Port: $hb_port"
echo "IP: $ip"
echo "Key: $key"
echo "Transport: $transport"
echo "Signature Scheme: $signature_scheme"
echo "Kernel Name: $kernel_name"
echo "Jupyter Session: $jupyter_session"

# jupyter-lab のプロセスIDを取得
JUPYTER_PID=$(pgrep -f "jupyter-lab")

# PIDが見つからない場合のエラーハンドリング
if [ -z "$JUPYTER_PID" ]; then
    echo "Error: jupyter-lab process not found."
    exit 1
fi

echo
echo "==============================="
pstree -p "$JUPYTER_PID"


TREE_PIDS=$(pstree -p "$JUPYTER_PID" | grep -o "([0-9]\+)" | tr -d "()")
echo
echo "Processes and Commands:"
echo "PID     Command"
echo "---------------------------"
# 各プロセスのコマンドを表示
for PID in $TREE_PIDS; do
    if [ -e /proc/$PID/cmdline ]; then
        CMD=$(cat /proc/$PID/cmdline | tr '\0' ' ')
        echo "$PID    $CMD"
    else
        echo "$PID    [Process not found or no permissions]"
    fi
done


# ss コマンドからプロセスとポート情報を収集
declare -A PORT_PID_MAP
declare -A PID_COMMAND_MAP
while read -r LINE; do
    PORT=$(echo "$LINE" | awk '{print $4}' | sed 's/.*://')   # ポート番号を抽出
    PID=$(echo "$LINE" | grep -oP 'pid=\K[0-9]+')            # プロセスIDを抽出
    PROCESS_NAME=$(echo "$LINE" | grep -oP 'users:\(\("([^,]+)' | sed 's/users:(("//;s/"$//')  # プロセス名を抽出
    if [[ -n "$PORT" && -n "$PID" ]]; then
        PORT_PID_MAP["$PID"]+="$PORT "                       # ポートをPIDに関連付け
    fi
    if [[ -n "$PID" && -n "$PROCESS_NAME" ]]; then
        PID_COMMAND_MAP["$PID"]="$PROCESS_NAME"              # PIDにプロセス名を関連付け
    fi
done < <(ss -tnp 2>/dev/null | tail -n +2)

# プロセスツリーを簡略表示
function display_tree() {
    local PID=$1
    local PREFIX=$2
    local IS_LAST=$3
    local CHILD_PREFIX=$PREFIX
    local PROCESS_NAME=${PID_COMMAND_MAP["$PID"]}

    if [ -z "$PROCESS_NAME" ]; then
        PROCESS_NAME="[Unknown]"
    fi

    if [ "$IS_LAST" = "true" ]; then
        echo "${PREFIX}└─ PID: $PID $PROCESS_NAME"
        CHILD_PREFIX="${PREFIX}    "
    else
        echo "${PREFIX}├─ PID: $PID $PROCESS_NAME"
        CHILD_PREFIX="${PREFIX}│   "
    fi

    # ポート情報を表示
    local PORTS=${PORT_PID_MAP["$PID"]}
    for PORT in $PORTS; do
        if [ "$PORT" = "$shell_port" ]; then
            echo "${CHILD_PREFIX}└─ PORT: $PORT shell_port"
        elif [ "$PORT" = "$iopub_port" ]; then
            echo "${CHILD_PREFIX}└─ PORT: $PORT iopub_port"
        elif [ "$PORT" = "$stdin_port" ]; then
            echo "${CHILD_PREFIX}└─ PORT: $PORT stdin_port"
        elif [ "$PORT" = "$control_port" ]; then
            echo "${CHILD_PREFIX}└─ PORT: $PORT control_port"
        elif [ "$PORT" = "$hb_port" ]; then
            echo "${CHILD_PREFIX}└─ PORT: $PORT hb_port"
        else
            echo "${CHILD_PREFIX}└─ PORT: $PORT 他プロセスと通信中"
        fi
    done
}

# ツリーの表示
echo
echo "==============================="
echo "Process and Ports Tree:"

CHILD_PIDS=($TREE_PIDS)
for i in "${!CHILD_PIDS[@]}"; do
    IS_LAST=false
    if [ "$i" -eq $((${#CHILD_PIDS[@]} - 1)) ]; then
        IS_LAST=true
    fi
    display_tree "${CHILD_PIDS[$i]}" "" "$IS_LAST"
done

echo
echo "==============================="
# ss -tnp の結果を表示
ss -tnp
