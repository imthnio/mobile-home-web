#!/bin/bash
# 移动爱家 - 完整抓包工具（含证书安装）

clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║    📱 移动爱家 - 完整抓包工具（HTTPS版）   ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# 获取Mac的IP地址
MAC_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取Mac的IP地址"
    exit 1
fi

echo "✅ Mac的IP地址: $MAC_IP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "第1步：在iPhone上设置代理"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. 打开「设置」→「无线局域网」"
echo "  2. 点击已连接WiFi右边的 (i)"
echo "  3. 滚动到底部，「配置代理」→「手动」"
echo "  4. 输入："
echo ""
echo "     服务器: $MAC_IP"
echo "     端口: 8080"
echo ""
echo "  5. 点击「存储」"
echo ""
read -p "✅ 设置好后按回车继续..." dummy

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "第2步：在iPhone上安装证书"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "正在启动代理服务器..."
echo ""

# 先启动代理服务器
~/Library/Python/3.9/bin/mitmproxy -p 8080 --set confdir=~/.mitmproxy &
PROXY_PID=$!

sleep 3

echo "✅ 代理服务器已启动"
echo ""
echo "现在在iPhone上："
echo ""
echo "  1. 打开 Safari 浏览器"
echo "  2. 访问: http://mitm.it"
echo "  3. 点击「Apple」图标，下载证书"
echo "  4. 会弹出「此网站尝试下载配置描述文件」→ 点击「允许」"
echo "  5. 打开「设置」→ 会看到「已下载描述文件」→ 点进去"
echo "  6. 点击右上角「安装」→ 输入密码 → 再次点「安装」→「完成」"
echo "  7. 打开「设置」→「通用」→「关于本机」→「证书信任设置」"
echo "  8. 找到「mitmproxy」，打开右边的开关"
echo ""
read -p "✅ 安装完成后按回车继续..." dummy

# 停止之前的代理
kill $PROXY_PID 2>/dev/null
sleep 2

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "第3步：开始抓包"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "现在在iPhone上："
echo "  1️⃣  打开「移动爱家」App"
echo "  2️⃣  登录（手机号：17811949340）"
echo "  3️⃣  点击摄像头查看视频"
echo "  4️⃣  完成后回到Mac，按 Ctrl+C 停止"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建输出目录
mkdir -p ~/Desktop/mobile_home_web/captures

# 使用mitmdump保存所有流量
CAPTURE_FILE=~/Desktop/mobile_home_web/captures/移动爱家_$(date +%Y%m%d_%H%M%S).mitm
~/Library/Python/3.9/bin/mitmdump -p 8080 -w "$CAPTURE_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 抓包完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "文件: $CAPTURE_FILE"
echo ""
echo "⚠️  记得关闭iPhone的代理："
echo "   「设置」→「WiFi」→ (i) →「配置代理」→「关闭」"
echo ""
