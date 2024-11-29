#!/bin/bash

# 関連するプロセスIDのリスト（例：jupyter labプロセスのプロセスツリーに基づく）
PIDS=(5867 5995 5996 6005 6006 6007 6020 6021 6022 6023 6024 6025 6026 6027 6028 6030 6031)

echo "PID    Command"
echo "---------------------------"

# 各プロセスのコマンドを取得
for PID in "${PIDS[@]}"
do
    if [ -e /proc/$PID/cmdline ]; then
        CMD=$(cat /proc/$PID/cmdline | tr '\0' ' ')
        echo "$PID    $CMD"
    else
        echo "$PID    [Process not found or no permissions]"
    fi
done
