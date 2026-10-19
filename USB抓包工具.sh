#!/bin/bash
# 移动爱家 - USB抓包工具（数据线版）
# 最简单的方案，插上数据线就能用！

clear

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║    📱 移动爱家 - USB抓包工具               ║"
echo "║                                           ║"
echo "║    用数据线连接，超级简单！                 ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# 检查是否有iPhone连接
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 1/3] 检查iPhone连接状态...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 获取iPhone的UDID
UDID=$(system_profiler SPUSBDataType 2>/dev/null | grep -A 11 "iPhone" | grep "Serial Number:" | awk '{print $3}')

if [ -z "$UDID" ]; then
    echo -e "${RED}❌ 没有检测到iPhone！${NC}"
    echo ""
    echo -e "${YELLOW}请按照以下步骤操作：${NC}"
    echo ""
    echo "  1️⃣  用数据线连接 iPhone 和 Mac"
    echo "  2️⃣  在 iPhone 上点击「信任此电脑」"
    echo "  3️⃣  重新运行本脚本"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ 已检测到iPhone！${NC}"
echo -e "${BLUE}设备ID: ${UDID}${NC}"
echo ""
sleep 2

# 创建虚拟网络接口
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 2/3] 准备抓包环境...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 创建rvi接口（需要sudo）
echo -e "${YELLOW}需要创建虚拟网络接口，请输入Mac密码：${NC}"
sudo rvictl -s $UDID > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 创建接口失败${NC}"
    echo "可能需要先安装 Xcode Command Line Tools"
    echo "运行命令：xcode-select --install"
    exit 1
fi

# 获取接口名称
RVI_INTERFACE=$(ifconfig | grep rvi | awk '{print $1}' | tr -d ':')

if [ -z "$RVI_INTERFACE" ]; then
    echo -e "${RED}❌ 找不到虚拟接口${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 虚拟接口已创建: ${RVI_INTERFACE}${NC}"
echo ""
sleep 1

# 开始抓包
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[步骤 3/3] 开始抓包！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}现在请在 iPhone 上操作：${NC}"
echo ""
echo "  1️⃣  打开「移动爱家」App"
echo "  2️⃣  输入手机号和密码"
echo "  3️⃣  点击登录"
echo "  4️⃣  登录成功后，随便点开一个摄像头"
echo ""
echo -e "${GREEN}电脑会自动记录所有请求！${NC}"
echo ""
echo -e "${RED}抓包完成后，按 Ctrl+C 停止${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
sleep 3

# 创建输出目录
OUTPUT_DIR=~/Desktop/mobile_home_web/captures
mkdir -p $OUTPUT_DIR
CAPTURE_FILE="$OUTPUT_DIR/移动爱家_$(date +%Y%m%d_%H%M%S).pcap"

echo "正在抓包中..."
echo "抓包文件保存位置: $CAPTURE_FILE"
echo ""

# 开始抓包（只抓取HTTP/HTTPS流量）
sudo tcpdump -i $RVI_INTERFACE -w $CAPTURE_FILE 'tcp port 80 or tcp port 443 or tcp port 8080'

# 清理
echo ""
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}抓包已停止！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 删除虚拟接口
echo "正在清理..."
sudo rvictl -x $UDID > /dev/null 2>&1

echo ""
echo -e "${GREEN}✅ 清理完成！${NC}"
echo ""

# 分析抓包文件
echo -e "${YELLOW}正在分析抓包数据...${NC}"
echo ""

# 提取HTTP请求
if command -v tshark &> /dev/null; then
    echo "找到的HTTP请求："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tshark -r $CAPTURE_FILE -Y "http.request" -T fields -e http.host -e http.request.uri 2>/dev/null | head -20
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo -e "${YELLOW}提示：安装 Wireshark 可以查看详细信息${NC}"
    echo "运行命令：brew install --cask wireshark"
fi

echo ""
echo -e "${GREEN}✅ 全部完成！${NC}"
echo ""
echo "抓包文件已保存到："
echo "$CAPTURE_FILE"
echo ""
echo -e "${YELLOW}下一步：${NC}"
echo ""
echo "1️⃣  用 Wireshark 打开抓包文件查看详细信息"
echo "    命令：open $CAPTURE_FILE"
echo ""
echo "2️⃣  或者把文件发给我，我来分析"
echo ""
echo "3️⃣  或者截图给我看看有哪些请求"
echo ""
