#!/usr/bin/env node

/**
 * VLESS服务器高级连接测试工具
 * 
 * 这个脚本测试与VLESS服务器的TLS握手，验证证书信息
 * 使用方法: node test-connectivity.js [hostname] [port]
 */

const tls = require('tls');
const { execSync } = require('child_process');
const fs = require('fs');

// 颜色定义
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  bold: '\x1b[1m'
};

// 获取参数
const hostname = process.argv[2] || 'localhost';
const port = parseInt(process.argv[3] || 443);
let uuid = process.argv[4] || '123';
console.log(`${colors.bold}===== VLESS 服务器高级连接测试 =====${colors.reset}`);
console.log(`${colors.blue}目标: ${hostname}:${port}${colors.reset}`);

// 尝试获取容器中的UUID (如果在Docker环境中运行)



// 测试TLS连接
console.log(`\n${colors.bold}正在测试TLS连接...${colors.reset}`);

// 创建输出目录
if (!fs.existsSync('test_results')) {
  fs.mkdirSync('test_results');
}

const options = {
  host: hostname,
  port: port,
  rejectUnauthorized: false, // 允许自签名证书
  servername: hostname,
};

const startTime = Date.now();
const tlsSocket = tls.connect(options, () => {
  const responseTime = Date.now() - startTime;
  
  console.log(`${colors.green}✓ TLS连接成功 (${responseTime}ms)${colors.reset}`);
  
  // 检查证书信息
  const cert = tlsSocket.getPeerCertificate();
  console.log(`\n${colors.bold}服务器证书信息:${colors.reset}`);
  console.log(`${colors.blue}主题: ${cert.subject.CN}${colors.reset}`);
  console.log(`${colors.blue}发行者: ${cert.issuer.CN || 'Self-signed'}${colors.reset}`);
  console.log(`${colors.blue}有效期从: ${new Date(cert.valid_from).toLocaleString()}${colors.reset}`);
  console.log(`${colors.blue}有效期至: ${new Date(cert.valid_to).toLocaleString()}${colors.reset}`);
  console.log(`${colors.blue}序列号: ${cert.serialNumber}${colors.reset}`);
  
  // 检查证书是否自签名
  const isSelfSigned = cert.issuer.CN === cert.subject.CN;
  if (isSelfSigned) {
    console.log(`${colors.yellow}⚠ 检测到自签名证书${colors.reset}`);
  }
  
  // 保存证书信息到文件
  fs.writeFileSync('test_results/certificate_info.json', JSON.stringify(cert, null, 2));
  
  // 测试证书验证
  console.log(`\n${colors.bold}测试证书验证:${colors.reset}`);
  if (tlsSocket.authorized) {
    console.log(`${colors.green}✓ 证书验证通过${colors.reset}`);
  } else {
    console.log(`${colors.yellow}⚠ 证书验证失败: ${tlsSocket.authorizationError}${colors.reset}`);
    console.log(`${colors.yellow}   这在使用自签名证书时是正常的${colors.reset}`);
  }
  
  // 关闭连接
  tlsSocket.end();
  
  // 打印连接指南
  console.log(`\n${colors.bold}${colors.green}========================================${colors.reset}`);
  console.log(`${colors.green}${colors.bold}✓ TLS连接测试完成${colors.reset}`);
  console.log(`${colors.green}${colors.bold}========================================${colors.reset}`);
  
  console.log(`\n${colors.bold}接下来的步骤:${colors.reset}`);
  console.log(`${colors.blue}1. 使用 ./generate_client_config.sh 生成客户端配置${colors.reset}`);
  console.log(`${colors.blue}2. 在您的设备上安装VLESS客户端${colors.reset}`);
  console.log(`${colors.blue}3. 导入配置并测试连接${colors.reset}`);
  
  if (uuid) {
    console.log(`\n${colors.bold}快速连接信息:${colors.reset}`);
    console.log(`${colors.blue}服务器: ${hostname}${colors.reset}`);
    console.log(`${colors.blue}端口: ${port}${colors.reset}`);
    console.log(`${colors.blue}UUID: ${uuid}${colors.reset}`);
    console.log(`${colors.blue}流控: xtls-rprx-vision${colors.reset}`);
    console.log(`${colors.blue}传输: tcp${colors.reset}`);
    console.log(`${colors.blue}安全: tls${colors.reset}`);
  }
});

// 错误处理
tlsSocket.on('error', (error) => {
  console.log(`${colors.red}✗ TLS连接失败: ${error.message}${colors.reset}`);
  
  // 根据错误类型提供建议
  if (error.code === 'ECONNREFUSED') {
    console.log(`${colors.yellow}建议: 请检查服务器是否正在运行，以及443端口是否已打开${colors.reset}`);
  } else if (error.code === 'ENOTFOUND') {
    console.log(`${colors.yellow}建议: 域名解析失败，请检查域名是否正确${colors.reset}`);
  }
  
  process.exit(1);
}); 