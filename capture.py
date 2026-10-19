#!/usr/bin/env python3
"""
移动爱家 App 网络请求抓取工具
使用方法：python3 capture.py
"""

import http.server
import socketserver
import urllib.parse
import json
from datetime import datetime

PORT = 8888
captured_requests = []

class ProxyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.capture_request('GET')
        self.send_response(200)
        self.end_headers()
        
    def do_POST(self):
        self.capture_request('POST')
        self.send_response(200)
        self.end_headers()
        
    def capture_request(self, method):
        # 读取请求体
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8') if content_length > 0 else ''
        
        request_info = {
            'time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'method': method,
            'path': self.path,
            'headers': dict(self.headers),
            'body': body
        }
        
        captured_requests.append(request_info)
        
        # 打印到控制台
        print(f"\n{'='*60}")
        print(f"[{request_info['time']}] {method} {self.path}")
        print(f"Headers: {json.dumps(dict(self.headers), indent=2, ensure_ascii=False)}")
        if body:
            print(f"Body: {body}")
        print('='*60)
        
        # 保存到文件
        with open('captured_requests.json', 'w', encoding='utf-8') as f:
            json.dump(captured_requests, f, indent=2, ensure_ascii=False)

print(f"""
移动爱家抓包工具已启动
监听端口: {PORT}

请在手机上设置 WiFi 代理：
1. 代理服务器：你的 Mac IP 地址
2. 端口：{PORT}

然后打开移动爱家 App，操作后会在这里显示抓到的请求。
抓到的请求会保存到 captured_requests.json 文件中。

按 Ctrl+C 停止抓包
""")

try:
    with socketserver.TCPServer(("", PORT), ProxyHandler) as httpd:
        httpd.serve_forever()
except KeyboardInterrupt:
    print("\n\n抓包已停止")
    print(f"共抓取 {len(captured_requests)} 个请求")
    print("请查看 captured_requests.json 文件")
