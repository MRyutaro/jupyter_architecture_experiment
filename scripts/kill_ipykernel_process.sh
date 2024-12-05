#!/bin/bash

# python3.12が起動しているプロセスを探し、killするスクリプト

# ssコマンドの結果からpython3.12のプロセスIDを抽出
python_pid=$(ss -tnp | grep python3.12 | awk -F'pid=' '{print $2}' | awk -F',' '{print $1}' | head -n 1)

if [ -z "$python_pid" ]; then
  echo "python3.12のプロセスは見つかりませんでした。"
else
  echo "python3.12のプロセスを終了します: PID=$python_pid"
  kill "$python_pid"
  if [ $? -eq 0 ]; then
    echo "プロセス $python_pid を正常に終了しました。"
  else
    echo "プロセス $python_pid の終了に失敗しました。"
  fi
fi
