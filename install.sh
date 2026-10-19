#!/bin/bash
# 移动爱家网页版 - 一键部署脚本
# 适用于 Ubuntu/Debian/CentOS 等 Linux VPS

set -e

echo "======================================"
echo "  移动爱家网页版 - 自动部署脚本"
echo "======================================"
echo ""

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ 无法检测操作系统"
    exit 1
fi

echo "✅ 检测到系统: $OS"

# 1. 安装依赖
echo ""
echo "[1/5] 安装依赖..."
if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip nginx
elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    sudo yum install -y python3 python3-pip nginx
else
    echo "⚠️  未知系统，尝试安装 python3..."
    command -v python3 >/dev/null 2>&1 || { echo "请手动安装 python3"; exit 1; }
fi

# 安装 Python 依赖
pip3 install flask flask-cors requests gunicorn

echo "✅ 依赖安装完成"

# 2. 创建项目目录
echo ""
echo "[2/5] 创建项目目录..."
PROJECT_DIR="/opt/mobile_home_web"
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR

echo "✅ 项目目录: $PROJECT_DIR"

# 3. 下载项目文件
echo ""
echo "[3/5] 创建项目文件..."

# 创建主服务器文件
cat > server.py << 'PYTHON_SERVER'
#!/usr/bin/env python3
"""
移动爱家网页版服务器
"""
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import requests
import hashlib
import time
import json

app = Flask(__name__, static_folder='.')
CORS(app)

# API 服务器配置
API_SERVER = 'https://bms-media.camera.komect.com'
SOUL_SERVER = 'https://soul-media.camera.komect.com'

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/<path:path>')
def static_files(path):
    return send_from_directory('.', path)

@app.route('/api/sms/send', methods=['POST'])
def send_sms():
    """发送验证码"""
    data = request.json
    phone = data.get('phone')
    
    if not phone:
        return jsonify({'code': 1, 'msg': '手机号不能为空'})
    
    # 这里需要真实的API调用
    # 目前返回模拟数据
    return jsonify({
        'code': 0,
        'msg': '验证码已发送（模拟）',
        'data': {
            'success': True,
            'message': '请查看控制台输出的验证码'
        }
    })

@app.route('/api/login', methods=['POST'])
def login():
    """登录接口"""
    data = request.json
    
    # 这里需要真实的API调用
    # 目前返回模拟数据用于测试界面
    return jsonify({
        'code': 0,
        'msg': '登录成功（模拟）',
        'data': {
            'token': 'mock_token_' + str(int(time.time())),
            'userId': 'mock_user_123',
            'username': data.get('username', 'test_user')
        }
    })

@app.route('/api/devices', methods=['GET'])
def get_devices():
    """获取设备列表"""
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    
    # 返回模拟数据
    return jsonify({
        'code': 0,
        'msg': '成功',
        'data': {
            'devices': [
                {
                    'id': 'camera_001',
                    'deviceId': 'camera_001',
                    'name': '客厅摄像头',
                    'online': True,
                    'type': 'camera'
                },
                {
                    'id': 'camera_002',
                    'deviceId': 'camera_002',
                    'name': '卧室摄像头',
                    'online': True,
                    'type': 'camera'
                },
                {
                    'id': 'camera_003',
                    'deviceId': 'camera_003',
                    'name': '门口摄像头',
                    'online': False,
                    'type': 'camera'
                }
            ]
        }
    })

@app.route('/api/device/<device_id>/stream', methods=['GET'])
def get_stream(device_id):
    """获取视频流地址"""
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    
    # 这里需要真实的API调用来获取RTSP/HLS流地址
    return jsonify({
        'code': 0,
        'msg': '成功',
        'data': {
            'url': f'rtsp://example.com/stream/{device_id}',
            'type': 'rtsp',
            'message': '需要真实API才能获取视频流'
        }
    })

if __name__ == '__main__':
    print("="*70)
    print("移动爱家网页版服务器启动")
    print("="*70)
    print("")
    print("⚠️  重要提示：")
    print("   目前使用的是模拟数据，登录和视频功能无法正常使用")
    print("   需要通过抓包获取真实API后才能完全工作")
    print("")
    print("访问地址：http://你的服务器IP:5000")
    print("")
    app.run(host='0.0.0.0', port=5000, debug=False)
PYTHON_SERVER

chmod +x server.py

