#!/bin/bash
# 移动爱家 - WiFi代理抓包工具
# 最简单的方案！

clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║    📱 移动爱家 - WiFi代理抓包工具          ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# 获取Mac的IP地址
MAC_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取Mac的IP地址"
    echo "请确保Mac已连接到WiFi"
    exit 1
fi

echo "✅ Mac的IP地址: $MAC_IP"
echo ""

# 创建输出目录
OUTPUT_DIR=~/Desktop/mobile_home_web/captures
mkdir -p $OUTPUT_DIR
CAPTURE_FILE="$OUTPUT_DIR/移动爱家_$(date +%Y%m%d_%H%M%S).pcap"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "设置步骤"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "【第1步】在iPhone上设置代理"
echo ""
echo "  1. 打开「设置」→「无线局域网」"
echo "  2. 点击已连接WiFi右边的 (i) 图标"
echo "  3. 滚动到最下面，找到「配置代理」"
echo "  4. 选择「手动」"
echo "  5. 输入以下信息："
echo ""
echo "     服务器: $MAC_IP"
echo "     端口: 8888"
echo ""
echo "  6. 点击右上角「存储」"
echo ""
echo "【第2步】在Mac上开始抓包"
echo ""
echo "  等你设置好iPhone后，按回车键继续..."
echo ""
read -p "" dummy

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "开始抓包"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "抓包文件: $CAPTURE_FILE"
echo ""
echo "现在请在iPhone上："
echo ""
echo "  1️⃣  打开「移动爱家」App"
echo "  2️⃣  登录"
echo "  3️⃣  打开摄像头"
echo ""
echo "完成后按 Ctrl+C 停止"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 启动简单的代理和抓包
# 使用Mac自带的tcpdump抓取所有进入8888端口的流量
echo "正在监听端口 8888..."
echo "（需要输入Mac密码）"
echo ""

# 先启动一个简单的HTTP代理
# 使用Python创建代理服务器
python3 -c "
import http.server
import socketserver
import socket

class ProxyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        print(f'GET {self.path}')
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Proxy is working')
    
    def do_POST(self):
        print(f'POST {self.path}')
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        print(f'Body: {body[:200]}')
        self.send_response(200)
        self.end_headers()
    
    def do_CONNECT(self):
        print(f'CONNECT {self.path}')
        self.send_response(200)
        self.end_headers()

PORT = 8888
Handler = ProxyHTTPRequestHandler

print(f'代理服务器运行在 {MAC_IP}:8888')
print('按 Ctrl+C 停止')

with socketserver.TCPServer(('', PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\n停止服务器...')
" &

PROXY_PID=$!

# 同时抓包
sudo tcpdump -i any -n 'port 8888' -w "$CAPTURE_FILE" 2>&1

# 清理
kill $PROXY_PID 2>/dev/null

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "别忘了关闭iPhone的代理："
echo "「设置」→「WiFi」→ (i) →「配置代理」→ 选择「关闭」"
echo ""
echo "抓包文件: $CAPTURE_FILE"
echo ""
