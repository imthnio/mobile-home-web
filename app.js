// 移动爱家网页版 - JavaScript
// 基于 Blurams API 的实现

class MobileHomeAPI {
    constructor() {
        // 从 APK 分析中获取的真实服务器地址
        this.apiServer = 'https://api-media.camera.komect.com';
        this.soulServer = 'https://soul-media.camera.komect.com'; // 视频流服务器
        this.bmsServer = 'https://bms-media.camera.komect.com'; // 设备管理服务器
        this.casServer = 'https://caas.blurams.cn'; // 认证服务器
        this.iotServer = 'https://gwapi.blurams.cn'; // IoT 网关
        this.stunServer = 'stun.blurams.cn'; // STUN 服务器
        this.relayServer = 'relaycn.blurams.cn'; // 中继服务器
        
        this.token = localStorage.getItem('token');
        this.userId = localStorage.getItem('userId');
    }

    // 登录
    async login(username, password) {
        // 注意：这里需要根据实际抓包结果调整
        // Blurams API 通常使用以下格式
        const endpoints = [
            '/v3/user/login',
            '/api/user/login',
            '/user/login'
        ];

        for (const endpoint of endpoints) {
            try {
                const response = await fetch(this.apiServer + endpoint, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'User-Agent': 'MobileHome/12.10.0',
                    },
                    body: JSON.stringify({
                        username: username,
                        password: password,
                        // 可能需要的其他参数
                        deviceId: this.getDeviceId(),
                        appVersion: '12.10.0',
                        platform: 'web'
                    })
                });

                if (response.ok) {
                    const data = await response.json();
                    if (data.code === 0 || data.success) {
                        this.token = data.data?.token || data.token;
                        this.userId = data.data?.userId || data.userId;
                        
                        localStorage.setItem('token', this.token);
                        localStorage.setItem('userId', this.userId);
                        
                        return { success: true, data };
                    }
                }
            } catch (error) {
                console.log(`尝试 ${endpoint} 失败:`, error);
            }
        }

        throw new Error('登录失败，请检查账号密码');
    }

    // 获取设备列表
    async getDevices() {
        const endpoints = [
            '/v3/device/list',
            '/api/device/list',
            '/device/list'
        ];

        for (const endpoint of endpoints) {
            try {
                const response = await fetch(this.apiServer + endpoint, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${this.token}`,
                        'User-Agent': 'MobileHome/12.10.0',
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    if (data.code === 0 || data.success) {
                        return data.data?.devices || data.devices || [];
                    }
                }
            } catch (error) {
                console.log(`尝试 ${endpoint} 失败:`, error);
            }
        }

        return [];
    }

    // 获取视频流地址
    async getVideoStream(deviceId) {
        const endpoints = [
            `/v3/device/${deviceId}/stream`,
            `/api/device/${deviceId}/stream`,
            `/device/${deviceId}/video`
        ];

        for (const endpoint of endpoints) {
            try {
                const response = await fetch(this.apiServer + endpoint, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${this.token}`,
                        'User-Agent': 'MobileHome/12.10.0',
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    if (data.code === 0 || data.success) {
                        return data.data?.url || data.url || data.rtspUrl;
                    }
                }
            } catch (error) {
                console.log(`尝试 ${endpoint} 失败:`, error);
            }
        }

        return null;
    }

    // 生成设备ID
    getDeviceId() {
        let deviceId = localStorage.getItem('deviceId');
        if (!deviceId) {
            deviceId = 'web_' + Math.random().toString(36).substr(2, 9);
            localStorage.setItem('deviceId', deviceId);
        }
        return deviceId;
    }

    // 登出
    logout() {
        localStorage.removeItem('token');
        localStorage.removeItem('userId');
        this.token = null;
        this.userId = null;
    }

    // 检查是否已登录
    isLoggedIn() {
        return !!this.token;
    }
}

// UI 控制器
class UIController {
    constructor(api) {
        this.api = api;
        this.initElements();
        this.bindEvents();
        this.checkLoginStatus();
    }

    initElements() {
        this.loginSection = document.getElementById('loginSection');
        this.dashboard = document.getElementById('dashboard');
        this.loginForm = document.getElementById('loginForm');
        this.errorMsg = document.getElementById('errorMsg');
        this.loginBtn = document.getElementById('loginBtn');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.camerasGrid = document.getElementById('camerasGrid');
        this.loadingCameras = document.getElementById('loadingCameras');
        this.videoModal = document.getElementById('videoModal');
        this.videoPlayer = document.getElementById('videoPlayer');
        this.videoTitle = document.getElementById('videoTitle');
        this.closeVideoBtn = document.getElementById('closeVideoBtn');
        this.loadingVideo = document.getElementById('loadingVideo');
    }

    bindEvents() {
        this.loginForm.addEventListener('submit', (e) => this.handleLogin(e));
        this.logoutBtn.addEventListener('click', () => this.handleLogout());
        this.closeVideoBtn.addEventListener('click', () => this.closeVideo());
    }

