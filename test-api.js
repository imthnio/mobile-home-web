const axios = require('axios');
const crypto = require('crypto');

// 从抓包数据提取的认证信息
const AUTH = {
  uid: '218847460',
  usertoken: 'Z46071e9e9d743f7a83760a6dd9a65ea',
  accessKey: '148cd55a-2eb',
  imei: '2184170000306773'
};

// 生成签名（暂时用随机值，后续需要找到真实算法）
function generateSign(accessKey, timestamp, data) {
  // 尝试几种常见的签名算法
  const methods = [
    // 方法1: MD5(accessKey + timestamp + data)
    () => crypto.createHash('md5').update(`${accessKey}${timestamp}${JSON.stringify(data)}`).digest('hex'),
    
    // 方法2: SHA256(accessKey + timestamp)
    () => crypto.createHash('sha256').update(`${accessKey}${timestamp}`).digest('hex'),
    
    // 方法3: MD5(timestamp + accessKey)
    () => crypto.createHash('md5').update(`${timestamp}${accessKey}`).digest('hex'),
  ];
  
  return methods[1](); // 先用SHA256试试
}

// 获取设备列表
async function getDeviceList() {
  const timestamp = Date.now();
  const traceId = `test${timestamp}`;
  const sign = generateSign(AUTH.accessKey, timestamp, {});
  
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📱 测试获取设备列表');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    const response = await axios.post(
      'https://soul-media.camera.komect.com/device/attachment/get',
      {
        data: {
          attachments: [
            { key: 'live_needCloud', imei: AUTH.imei },
            { key: 'packageType', imei: AUTH.imei },
            { key: 'cmeiState', imei: AUTH.imei }
          ]
        }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'uid': AUTH.uid,
          'usertoken': AUTH.usertoken,
          'accept-accesskey': AUTH.accessKey,
          'msgtraceid': traceId,
          'request-version': '1',
          'accept-time': timestamp.toString(),
          'accept-sign': sign,
          'flowinfo': 'tId=APPLC_test;nt=4;tt=2;tm=iPhone17,5 iOS 27.0.1;v=10.11.0;tmn=iPhone 27.0.1;la=zh_CN;bp=com.cmcc.zhihuiguanjia',
          'user-agent': 'iOS_SDK/4.3.0.128.5d93b2784b(iPhoneiPhone27.0.1;iOS_SDK)',
          'accept-language': 'zh-Hans-GB;q=1, en-GB;q=0.9'
        }
      }
    );
    
    console.log('✅ 成功！');
    console.log(JSON.stringify(response.data, null, 2));
    return response.data;
    
  } catch (error) {
    console.log('❌ 失败:', error.response?.data || error.message);
    
    // 如果签名错误，尝试其他签名方法
    if (error.response?.data?.code === 33205) {
      console.log('\n💡 签名错误，正在尝试其他算法...\n');
      await tryDifferentSigns();
    }
  }
}

// 尝试不同的签名算法
async function tryDifferentSigns() {
  const timestamp = Date.now();
  const data = { data: {} };
  
  const algorithms = [
    { name: 'MD5(accessKey)', fn: () => crypto.createHash('md5').update(AUTH.accessKey).digest('hex') },
    { name: 'MD5(accessKey + timestamp)', fn: () => crypto.createHash('md5').update(AUTH.accessKey + timestamp).digest('hex') },
    { name: 'SHA256(accessKey + timestamp)', fn: () => crypto.createHash('sha256').update(AUTH.accessKey + timestamp).digest('hex') },
    { name: 'MD5(timestamp + accessKey + JSON)', fn: () => crypto.createHash('md5').update(timestamp + AUTH.accessKey + JSON.stringify(data)).digest('hex') },
    { name: 'SHA256(JSON + timestamp + accessKey)', fn: () => crypto.createHash('sha256').update(JSON.stringify(data) + timestamp + AUTH.accessKey).digest('hex') },
  ];
  
  for (const algo of algorithms) {
    console.log(`🔐 尝试: ${algo.name}`);
    const sign = algo.fn();
    console.log(`   签名: ${sign.substring(0, 32)}...`);
    
    try {
      const response = await axios.post(
        'https://soul-media.camera.komect.com/region/all/list',
        data,
        {
          headers: {
            'Content-Type': 'application/json',
            'uid': AUTH.uid,
            'usertoken': AUTH.usertoken,
            'accept-accesskey': AUTH.accessKey,
            'accept-time': timestamp.toString(),
            'accept-sign': sign,
            'request-version': '1',
            'user-agent': 'iOS_SDK/4.3.0.128.5d93b2784b(iPhoneiPhone27.0.1;iOS_SDK)'
          }
        }
      );
      
      console.log(`   ✅ 成功！找到正确算法: ${algo.name}\n`);
      console.log(JSON.stringify(response.data, null, 2));
      return algo.name;
      
    } catch (error) {
      const code = error.response?.data?.code;
      console.log(`   ❌ 失败 (code: ${code || 'network error'})\n`);
    }
    
    // 等待一下避免请求太快
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  console.log('\n😞 所有签名算法都失败了，需要反编译APK找真实算法');
}

// 主函数
async function main() {
  console.log('🔍 移动爱家API测试工具');
  console.log('基于Charles抓包数据 - 2026-10-20\n');
  
  await getDeviceList();
}

main().catch(console.error);
