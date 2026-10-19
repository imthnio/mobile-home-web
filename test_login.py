#!/usr/bin/env python3
"""
测试移动爱家登录 API
"""

import requests
import json

# 禁用 SSL 警告
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# 测试不同的服务器和登录方式
servers = {
    'BMS': 'https://bms-media.camera.komect.com',
    'API': 'https://api-media.camera.komect.com',
}

endpoints = [
    '/api/user/login',
    '/api/v1/user/login', 
    '/v1/user/login',
    '/user/login',
]

# 测试数据
test_payloads = [
    # 方式1: 手机号+密码
    {
        'username': '13800138000',
        'password': 'test123456',
    },
    # 方式2: 手机号+密码+验证码
    {
        'phone': '13800138000',
        'password': 'test123456',
        'code': '123456',
    },
    # 方式3: 只有手机号（获取验证码）
    {
        'phone': '13800138000',
    },
    # 方式4: 更详细的参数
    {
        'username': '13800138000',
        'password': 'test123456',
        'deviceId': 'test_device_123',
        'appVersion': '12.10.0',
        'platform': 'android',
    }
]

headers = {
    'User-Agent': 'MobileHome/12.10.0 (Android 11; blurams)',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': 'zh-CN,zh;q=0.9',
}

print("="*70)
print("测试登录 API")
print("="*70)

for server_name, server_url in servers.items():
    print(f"\n[{server_name}] {server_url}")
    print("-"*70)
    
    for endpoint in endpoints:
        url = server_url + endpoint
        print(f"\n端点: {endpoint}")
        
        for i, payload in enumerate(test_payloads, 1):
            try:
                # 尝试 POST
                response = requests.post(
                    url,
                    headers=headers,
                    json=payload,
                    timeout=5,
                    verify=False
                )
                
                print(f"  测试 {i}: {list(payload.keys())}")
                print(f"    状态码: {response.status_code}")
                
                try:
                    data = response.json()
                    print(f"    响应: {json.dumps(data, ensure_ascii=False, indent=6)}")
                    
                    # 如果返回了有用信息，保存下来
                    if 'code' in data or 'msg' in data or 'message' in data:
                        print(f"    ✅ 发现有效响应格式")
                except:
                    print(f"    响应(非JSON): {response.text[:200]}")
                    
            except Exception as e:
                print(f"  测试 {i}: 错误 - {e}")

print("\n" + "="*70)
print("查找验证码相关端点")
print("="*70)

# 查找获取验证码的端点
sms_endpoints = [
    '/api/sms/send',
    '/api/v1/sms/send',
    '/v1/sms/send',
    '/api/user/sms',
    '/api/user/sendCode',
    '/api/user/getCode',
    '/user/sendSms',
    '/user/getVerifyCode',
    '/sms/send',
    '/sendSms',
]

for server_name, server_url in servers.items():
    print(f"\n[{server_name}]")
    for endpoint in sms_endpoints:
        url = server_url + endpoint
        try:
            response = requests.post(
                url,
                headers=headers,
                json={'phone': '13800138000'},
                timeout=3,
                verify=False
            )
            if response.status_code != 404:
                print(f"  ✅ {endpoint:30} -> {response.status_code}")
                try:
                    print(f"     {response.json()}")
                except:
                    print(f"     {response.text[:100]}")
        except:
            pass

print("\n完成!")
