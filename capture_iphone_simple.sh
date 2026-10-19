#!/bin/bash
# iPhone 超简单抓包脚本
# 使用 Mac 自带工具，无需在 iPhone 上配置

echo "======================================"
echo "  iPhone 抓包 - 超简单版"
echo "======================================"
echo ""

# 1. 检查是否连接了 iPhone
echo "[1/4] 检查 iPhone 连接..."
if ! system_profiler SPUSBDataType 2>/dev/null | grep -q "iPhone"; then
    echo "❌ 未检测到 iPhone"
    echo ""
    echo "请按以下步骤操作："
    echo "  1. 用数据线连接 iPhone 和 Mac"
    echo "  2. 在 iPhone 上点击「信任此电脑」"
    echo "  3. 重新运行此脚本"
    exit 1
fi

echo "✅ 已检测到 iPhone"

# 2. 获取 iPhone 的 UDID
echo ""
echo "[2/4] 获取 iPhone 信息..."
UDID=$(system_profiler SPUSBDataType 2>/dev/null | grep "Serial Number:" | awk '{print $3}' | head -1)

if [ -z "$UDID" ]; then
    echo "❌ 无法获取 iPhone UDID"
    echo "请确保："
    echo "  1. iPhone 已解锁"
    echo "  2. 已点击「信任此电脑」"
    exit 1
fi

echo "✅ UDID: $UDID"

# 3. 创建虚拟网络接口
echo ""
echo "[3/4] 创建虚拟网络接口..."
sudo rvictl -s $UDID

if [ $? -ne 0 ]; then
    echo "❌ 创建失败"
    echo "提示：如果提示接口已存在，说明之前创建过，可以继续"
fi

INTERFACE="rvi0"
echo "✅ 接口名称: $INTERFACE"

# 4. 开始抓包
echo ""
echo "[4/4] 开始抓包..."
echo ""
echo "======================================"
echo "  准备就绪！"
echo "======================================"
echo ""
echo "现在请在 iPhone 上操作："
echo "  1. 打开「移动爱家」App"
echo "  2. 输入手机号和密码"
echo "  3. 点击登录"
echo "  4. 打开一个摄像头查看监控"
echo ""
echo "抓包进行中...（按 Ctrl+C 停止）"
echo ""
echo "正在捕获的请求："
echo "--------------------------------------"

# 使用 tcpdump 抓包并实时解析
sudo tcpdump -i $INTERFACE -A -s 0 \
    'tcp port 443 or tcp port 80' \
    2>/dev/null | while read line; do
    
    # 查找包含 API 路径的行
    if echo "$line" | grep -qE "(POST|GET|PUT|DELETE) /(api|v1|v2|v3|user|device|login|sms)"; then
        echo "🔍 发现 API 请求:"
        echo "$line"
        echo "--------------------------------------"
    fi
    
    # 查找 JSON 数据
    if echo "$line" | grep -qE '^\{.*\}$'; then
        echo "📦 数据包:"
        echo "$line" | python3 -m json.tool 2>/dev/null || echo "$line"
        echo "--------------------------------------"
    fi
done

# 清理
echo ""
echo ""
echo "清理虚拟接口..."
sudo rvictl -x $UDID
echo "✅ 完成"
