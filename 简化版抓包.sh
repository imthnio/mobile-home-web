#!/bin/bash
# 移动爱家 - 简化版抓包工具
# 手动版，不需要自动检测

clear
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║    📱 移动爱家 - 抓包工具（简化版）        ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "⚠️  需要输入Mac密码来开始抓包"
echo ""
read -p "按回车键继续..."

# 创建输出目录
OUTPUT_DIR=~/Desktop/mobile_home_web/captures
mkdir -p $OUTPUT_DIR

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤1: 创建iPhone网络接口"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "请输入Mac密码："

# 列出所有rvi接口，如果有就先删除
sudo rvictl -x all 2>/dev/null

# 尝试为所有连接的iOS设备创建接口
echo ""
echo "正在创建虚拟网络接口..."
echo ""

# 使用cfgutil（如果有）或者让用户手动输入UDID
if command -v cfgutil &> /dev/null; then
    UDID=$(cfgutil list | head -1 | awk '{print $1}')
    if [ ! -z "$UDID" ]; then
        sudo rvictl -s $UDID
    fi
else
    # 让用户从iTunes或Finder复制UDID
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "需要获取iPhone的UDID"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "请按照以下步骤操作："
    echo ""
    echo "1️⃣  打开「访达」（Finder）"
    echo "2️⃣  在左侧边栏找到你的 iPhone"
    echo "3️⃣  点击iPhone名称下方的文字（会显示序列号等）"
    echo "4️⃣  多点击几次，直到显示「UDID」"
    echo "5️⃣  右键点击 UDID，选择「拷贝」"
    echo "6️⃣  回到这里，粘贴UDID"
    echo ""
    echo "或者跳过，直接用命令："
    echo "sudo rvictl -s \$(你的UDID)"
    echo ""
    read -p "请粘贴UDID，或按回车跳过: " USER_UDID
    
    if [ ! -z "$USER_UDID" ]; then
        sudo rvictl -s "$USER_UDID"
    else
        echo ""
        echo "跳过自动创建，尝试使用现有接口..."
    fi
fi

# 查找rvi接口
RVI_INTERFACE=$(ifconfig | grep "^rvi" | head -1 | awk '{print $1}' | tr -d ':')

if [ -z "$RVI_INTERFACE" ]; then
    echo ""
    echo "❌ 没有找到虚拟接口"
    echo ""
    echo "请手动运行以下命令："
    echo ""
    echo "1. 在「访达」中找到iPhone的UDID（参考上面的步骤）"
    echo "2. 运行命令："
    echo "   sudo rvictl -s <你的UDID>"
    echo "3. 然后重新运行本脚本"
    echo ""
    exit 1
fi

echo ""
echo "✅ 找到接口: $RVI_INTERFACE"
echo ""
sleep 2

# 开始抓包
CAPTURE_FILE="$OUTPUT_DIR/移动爱家_$(date +%Y%m%d_%H%M%S).pcap"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤2: 开始抓包！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "现在请在 iPhone 上操作："
echo ""
echo "  1️⃣  打开「移动爱家」App"
echo "  2️⃣  输入手机号和密码"
echo "  3️⃣  点击登录"
echo "  4️⃣  登录成功后，点开一个摄像头"
echo ""
echo "完成后按 Ctrl+C 停止抓包"
echo ""
echo "抓包文件: $CAPTURE_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 开始抓包
sudo tcpdump -i $RVI_INTERFACE -w "$CAPTURE_FILE" 2>&1

# 清理
echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "抓包已停止！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "正在清理..."
sudo rvictl -x all 2>/dev/null

echo ""
echo "✅ 完成！"
echo ""
echo "抓包文件保存在："
echo "$CAPTURE_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
