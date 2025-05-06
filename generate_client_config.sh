#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "===== VLESS 客户端配置生成器 ====="

# 获取容器ID
CONTAINER_ID=$(docker ps | grep vless-server | awk '{print $1}')

if [ -z "$CONTAINER_ID" ]; then
  echo -e "${RED}错误：找不到运行中的VLESS服务器容器${NC}"
  exit 1
fi

# 获取UUID
UUID=$(docker logs $CONTAINER_ID 2>&1 | grep "UUID:" | awk '{print $2}')
if [ -z "$UUID" ]; then
  echo -e "${RED}错误：无法从容器日志中获取UUID${NC}"
  exit 1
fi

# 获取SNI
SNI=$(docker exec $CONTAINER_ID cat /etc/xray/sni.txt 2>/dev/null)
if [ -z "$SNI" ]; then
  SNI="vless-server"  # 默认值
fi

# 获取主机IP
HOST_IP=$(curl -s https://api.ipify.org || curl -s http://ifconfig.me)
if [ -z "$HOST_IP" ]; then
  echo -e "${YELLOW}警告：无法自动获取主机IP，请手动输入服务器IP或域名:${NC}"
  read HOST_IP
fi

# 创建输出目录
mkdir -p client_configs

# 生成通用链接
VLESS_LINK="vless://${UUID}@${HOST_IP}:443?flow=xtls-rprx-vision&security=tls&sni=${SNI}&type=tcp&encryption=none#VLESS-Server"
echo -e "${GREEN}生成VLESS链接:${NC}"
echo -e "${YELLOW}${VLESS_LINK}${NC}"
echo "$VLESS_LINK" > client_configs/vless_link.txt

# 生成v2rayN/V2rayNG配置
cat > client_configs/v2rayn_config.json << EOF
{
  "v": "2",
  "ps": "VLESS-Server",
  "add": "${HOST_IP}",
  "port": "443",
  "id": "${UUID}",
  "flow": "xtls-rprx-vision",
  "type": "tcp",
  "host": "",
  "path": "",
  "tls": "tls",
  "sni": "${SNI}"
}
EOF

# 生成Shadowrocket配置 (iOS)
cat > client_configs/shadowrocket_config.txt << EOF
VLESS配置:
地址: ${HOST_IP}
端口: 443
UUID: ${UUID}
流控: xtls-rprx-vision
传输: tcp
TLS: 开启
SNI: ${SNI}
允许不安全: 开启 (自签名证书需要)
EOF

# 生成二维码
echo -e "${YELLOW}提示：您还可以将VLESS链接转换为二维码，帮助在移动设备上快速导入:${NC}"
echo -e "${YELLOW}请访问以下网站并粘贴VLESS链接生成二维码:${NC}"
echo -e "${GREEN}https://www.qr-code-generator.com/${NC}"

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}客户端配置文件已生成到 client_configs 目录${NC}"
echo -e "${GREEN}- vless_link.txt: 通用分享链接${NC}"
echo -e "${GREEN}- v2rayn_config.json: V2rayN/V2rayNG配置${NC}"
echo -e "${GREEN}- shadowrocket_config.txt: Shadowrocket指引${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${YELLOW}配置细节:${NC}"
echo -e "${YELLOW}服务器地址: ${HOST_IP}${NC}"
echo -e "${YELLOW}端口: 443${NC}"
echo -e "${YELLOW}UUID: ${UUID}${NC}"
echo -e "${YELLOW}流控: xtls-rprx-vision${NC}"
echo -e "${YELLOW}安全性: tls${NC}"
echo -e "${YELLOW}网络: tcp${NC}"
echo -e "${YELLOW}SNI: ${SNI}${NC}" 