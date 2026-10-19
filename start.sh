#!/bin/bash
# 移动爱家网页版 - 一键开始

clear
echo ""
echo "╔════════════════════════════════════════╗"
echo "║     移动爱家网页版 - 一键启动工具      ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "请选择你要做什么："
echo ""
echo "  1) 🔍 抓取 API（让登录功能可用）"
echo "  2) 👀 预览界面（使用模拟数据）"
echo "  3) 🚀 部署到 VPS"
echo "  4) 📖 查看使用说明"
echo "  5) 🛠️  测试 API 服务器"
echo "  0) 退出"
echo ""
read -p "请输入选项 [0-5]: " choice

case $choice in
    1)
        echo ""
        echo "准备开始抓包..."
        sleep 1
        ./capture_complete.sh
        ;;
    2)
        echo ""
        echo "启动预览服务器..."
        echo "浏览器访问: http://localhost:8000"
        echo "按 Ctrl+C 停止"
        echo ""
        python3 -m http.server 8000
        ;;
    3)
        echo ""
        echo "VPS 部署步骤："
        echo ""
        echo "1. 将整个文件夹上传到 VPS："
        echo "   scp -r mobile_home_web root@你的VPS_IP:/root/"
        echo ""
        echo "2. SSH 登录到 VPS："
        echo "   ssh root@你的VPS_IP"
        echo ""
        echo "3. 运行安装脚本："
        echo "   cd /root/mobile_home_web"
        echo "   chmod +x install.sh"
        echo "   ./install.sh"
        echo ""
        read -p "按回车键返回..."
        ./start.sh
        ;;
    4)
        echo ""
        cat 使用说明.md
        echo ""
        read -p "按回车键返回..."
        ./start.sh
        ;;
    5)
        echo ""
        echo "测试 API 服务器..."
        python3 test_api.py
        echo ""
        read -p "按回车键返回..."
        ./start.sh
        ;;
    0)
        echo ""
        echo "👋 再见！"
        echo ""
        exit 0
        ;;
    *)
        echo ""
        echo "❌ 无效选项"
        sleep 1
        ./start.sh
        ;;
esac
