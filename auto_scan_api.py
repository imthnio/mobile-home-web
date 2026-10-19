#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
移动爱家 API 自动探测工具
通过智能试探找到正确的 API 接口
"""

import requests
import json
import hashlib
from urllib.parse import urljoin

class MobileHomeAPIScanner:
    def __init__(self):
        self.base_urls = [
            "https://ydaj.10086.cn",
            "https://ydaj.cn",
            "https://home.10086.cn",
            "https://api.ydaj.10086.cn",
        ]
        
        # 常见的登录路径
        self.login_paths = [
            "/api/login",
            "/api/user/login",
            "/api/v1/login",
            "/api/v2/login",
            "/api/auth/login",
            "/login",
            "/user/login",
            "/auth/login",
            "/account/login",
            "/sso/login",
        ]
        
        # 常见的 API 前缀
        self.api_prefixes = [
            "/api",
            "/api/v1",
            "/api/v2",
            "/mobile",
            "/app",
        ]
        
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MobileHome/3.0 (iPhone; iOS 15.0; Scale/3.00)',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        })
    
    def test_url(self, url):
        """测试 URL 是否可访问"""
        try:
            resp = self.session.get(url, timeout=5)
            return resp.status_code, resp.text[:200]
        except Exception as e:
            return None, str(e)
    
    def test_login_endpoint(self, url, data):
        """测试登录端点"""
        try:
            resp = self.session.post(url, json=data, timeout=10)
            return {
                'status': resp.status_code,
                'headers': dict(resp.headers),
                'body': resp.text[:500],
                'success': resp.status_code in [200, 201]
            }
        except Exception as e:
            return {
                'status': 'error',
                'error': str(e)
            }
    
    def scan(self):
        """扫描所有可能的 API 端点"""
        results = {
            'base_urls': {},
            'login_endpoints': [],
            'discoveries': []
        }
        
        print("🔍 开始扫描移动爱家 API...")
        print("=" * 60)
        
        # 1. 测试基础 URL
        print("\n[1/3] 测试基础 URL...")
        for base_url in self.base_urls:
            print(f"  测试: {base_url}")
            status, content = self.test_url(base_url)
            results['base_urls'][base_url] = {
                'status': status,
                'accessible': status is not None
            }
            if status:
                print(f"    ✅ 可访问 (状态码: {status})")
            else:
                print(f"    ❌ 无法访问")
        
        # 2. 测试登录端点
        print("\n[2/3] 测试登录端点...")
        test_data_variants = [
            {'phone': '13800138000', 'password': 'test123'},
            {'mobile': '13800138000', 'password': 'test123'},
            {'username': '13800138000', 'password': 'test123'},
            {'phone': '13800138000', 'pwd': 'test123'},
            {'phone': '13800138000', 'password': hashlib.md5('test123'.encode()).hexdigest()},
        ]
        
        for base_url in self.base_urls:
            if not results['base_urls'][base_url]['accessible']:
                continue
                
            for login_path in self.login_paths:
                url = urljoin(base_url, login_path)
                print(f"  测试: {url}")
                
                for data in test_data_variants:
                    result = self.test_login_endpoint(url, data)
                    
                    if result['status'] not in ['error', 404]:
                        results['login_endpoints'].append({
                            'url': url,
                            'test_data': data,
                            'result': result
                        })
                        
                        if result.get('success'):
                            print(f"    🎉 发现可用端点！")
                        elif result['status'] in [400, 401, 403]:
                            print(f"    ⚠️  端点存在但需要正确凭证 (状态码: {result['status']})")
        
        # 3. 检查常见 API 前缀
        print("\n[3/3] 检查 API 结构...")
        for base_url in self.base_urls:
            if not results['base_urls'][base_url]['accessible']:
                continue
                
            for prefix in self.api_prefixes:
                url = urljoin(base_url, prefix)
                status, content = self.test_url(url)
                if status and status != 404:
                    results['discoveries'].append({
                        'url': url,
                        'status': status
                    })
                    print(f"  ✅ 发现: {url} (状态码: {status})")
        
        return results
    
    def generate_report(self, results):
        """生成报告"""
        print("\n" + "=" * 60)
        print("📊 扫描结果报告")
        print("=" * 60)
        
        # 可访问的基础 URL
        print("\n✅ 可访问的服务器:")
        accessible = [url for url, info in results['base_urls'].items() if info['accessible']]
        if accessible:
            for url in accessible:
                print(f"  • {url}")
        else:
            print("  无")
        
        # 发现的登录端点
        print("\n🔑 可能的登录端点:")
        if results['login_endpoints']:
            for endpoint in results['login_endpoints']:
                print(f"  • {endpoint['url']}")
                print(f"    状态码: {endpoint['result']['status']}")
                if endpoint['result'].get('body'):
                    print(f"    响应: {endpoint['result']['body'][:100]}...")
        else:
            print("  未发现")
        
        # 其他发现
        print("\n🎯 其他发现:")
        if results['discoveries']:
            for disc in results['discoveries']:
                print(f"  • {disc['url']} (状态码: {disc['status']})")
        else:
            print("  无")
        
        # 保存详细结果
        with open('api_scan_results.json', 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print("\n💾 详细结果已保存到: api_scan_results.json")
        print("=" * 60)

def main():
    scanner = MobileHomeAPIScanner()
    results = scanner.scan()
    scanner.generate_report(results)
    
    print("\n📝 下一步建议:")
    if results['login_endpoints']:
        print("  1. 检查 api_scan_results.json 文件")
        print("  2. 找到返回 401/403 的端点（说明端点存在）")
        print("  3. 用真实账号测试这些端点")
    else:
        print("  1. 可能需要更多的端点路径")
        print("  2. 或者服务器有 IP 白名单限制")
        print("  3. 建议使用抓包方法获取真实 API")

if __name__ == '__main__':
    main()
