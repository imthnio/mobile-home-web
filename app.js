// 移动爱家网页版 - 完整可用版本（模拟数据）
// 等抓包完成后，只需要替换 API 地址即可

class MobileHomeApp {
    constructor() {
        this.currentUser = null;
        this.devices = [];
        this.init();
    }

    init() {
        // 检查是否已登录
        const savedUser = localStorage.getItem('mobile_home_user');
        if (savedUser) {
            this.currentUser = JSON.parse(savedUser);
            this.showDeviceList();
        } else {
            this.showLogin();
        }

        // 绑定事件
        this.bindEvents();
    }

    bindEvents() {
        // 登录方式切换
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
                
                const type = e.target.dataset.tab;
                document.querySelectorAll('.tab-content').forEach(content => {
                    content.classList.remove('active');
                });
                document.getElementById(`${type}-tab`).classList.add('active');
            });
        });

        // 密码登录
        document.getElementById('password-login-btn')?.addEventListener('click', () => {
            this.handlePasswordLogin();
        });

        // 验证码登录
        document.getElementById('sms-login-btn')?.addEventListener('click', () => {
            this.handleSmsLogin();
        });

        // 发送验证码
        document.getElementById('send-code-btn')?.addEventListener('click', () => {
            this.sendVerificationCode();
        });

        // 退出登录
        document.getElementById('logout-btn')?.addEventListener('click', () => {
            this.handleLogout();
        });

        // 回车登录
        document.querySelectorAll('input').forEach(input => {
            input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    const activeTab = document.querySelector('.tab-content.active');
                    if (activeTab.id === 'password-tab') {
                        this.handlePasswordLogin();
                    } else {
                        this.handleSmsLogin();
                    }
                }
            });
        });
    }

    showLogin() {
        document.getElementById('login-container').style.display = 'flex';
        document.getElementById('device-container').style.display = 'none';
    }

    showDeviceList() {
        document.getElementById('login-container').style.display = 'none';
        document.getElementById('device-container').style.display = 'block';
        
        // 显示用户信息
        if (this.currentUser) {
            document.getElementById('user-phone').textContent = this.currentUser.phone;
        }
        
        // 加载设备列表
        this.loadDevices();
    }

    async handlePasswordLogin() {
        const phone = document.getElementById('phone').value.trim();
        const password = document.getElementById('password').value.trim();

        if (!phone || !password) {
            this.showMessage('请输入手机号和密码', 'error');
            return;
        }

        if (!/^1[3-9]\d{9}$/.test(phone)) {
            this.showMessage('手机号格式不正确', 'error');
            return;
        }

        const btn = document.getElementById('password-login-btn');
        btn.disabled = true;
        btn.textContent = '登录中...';

        try {
            // 模拟 API 调用
            await this.simulateLogin(phone, password);
            
            this.currentUser = {
                phone: phone,
                loginTime: new Date().toISOString()
            };
            
            localStorage.setItem('mobile_home_user', JSON.stringify(this.currentUser));
            
            this.showMessage('登录成功！', 'success');
            setTimeout(() => this.showDeviceList(), 500);
            
        } catch (error) {
            this.showMessage(error.message, 'error');
        } finally {
            btn.disabled = false;
            btn.textContent = '登录';
        }
    }

    async handleSmsLogin() {
        const phone = document.getElementById('sms-phone').value.trim();
        const code = document.getElementById('verify-code').value.trim();

        if (!phone || !code) {
            this.showMessage('请输入手机号和验证码', 'error');
            return;
        }

        if (!/^1[3-9]\d{9}$/.test(phone)) {
            this.showMessage('手机号格式不正确', 'error');
            return;
        }

        const btn = document.getElementById('sms-login-btn');
        btn.disabled = true;
        btn.textContent = '登录中...';

        try {
            await this.simulateLogin(phone, code);
            
            this.currentUser = {
                phone: phone,
                loginTime: new Date().toISOString()
            };
            
            localStorage.setItem('mobile_home_user', JSON.stringify(this.currentUser));
            
            this.showMessage('登录成功！', 'success');
            setTimeout(() => this.showDeviceList(), 500);
            
        } catch (error) {
            this.showMessage(error.message, 'error');
        } finally {
            btn.disabled = false;
            btn.textContent = '登录';
        }
    }

    async sendVerificationCode() {
        const phone = document.getElementById('sms-phone').value.trim();
        
        if (!phone) {
            this.showMessage('请输入手机号', 'error');
            return;
        }

        if (!/^1[3-9]\d{9}$/.test(phone)) {
            this.showMessage('手机号格式不正确', 'error');
            return;
        }

        const btn = document.getElementById('send-code-btn');
        btn.disabled = true;

        try {
            // 模拟发送验证码
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            this.showMessage('验证码已发送（演示：123456）', 'success');
            
            // 倒计时
            let countdown = 60;
            const timer = setInterval(() => {
                countdown--;
                btn.textContent = `${countdown}秒后重试`;
                
                if (countdown <= 0) {
                    clearInterval(timer);
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                }
            }, 1000);
            
        } catch (error) {
            this.showMessage('发送失败，请稍后重试', 'error');
            btn.disabled = false;
        }
    }

    async loadDevices() {
        const container = document.getElementById('device-list');
        container.innerHTML = '<div class="loading">加载设备列表中...</div>';

        try {
            // 模拟 API 调用
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // 模拟设备数据
            this.devices = [
                {
                    id: '1',
                    name: '客厅摄像头',
                    online: true,
                    location: '客厅',
                    thumbnail: 'https://via.placeholder.com/320x180?text=客厅摄像头'
                },
                {
                    id: '2',
                    name: '卧室摄像头',
                    online: true,
                    location: '卧室',
                    thumbnail: 'https://via.placeholder.com/320x180?text=卧室摄像头'
                },
                {
                    id: '3',
                    name: '门口摄像头',
                    online: false,
                    location: '门口',
                    thumbnail: 'https://via.placeholder.com/320x180?text=门口摄像头'
                },
                {
                    id: '4',
                    name: '厨房摄像头',
                    online: true,
                    location: '厨房',
                    thumbnail: 'https://via.placeholder.com/320x180?text=厨房摄像头'
                }
            ];
            
            this.renderDevices();
            
        } catch (error) {
            container.innerHTML = '<div class="error">加载失败，请刷新重试</div>';
        }
    }

    renderDevices() {
        const container = document.getElementById('device-list');
        
        if (this.devices.length === 0) {
            container.innerHTML = '<div class="empty">暂无设备</div>';
            return;
        }

        container.innerHTML = this.devices.map(device => `
            <div class="device-card ${device.online ? '' : 'offline'}" onclick="app.playVideo('${device.id}')">
                <img src="${device.thumbnail}" alt="${device.name}">
                <div class="device-info">
                    <div class="device-name">${device.name}</div>
                    <div class="device-status">
                        <span class="status-dot ${device.online ? 'online' : 'offline'}"></span>
                        ${device.online ? '在线' : '离线'}
                    </div>
                    <div class="device-location">📍 ${device.location}</div>
                </div>
                ${device.online ? '<button class="play-btn" onclick="event.stopPropagation(); app.playVideo(\'' + device.id + '\')">▶️ 播放</button>' : ''}
            </div>
        `).join('');
    }

    playVideo(deviceId) {
        const device = this.devices.find(d => d.id === deviceId);
        
        if (!device) {
            this.showMessage('设备不存在', 'error');
            return;
        }

        if (!device.online) {
            this.showMessage('设备离线，无法播放', 'error');
            return;
        }

        // 显示视频弹窗
        const modal = document.getElementById('video-modal');
        const title = document.getElementById('modal-device-name');
        const video = document.getElementById('video-player');
        
        title.textContent = device.name;
        modal.style.display = 'flex';
        
        // 这里应该加载真实的视频流
        // video.src = device.streamUrl;
        this.showMessage('演示模式：实际使用时这里会播放视频', 'info');
    }

    handleLogout() {
        if (confirm('确定要退出登录吗？')) {
            localStorage.removeItem('mobile_home_user');
            this.currentUser = null;
            this.devices = [];
            this.showLogin();
            this.showMessage('已退出登录', 'success');
        }
    }

    async simulateLogin(username, password) {
        // 模拟网络延迟
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // 这里应该是真实的 API 调用
        // const response = await fetch('https://ydaj.10086.cn/api/login', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({ phone: username, password: password })
        // });
        
        // 模拟登录成功（演示用）
        // 真实环境中，任何手机号+密码都会成功（仅用于测试界面）
        return { success: true, token: 'demo_token_' + Date.now() };
    }

    showMessage(message, type = 'info') {
        // 创建消息提示
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        
        document.body.appendChild(toast);
        
        // 显示动画
        setTimeout(() => toast.classList.add('show'), 10);
        
        // 3秒后移除
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
}

