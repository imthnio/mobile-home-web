# AI 协作指南

## 给其他AI助手的说明

如果你接手这个项目，这里是你需要知道的关键信息：

## 📍 项目位置
- **主项目**：`/Users/cat/Desktop/mobile_home_web/`
- **GitHub**：https://github.com/imthnio/mobile-home-web
- **用户GitHub账号**：imthnio

## 🎯 项目目标
为移动爱家App（中国移动的智能家居摄像头管理App）制作网页版，能够查看真实摄像头画面。

## 📊 当前进度

### ✅ 已完成
1. **网页界面** - `index.html`（使用真实抓包数据）
2. **抓包工具** - 位于 `/Users/cat/Desktop/抓包工具箱/`
3. **真实设备数据** - 从APK和抓包提取，保存在 `~/Desktop/移动爱家_真实设备数据.json`
4. **APK逆向** - APK已下载并解压到 `~/Desktop/移动爱家_解压/`

### ⚠️ 核心问题
**移动爱家App有严格的安全保护**：
1. **SSL Pinning** - 开启抓包时App检测到证书就无法登录
2. **API签名加密** - 直接调用API会返回签名错误
3. **缺少完整登录流程** - 因SSL Pinning无法抓到登录请求

### 🔧 技术栈
- 纯HTML + CSS + JavaScript（无需构建工具）
- 设计风格：深色主题，流体排版，Grid布局
- 配色：青蓝主色 (#38BDF8)，深色背景 (#05070C系列)

## 📁 重要文件

### 项目文件
```
/Users/cat/Desktop/mobile_home_web/
├── index.html           # 当前版本（静态数据）
├── complete.html        # 旧版本（模拟数据，带登录）
├── captures/            # 抓包数据存放处
└── README.md           # 项目说明文档
```

### 参考文档
```
/Users/cat/Desktop/
├── 移动爱家项目总结.md           # 完整项目总结
├── 移动爱家_API分析.txt          # API详细分析
├── 移动爱家_API文档.md           # API使用文档
├── 移动爱家_真实设备数据.json    # 设备数据
└── 测试API.sh                   # API测试脚本
```

### 抓包数据
```
/Users/cat/Desktop/921_1792446170443/
- 包含129个网络请求的抓包数据
- 用Charles在2026年抓取
```

### APK文件
```
/Users/cat/Desktop/
├── 移动爱家.apk           # 原始APK（303MB）
└── 移动爱家_解压/         # 解压后的文件
```

## 🔐 数据获取

需要用户自己的账号Token和设备信息，通过抓包工具获取：

```bash
cd /Users/cat/Desktop/抓包工具箱
./一键抓包.sh
```

抓包后可以从数据中提取：
- uid（用户ID）
- usertoken（认证Token）
- deviceid（设备ID）
- 其他设备信息

**注意**：Token会过期，过期后需要重新抓包。

## 🌐 API信息

### 核心域名
- `base.hjq.komect.com` - 基础API
- `video.hjq.komect.com` - 视频API
- `esd-media.camera.komect.com` - 设备列表

### 认证方式
所有请求都需要：
- `uid` - 用户ID
- `usertoken` - 用户Token
- 签名算法（暂未破解）

### 已知接口
- 获取设备列表：`POST /esd-media/esd/v1/device/list`
- 获取设备详情：需要签名
- 获取视频流：需要破解协议

## 🚀 三个可选方案

### 方案A：反编译APK找加密算法 ⭐ 推荐但费时
**优势**：完整实现所有功能  
**难度**：高，需要Java环境和逆向经验  
**步骤**：
1. 使用jadx或jd-gui反编译APK
2. 查找API请求相关代码
3. 提取签名算法
4. 用JavaScript重新实现

**工具**：可以使用 https://github.com/morluto/rea （用户记忆中的逆向工具）

### 方案B：静态展示抓包数据 ✅ 当前方案
**优势**：快速，能看到真实设备  
**难度**：低  
**限制**：Token会过期，无法播放视频

### 方案C：寻找开源破解方案
**优势**：可能有现成代码  
**难度**：中等  
**行动**：搜索GitHub/网络是否有人破解过移动爱家API

## 🛠️ 开发环境

### 用户系统
- macOS
- GitHub CLI 已安装并认证
- 使用HTTPS协议连接GitHub
- **特殊要求**：用户要求直接推送到main分支，不创建PR

### 提交代码步骤
```bash
cd ~/Desktop/mobile_home_web
git add .
git commit -m "你的提交信息"
git push origin main  # 直接推送到main
```

## 🎨 设计规范

用户使用的是一套特定的设计品味（见system prompt中的design_sense）：
- **配色**：深色背景（#05070C系列），青蓝主色（#38BDF8）
- **排版**：使用 `clamp()` 实现流体字体大小
- **布局**：CSS Grid为主，Flexbox为辅
- **圆角**：大圆角（999px的pill按钮，50%的圆形头像）
- **Token化**：用CSS变量管理间距、颜色、阴影

## 📝 用户偏好（从记忆中提取）

1. **自动化优先** - 用户是电脑新手，要尽量自动化，不要让用户手动操作
2. **直接推main** - 修改代码后直接推送到main分支
3. **清理临时文件** - 任务完成后删除测试文件和下载的安装包
4. **中文交流** - 用中文回答，解释要通俗易懂

## 🔍 如何继续这个项目

### 如果用户想要完整功能
1. 先用web_search搜索是否有现成的移动爱家API破解方案
2. 如果没有，建议反编译APK，查找签名算法
3. 提取算法后，用JavaScript重新实现
4. 测试API调用，确保能获取设备列表和视频流

### 如果用户只想优化当前页面
1. 改进UI/UX设计
2. 添加更多设备信息展示
3. 优化缩略图加载
4. 添加错误处理

### 如果用户想更新数据
1. 指导用户使用 `/Users/cat/Desktop/抓包工具箱/` 中的工具重新抓包
2. 提取新的Token和设备数据
3. 更新 `index.html` 中的数据

## 🆘 遇到问题时

### Token过期
```bash
# 运行抓包工具重新获取
cd /Users/cat/Desktop/抓包工具箱
./一键抓包.sh
```

### API调用失败
- 检查 `~/Desktop/移动爱家_API文档.md` 了解已知的API端点
- 查看 `~/Desktop/测试API.sh` 看之前的测试方式
- 考虑是否需要破解签名算法

### 找不到文件
- 项目在 `/Users/cat/Desktop/mobile_home_web/`
- 文档在 `/Users/cat/Desktop/` 目录下
- 抓包数据在 `/Users/cat/Desktop/921_1792446170443/`

## 📚 推荐阅读顺序

如果你是新接手的AI，建议按这个顺序了解项目：

1. 📄 `/Users/cat/Desktop/移动爱家项目总结.md` - 了解全貌
2. 📊 `/Users/cat/Desktop/mobile_home_web/README.md` - 了解代码
3. 🔍 `/Users/cat/Desktop/移动爱家_API文档.md` - 了解API
4. 📱 `/Users/cat/Desktop/mobile_home_web/index.html` - 看当前实现

## ✅ 验证要点

修改代码后，务必：
1. **实际运行**一遍网页，确认功能正常
2. **提交到GitHub**，让代码同步
3. **简短汇报**结果，告诉用户做了什么

## 🚫 注意事项

- **不要**删除用户的设计文件（psd、cps、fcp等）
- **不要**自动清理文件，必须先询问用户
- **不要**使用sudo命令（会提示密码失败）
- **不要**创建PR，直接推送到main分支

---

**最后更新**：2026-10-20  
**文档版本**：v1.0

如有疑问，查看用户的记忆（session facts顶部的"你记住的关于用户的事"）或直接询问用户。
