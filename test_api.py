#!/usr/bin/env python3
"""
移动爱家 API 测试工具
测试从 APK 中提取的服务器地址是否可用
"""

import requests
import json

# 从 cloud_prod.ini 提取的服务器列表
SERVERS = {
    'API服务器': 'https://api-media.camera.komect.com',
    'Soul视频服务器': 'https://soul-media.camera.komect.com',
    'BMS设备管理': 'https://bms-media.camera.komect.com',
    'CAS认证服务': 'https://caas.blurams.cn',
    'IoT网关': 'https://gwapi.blurams.cn',
    '文件服务器': 'https://file.blurams.cn',
    '广告服务器': 'https://ads.blurams.cn',
    'H5服务器': 'https://bf-h-pro.blurams.cn',
    'DNS服务器': 'https://aicare.komect.com',
}

# 可能的 API 端点
ENDPOINTS = [
    '/api/user/login',
    '/api/v1/user/login',
    '/api/v2/user/login',
    '/api/v3/user/login',
    '/v1/user/login',
    '/v2/user/login',
    '/v3/user/login',
    '/user/login',
    '/login',
    '/api/device/list',
    '/api/v1/device/list',
    '/v1/device/list',
    '/device/list',
]

def test_server(name, url):
    """测试服务器是否在线"""
    try:
        response = requests.get(url, timeout=5, verify=False)
        return True, response.status_code
    except requests.exceptions.SSLError:
        return True, 'SSL'
    except requests.exceptions.ConnectionError:
        return False, 'ConnectionError'
    except requests.exceptions.Timeout:
        return False, 'Timeout'
    except Exception as e:
        return False, str(e)

def test_endpoint(server_url, endpoint):
    """测试具体的 API 端点"""
    url = server_url + endpoint
    headers = {
        'User-Agent': 'MobileHome/12.10.0 (Android 11; blurams)',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
    
    try:
        # 尝试 GET
        response = requests.get(url, headers=headers, timeout=3, verify=False)
        if response.status_code != 404:
            return 'GET', response.status_code, response.text[:200]
    except:
        pass
    
    try:
        # 尝试 POST
        response = requests.post(
            url, 
            headers=headers, 
            json={'test': 'ping'}, 
            timeout=3, 
            verify=False
        )
        if response.status_code != 404:
            return 'POST', response.status_code, response.text[:200]
    except:
        pass
    
    return None, None, None

print("="*70)
print("移动爱家 API 服务器测试")
print("="*70)

# 忽略 SSL 警告
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# 1. 测试服务器在线状态
print("\n[1] 测试服务器在线状态...")
print("-"*70)
online_servers = []
for name, url in SERVERS.items():
    is_online, status = test_server(name, url)
    status_text = f"✅ 在线 (状态: {status})" if is_online else f"❌ 离线 ({status})"
    print(f"{name:15} {url:50} {status_text}")
    if is_online:
        online_servers.append((name, url))

# 2. 测试 API 端点
print("\n[2] 测试 API 端点...")
print("-"*70)
found_endpoints = []

for name, server_url in online_servers:
    print(f"\n正在测试 {name}...")
    for endpoint in ENDPOINTS:
        method, status, body = test_endpoint(server_url, endpoint)
        if method:
            print(f"  ✅ {method:4} {endpoint:30} -> {status}")
            if body:
                print(f"     响应: {body}")
            found_endpoints.append({
                'server': name,
                'url': server_url + endpoint,
                'method': method,
                'status': status
            })

# 3. 总结
print("\n" + "="*70)
print("测试总结")
print("="*70)
print(f"在线服务器: {len(online_servers)}/{len(SERVERS)}")
print(f"发现的端点: {len(found_endpoints)}")

if found_endpoints:
    print("\n发现的可用端点：")
    for ep in found_endpoints:
        print(f"  {ep['method']:4} {ep['url']}")
    
    # 保存结果
    with open('api_test_results.json', 'w', encoding='utf-8') as f:
        json.dump(found_endpoints, f, indent=2, ensure_ascii=False)
    print("\n详细结果已保存到 api_test_results.json")
else:
    print("\n未发现可用端点，可能需要：")
    print("  1. 正确的认证信息")
    print("  2. 特定的请求头")
    print("  3. 通过抓包获取真实的 API 路径")

print("\n建议：")
print("  按照 IPHONE_GUIDE.md 的步骤进行抓包，获取真实的 API 调用")
print("="*70)