// 关闭视频弹窗
function closeVideoModal() {
    const modal = document.getElementById('video-modal');
    const video = document.getElementById('video-player');
    
    modal.style.display = 'none';
    video.pause();
    video.src = '';
}

// 点击弹窗外部关闭
document.getElementById('video-modal')?.addEventListener('click', (e) => {
    if (e.target.id === 'video-modal') {
        closeVideoModal();
    }
});

// 初始化应用
let app;
window.addEventListener('DOMContentLoaded', () => {
    app = new MobileHomeApp();
});

// 添加 Toast 样式
const style = document.createElement('style');
style.textContent = `
    .toast {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 25px;
        border-radius: 8px;
        color: white;
        font-size: 14px;
        opacity: 0;
        transform: translateX(400px);
        transition: all 0.3s ease;
        z-index: 10000;
        max-width: 300px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }

    .toast.show {
        opacity: 1;
        transform: translateX(0);
    }

    .toast-success {
        background: linear-gradient(135deg, #6EE7B7 0%, #10B981 100%);
    }

    .toast-error {
        background: linear-gradient(135deg, #F87171 0%, #EF4444 100%);
    }

    .toast-info {
        background: linear-gradient(135deg, #60A5FA 0%, #3B82F6 100%);
    }

    .loading, .empty, .error {
        text-align: center;
        padding: 60px 20px;
        color: #6B7280;
        font-size: 16px;
    }

    .error {
        color: #EF4444;
    }

    .device-card.offline {
        opacity: 0.6;
    }

    .device-card.offline img {
        filter: grayscale(100%);
    }
`;
document.head.appendChild(style);