    checkLoginStatus() {
        if (this.api.isLoggedIn()) {
            this.showDashboard();
        } else {
            this.showLogin();
        }
    }

    showLogin() {
        this.loginSection.classList.remove('hidden');
        this.dashboard.classList.add('hidden');
    }

    showDashboard() {
        this.loginSection.classList.add('hidden');
        this.dashboard.classList.remove('hidden');
        this.loadDevices();
    }

    showError(message) {
        this.errorMsg.textContent = message;
        this.errorMsg.classList.remove('hidden');
        setTimeout(() => {
            this.errorMsg.classList.add('hidden');
        }, 5000);
    }

    async handleLogin(e) {
        e.preventDefault();
        
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        
        this.loginBtn.disabled = true;
        this.loginBtn.textContent = '登录中...';

        try {
            await this.api.login(username, password);
            this.showDashboard();
        } catch (error) {
            this.showError(error.message);
        } finally {
            this.loginBtn.disabled = false;
            this.loginBtn.textContent = '登录';
        }
    }

    handleLogout() {
        this.api.logout();
        this.showLogin();
    }

    async loadDevices() {
        this.loadingCameras.classList.remove('hidden');
        this.camerasGrid.innerHTML = '';

        try {
            const devices = await this.api.getDevices();
            
            if (devices.length === 0) {
                this.camerasGrid.innerHTML = `
                    <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: var(--text-secondary);">
                        <p>暂无设备</p>
                        <p style="font-size: 0.875rem; margin-top: 0.5rem;">请在移动爱家 App 中添加设备</p>
                    </div>
                `;
            } else {
                devices.forEach(device => {
                    this.renderCameraCard(device);
                });
            }
        } catch (error) {
            this.camerasGrid.innerHTML = `
                <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: #EF4444;">
                    <p>加载失败</p>
                    <p style="font-size: 0.875rem; margin-top: 0.5rem;">${error.message}</p>
                </div>
            `;
        } finally {
            this.loadingCameras.classList.add('hidden');
        }
    }

    renderCameraCard(device) {
        const card = document.createElement('div');
        card.className = 'camera-card';
        card.innerHTML = `
            <div class="camera-preview">
                <span style="color: var(--text-secondary); font-size: 3rem;">📹</span>
            </div>
            <div class="camera-name">${device.name || '未命名设备'}</div>
            <div class="camera-status ${device.online ? 'status-online' : 'status-offline'}">
                ${device.online ? '● 在线' : '● 离线'}
            </div>
        `;

        card.addEventListener('click', () => {
            if (device.online) {
                this.openVideo(device);
            }
        });

        this.camerasGrid.appendChild(card);
    }

    async openVideo(device) {
        this.videoModal.classList.add('active');
        this.videoTitle.textContent = device.name || '未命名设备';
        this.videoPlayer.style.display = 'none';
        this.loadingVideo.classList.remove('hidden');

        try {
            const streamUrl = await this.api.getVideoStream(device.id || device.deviceId);
            
            if (streamUrl) {
                // 如果是 RTSP 流，需要转换
                if (streamUrl.startsWith('rtsp://')) {
                    this.showError('检测到 RTSP 流，需要转码服务器支持。请参考 README.md 配置转码服务器。');
                    this.loadingVideo.innerHTML = `
                        <p style="color: var(--text-secondary);">
                            RTSP 流地址：<br>
                            <code style="background: var(--surface-4); padding: 0.5rem; border-radius: 4px; display: inline-block; margin-top: 0.5rem;">
                                ${streamUrl}
                            </code>
                        </p>
                        <p style="margin-top: 1rem; font-size: 0.875rem; color: var(--text-secondary);">
                            你可以使用 VLC 播放器打开此地址观看
                        </p>
                    `;
                } else {
                    // HTTP/HLS 流可以直接播放
                    this.videoPlayer.src = streamUrl;
                    this.videoPlayer.style.display = 'block';
                    this.loadingVideo.classList.add('hidden');
                }
            } else {
                throw new Error('无法获取视频流地址');
            }
        } catch (error) {
            this.loadingVideo.innerHTML = `
                <p style="color: #EF4444;">加载失败: ${error.message}</p>
            `;
        }
    }

    closeVideo() {
        this.videoModal.classList.remove('active');
        this.videoPlayer.pause();
        this.videoPlayer.src = '';
    }
}

// 初始化应用
document.addEventListener('DOMContentLoaded', () => {
    const api = new MobileHomeAPI();
    const ui = new UIController(api);
    
    // 开发模式：显示调试信息
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        console.log('移动爱家网页版 - 开发模式');
        console.log('API 服务器:', api.apiServer);
        console.log('提示：这是一个逆向工程项目，API 端点需要通过抓包获取真实地址');
    }
});
