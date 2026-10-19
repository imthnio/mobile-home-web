#!/bin/bash
# 移动爱家 - 完整抓包方案（含证书安装）
# 这个脚本会自动化整个流程

echo "======================================"
echo "  移动爱家 HTTPS 抓包工具"
echo "======================================"
echo ""

# 检查并安装 mitmproxy
echo "[1/5] 检查 mitmproxy..."
if ! command -v mitmweb &> /dev/null; then
    echo "未安装 mitmproxy，正在安装..."
    
    # 检查 Python
    if command -v python3 &> /dev/null; then
        pip3 install mitmproxy
    else
        echo "❌ 需要先安装 Python 3"
        echo "请运行: brew install python3"
        exit 1
    fi
fi

echo "✅ mitmproxy 已就绪"

# 获取本机 IP
echo ""
echo "[2/5] 获取本机 IP 地址..."
MAC_IP=$(ifconfig en0 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')

if [ -z "$MAC_IP" ]; then
    MAC_IP=$(ifconfig en1 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
fi

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取 IP 地址"
    echo "请确保 Mac 已连接到 WiFi"
    exit 1
fi

echo "✅ 本机 IP: $MAC_IP"

# 启动 mitmweb
echo ""
echo "[3/5] 启动抓包服务器..."
echo ""
echo "======================================"
echo "  配置 iPhone"
echo "======================================"
echo ""
echo "请按以下步骤在 iPhone 上操作："
echo ""
echo "第一步：配置代理"
echo "  1. 打开「设置」→「无线局域网」"
echo "  2. 点击已连接 WiFi 右边的 ⓘ"
echo "  3. 滚动到底部，点击「配置代理」"
echo "  4. 选择「手动」"
echo "  5. 填写："
echo "     服务器: $MAC_IP"
echo "     端口: 8080"
echo "  6. 点击「存储」"
echo ""
echo "第二步：安装证书"
echo "  1. 在 iPhone 的 Safari 浏览器中访问："
echo "     http://mitm.it"
echo "  2. 点击「iOS」图标下载证书"
echo "  3. 在弹出的对话框中点击「允许」"
echo "  4. 打开「设置」→「已下载描述文件」"
echo "  5. 点击「mitmproxy」证书"
echo "  6. 点击右上角「安装」（输入密码）"
echo "  7. 点击「安装」（会提示「未签名」，继续点击「安装」）"
echo "  8. 点击「完成」"
echo ""
echo "第三步：信任证书"
echo "  1. 打开「设置」→「通用」→「关于本机」"
echo "  2. 滚动到底部，点击「证书信任设置」"
echo "  3. 开启「mitmproxy」的完全信任"
echo "  4. 在弹窗中点击「继续」"
echo ""
echo "======================================"
echo ""
read -p "配置完成后，按回车键继续..."

# 启动 mitmweb
echo ""
echo "[4/5] 启动抓包界面..."
echo ""
echo "浏览器会自动打开抓包界面"
echo "地址: http://127.0.0.1:8081"
echo ""
echo "现在可以在 iPhone 上操作移动爱家 App 了："
echo "  1. 打开移动爱家 App"
echo "  2. 输入手机号和密码登录"
echo "  3. 查看摄像头"
echo ""
echo "所有的网络请求会显示在浏览器中"
echo "按 Ctrl+C 停止抓包"
echo ""

mitmweb --listen-host 0.0.0.0 --listen-port 8080 --web-host 127.0.0.1 --web-port 8081

# 清理
echo ""
echo ""
echo "[5/5] 清理..."
echo ""
echo "⚠️  记得在 iPhone 上关闭代理："
echo "  设置 → 无线局域网 → WiFi ⓘ → 配置代理 → 关闭"
echo ""
echo "抓到的数据已保存，请截图发给我，或者告诉我看到了什么请求"
