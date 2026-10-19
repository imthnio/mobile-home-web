#!/bin/bash
# 移动爱家 - 超级傻瓜式抓包工具
# 适合完全不懂技术的用户

clear

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    📱 移动爱家 - 超级傻瓜式抓包工具       ║"
echo "║                                           ║"
echo "║    为电脑小白设计，5分钟搞定！             ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo -e "${YELLOW}温馨提示：整个过程很简单，跟着做就行！${NC}"
echo ""
sleep 2

# 第0步：检查 Python
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 0/4] 检查电脑环境...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 电脑上没有 Python${NC}"
    echo ""
    echo "需要先安装 Python，很简单："
    echo "1. 访问：https://www.python.org/downloads/"
    echo "2. 下载并安装"
    echo "3. 重新运行本脚本"
    exit 1
fi

echo -e "${GREEN}✅ Python 已安装${NC}"
sleep 1

# 安装 mitmproxy
echo ""
echo "正在安装抓包工具（只需要一次）..."
if ! command -v mitmweb &> /dev/null; then
    pip3 install mitmproxy --quiet
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 安装失败${NC}"
        echo "请手动运行：pip3 install mitmproxy"
        exit 1
    fi
fi
echo -e "${GREEN}✅ 工具已就绪${NC}"
sleep 1

# 第1步：获取 IP
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 1/4] 获取电脑 IP 地址...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

MAC_IP=$(ifconfig en0 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
if [ -z "$MAC_IP" ]; then
    MAC_IP=$(ifconfig en1 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
fi

if [ -z "$MAC_IP" ]; then
    echo -e "${RED}❌ 无法获取 IP 地址${NC}"
    echo "请确保 Mac 已连接到 WiFi"
    exit 1
fi

echo -e "${GREEN}✅ 电脑 IP：${MAC_IP}${NC}"
echo ""
echo -e "${YELLOW}👉 请记住这个 IP，等会儿要在 iPhone 上填写${NC}"
sleep 3

# 第2步：显示 iPhone 配置教程
clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    📱 现在要在 iPhone 上操作了             ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 2/4] 配置 iPhone 网络代理${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "请在 iPhone 上按顺序操作："
echo ""
echo -e "${YELLOW}1️⃣  打开「设置」App${NC}"
echo "    （就是那个灰色齿轮图标）"
echo ""
echo -e "${YELLOW}2️⃣  点击「无线局域网」${NC}"
echo "    （通常在第二个选项）"
echo ""
echo -e "${YELLOW}3️⃣  找到已连接的 WiFi，点击右边的 ${BLUE}ⓘ${YELLOW} 图标${NC}"
echo "    （一定要是已连接的那个WiFi）"
echo ""
echo -e "${YELLOW}4️⃣  滚动到最底部，找到「配置代理」${NC}"
echo ""
echo -e "${YELLOW}5️⃣  点击「手动」${NC}"
echo ""
echo -e "${YELLOW}6️⃣  填写以下信息：${NC}"
echo ""
echo -e "    ${GREEN}服务器：${MAC_IP}${NC}"
echo -e "    ${GREEN}端口：  8080${NC}"
echo ""
echo -e "    ${RED}注意：一个字母都不能错！${NC}"
echo ""
echo -e "${YELLOW}7️⃣  点击右上角「存储」${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "配置好了吗？按回车键继续..."

# 第3步：安装证书
clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    🔒 安装证书（这步很重要！）             ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 3/4] 在 iPhone 上安装证书${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "继续在 iPhone 上操作："
echo ""
echo -e "${YELLOW}1️⃣  打开 Safari 浏览器${NC}"
echo "    （必须用 Safari，不能用其他浏览器）"
echo ""
echo -e "${YELLOW}2️⃣  在地址栏输入：${NC}"
echo ""
echo -e "    ${GREEN}http://mitm.it${NC}"
echo ""
echo -e "    ${RED}注意：是 http 不是 https！${NC}"
echo ""
echo -e "${YELLOW}3️⃣  页面打开后，点击 iOS 图标（苹果标志）${NC}"
echo ""
echo -e "${YELLOW}4️⃣  弹出对话框，点击「允许」${NC}"
echo ""
echo -e "${YELLOW}5️⃣  返回桌面，打开「设置」→「已下载描述文件」${NC}"
echo "    （如果没看到，去「通用」里找）"
echo ""
echo -e "${YELLOW}6️⃣  点击「mitmproxy」证书${NC}"
echo ""
echo -e "${YELLOW}7️⃣  点击右上角「安装」，输入密码${NC}"
echo ""
echo -e "${YELLOW}8️⃣  会提示「未签名」，不用管，继续点「安装」${NC}"
echo ""
echo -e "${YELLOW}9️⃣  点击「完成」${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "证书安装好了吗？按回车键继续..."

# 第3.5步：信任证书
clear
echo ""
echo -e "${RED}⚠️  最后一步很重要！${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 3.5/4] 信任证书${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "还差一点点："
echo ""
echo -e "${YELLOW}1️⃣  打开「设置」→「通用」→「关于本机」${NC}"
echo ""
echo -e "${YELLOW}2️⃣  滚动到最底部，点击「证书信任设置」${NC}"
echo ""
echo -e "${YELLOW}3️⃣  开启「mitmproxy」的开关（变成绿色）${NC}"
echo ""
echo -e "${YELLOW}4️⃣  弹窗警告，点击「继续」${NC}"
echo ""
echo -e "${GREEN}✅ 完成！现在可以抓包了！${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "全部设置好了吗？按回车键开始抓包..."

# 第4步：开始抓包
clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    🎉 太棒了！开始抓包！                   ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 4/4] 抓取移动爱家 API${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "马上浏览器会自动打开一个网页，那就是抓包界面"
echo ""
echo -e "${YELLOW}现在请在 iPhone 上操作：${NC}"
echo ""
echo "  1️⃣  打开「移动爱家」App"
echo "  2️⃣  输入你的手机号和密码"
echo "  3️⃣  点击登录"
echo "  4️⃣  登录成功后，随便点开一个摄像头"
echo ""
echo -e "${GREEN}电脑浏览器里会实时显示所有请求${NC}"
echo ""
echo -e "${RED}抓包完成后，按 Ctrl+C 停止${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
sleep 3

# 启动 mitmweb
echo "正在启动抓包服务..."
echo ""
mitmweb --listen-host 0.0.0.0 --listen-port 8080 --web-host 127.0.0.1 --web-port 8081

# 清理
clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    ✅ 抓包完成！                           ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}太棒了！你已经成功抓到数据了！${NC}"
echo ""
echo -e "${YELLOW}下一步要做：${NC}"
echo ""
echo "  1️⃣  在浏览器中找到登录相关的请求"
echo "      （看 URL 里有没有 login、auth 之类的字眼）"
echo ""
echo "  2️⃣  截图给我，或者复制 URL 和参数告诉我"
echo ""
echo "  3️⃣  我会根据这些数据更新网页版代码"
echo ""
echo -e "${RED}⚠️  重要：记得关闭 iPhone 的代理！${NC}"
echo ""
echo "  设置 → 无线局域网 → WiFi ⓘ → 配置代理 → 关闭"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
