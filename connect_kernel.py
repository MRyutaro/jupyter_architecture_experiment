import os
from pprint import pprint

from jupyter_client import BlockingKernelClient

# python -m ipykernelで起動したカーネルの接続情報を指定

dir_path = "/home/vscode/.local/share/jupyter/runtime"
# dir_pathに含まれるファイル名を取得
files = os.listdir(dir_path)
print(files)
print()

file_name = "kernel-65080.json"
connection_file = f"{dir_path}/{file_name}"
print(connection_file)
print()

# BlockingKernelClientを使用して接続
client = BlockingKernelClient(connection_file=connection_file)
client.load_connection_file()
client.start_channels()

# カーネルにコマンドを送信
client.execute("print('Hello, Kernel!')")

# カーネルの出力を確認
shell_reply = client.get_shell_msg()
iopub_reply = client.get_iopub_msg()
pprint(shell_reply)
print()
pprint(iopub_reply)
print()
