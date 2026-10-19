#!/bin/bash
# 移动爱家 - 超简单抓包工具

clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║    📱 移动爱家 - 超简单抓包工具            ║"
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
echo "📱 在iPhone上设置代理"
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
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "设置好后按回车继续..." dummy

echo ""
echo "🚀 启动代理服务器..."
echo ""
echo "现在在iPhone上："
echo "  1️⃣  打开移动爱家App"
echo "  2️⃣  登录并查看摄像头"
echo "  3️⃣  完成后回到Mac，按 Ctrl+C 停止"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建输出目录
mkdir -p ~/Desktop/mobile_home_web/captures

# 使用mitmdump（命令行版本）保存所有流量
~/Library/Python/3.9/bin/mitmdump -p 8080 -w ~/Desktop/mobile_home_web/captures/移动爱家_$(date +%Y%m%d_%H%M%S).mitm

echo ""
echo "✅ 抓包完成！"
echo ""
echo "文件保存在: ~/Desktop/mobile_home_web/captures/"
echo ""
echo "⚠️  别忘了关闭iPhone的代理："
echo "   「设置」→「WiFi」→ (i) →「配置代理」→「关闭」"
echo ""