# 创建前端文件
wget -q https://raw.githubusercontent.com/imthnio/mobile-home-web/main/index.html -O index.html 2>/dev/null || cat > index.html << 'HTML_FILE'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>移动爱家 - 网页版</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="loginSection" class="login-container">
        <div class="login-card">
            <div class="logo">🏠</div>
            <h1>移动爱家</h1>
            <p class="subtitle">网页版监控</p>
            
            <div class="login-tabs">
                <button class="tab-btn active" data-tab="password">密码登录</button>
                <button class="tab-btn" data-tab="sms">验证码登录</button>
            </div>
            
            <form id="loginForm" class="login-form active">
                <div class="form-group">
                    <label>手机号</label>
                    <input type="tel" id="username" placeholder="请输入手机号" required>
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" id="password" placeholder="请输入密码" required>
                </div>
                <button type="submit" id="loginBtn" class="btn-primary">登录</button>
            </form>
            
            <form id="smsLoginForm" class="login-form">
                <div class="form-group">
                    <label>手机号</label>
                    <input type="tel" id="smsPhone" placeholder="请输入手机号" required>
                </div>
                <div class="form-group">
                    <label>验证码</label>
                    <div class="code-input-group">
                        <input type="text" id="smsCode" placeholder="请输入验证码" required>
                        <button type="button" id="getSmsBtn" class="btn-get-code">获取验证码</button>
                    </div>
                </div>
                <button type="submit" id="smsLoginBtn" class="btn-primary">登录</button>
            </form>
            
            <div id="errorMsg" class="error-message hidden"></div>
            
            <div class="warning-box">
                ⚠️ 当前为演示模式，登录后可查看界面，但视频功能需要真实API
            </div>
        </div>
    </div>
    
    <div id="dashboard" class="dashboard hidden">
        <header class="dashboard-header">
            <div class="header-content">
                <h2>📹 我的监控</h2>
                <button id="logoutBtn" class="btn-logout">退出登录</button>
            </div>
        </header>
        
        <main class="dashboard-main">
            <div id="loadingCameras" class="loading hidden">
                <div class="spinner"></div>
                <p>加载中...</p>
            </div>
            
            <div id="camerasGrid" class="cameras-grid"></div>
        </main>
    </div>
    
    <div id="videoModal" class="video-modal">
        <div class="video-modal-content">
            <button id="closeVideoBtn" class="btn-close">×</button>
            <h3 id="videoTitle">摄像头</h3>
            <div class="video-container">
                <video id="videoPlayer" controls autoplay></video>
                <div id="loadingVideo" class="loading">
                    <div class="spinner"></div>
                    <p>加载视频流...</p>
                </div>
            </div>
        </div>
    </div>
    
    <script src="app.js"></script>
</body>
</html>
HTML_FILE

echo "✅ 项目文件创建完成"

# 4. 创建系统服务
echo ""
echo "[4/5] 创建系统服务..."

sudo tee /etc/systemd/system/mobile-home.service > /dev/null << SERVICE_FILE
[Unit]
Description=Mobile Home Web Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/python3 $PROJECT_DIR/server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_FILE

sudo systemctl daemon-reload
sudo systemctl enable mobile-home
sudo systemctl start mobile-home

echo "✅ 系统服务创建完成"

# 5. 配置防火墙
echo ""
echo "[5/5] 配置防火墙..."

if command -v ufw &> /dev/null; then
    sudo ufw allow 5000/tcp
    echo "✅ UFW 防火墙规则已添加"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=5000/tcp
    sudo firewall-cmd --reload
    echo "✅ Firewalld 防火墙规则已添加"
else
    echo "⚠️  未检测到防火墙，请手动开放 5000 端口"
fi

# 完成
echo ""
echo "======================================"
echo "  🎉 部署完成！"
echo "======================================"
echo ""
echo "服务状态: $(sudo systemctl is-active mobile-home)"
echo ""
echo "访问地址: http://$(curl -s ifconfig.me):5000"
echo "         或 http://你的服务器IP:5000"
echo ""
echo "管理命令:"
echo "  启动服务: sudo systemctl start mobile-home"
echo "  停止服务: sudo systemctl stop mobile-home"
echo "  重启服务: sudo systemctl restart mobile-home"
echo "  查看日志: sudo journalctl -u mobile-home -f"
echo ""
echo "⚠️  重要提示："
echo "  1. 目前是演示模式，使用模拟数据"
echo "  2. 要实现真实功能，需要通过抓包获取API"
echo "  3. 抓包教程在项目目录: $PROJECT_DIR/IPHONE_GUIDE.md"
echo ""
echo "======================================"
