import os
import sys
import subprocess

# jupyter-lab のプロセスIDを取得
try:
    result = subprocess.run(
        ["pgrep", "-f", "jupyter-lab"],
        text=True,
        capture_output=True,
        check=False
    )
    jupyter_pid = result.stdout.strip()

    # PIDが見つからない場合のエラーハンドリング
    if not jupyter_pid:
        print("Error: jupyter-lab process not found.")
        sys.exit(1)

    print(f"jupyter-lab PID: {jupyter_pid}")

    # プロセスツリーを表示
    os.system(f"pstree -p {jupyter_pid}")

except Exception as e:
    print(f"An error occurred: {e}")
    sys.exit(1)
