from jupyter_client import KernelManager

# KernelManagerを初期化
km = KernelManager(kernel_name='faosjdofizx9duf')  # 必要に応じてカーネル名を変更
km.start_kernel()

try:
    # カーネルとの通信チャネルを作成
    kc = km.client()
    kc.start_channels()

    # コードを実行
    code = "print('Hello from Jupyter Client')"
    kc.execute(code)

    # 結果を取得
    while True:
        msg = kc.get_iopub_msg(timeout=5)  # タイムアウトを指定
        if msg['msg_type'] == 'stream':
            print("Output:", msg['content']['text'])
        elif msg['msg_type'] == 'execute_result':
            print("Result:", msg['content']['data']['text/plain'])
        elif msg['msg_type'] == 'error':
            print("Error:", msg['content'])
        # 結果がすべて取得できたら終了
        if msg['msg_type'] in {'execute_reply', 'status'}:
            break

finally:
    # カーネルを停止
    kc.stop_channels()
    km.shutdown_kernel()
