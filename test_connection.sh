#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "===== VLESS 服务器连接测试 ====="

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

echo -e "${GREEN}找到VLESS服务器容器ID: ${CONTAINER_ID}${NC}"
echo -e "${GREEN}获取到UUID: ${UUID}${NC}"
echo -e "${GREEN}服务器SNI: ${SNI}${NC}"

# 检查端口是否开放
echo -e "${YELLOW}检查443端口是否开放...${NC}"
if docker exec $CONTAINER_ID netstat -tuln | grep -q ":443"; then
  echo -e "${GREEN}端口443已开放√${NC}"
else
  echo -e "${RED}错误：端口443未开放×${NC}"
  exit 1
fi

# 检查Xray进程是否运行
echo -e "${YELLOW}检查Xray进程是否运行...${NC}"
if docker exec $CONTAINER_ID ps aux | grep -v grep | grep -q xray; then
  echo -e "${GREEN}Xray进程正在运行√${NC}"
else
  echo -e "${RED}错误：Xray进程未运行×${NC}"
  exit 1
fi

# 尝试连接到服务器（仅测试TCP连接）
echo -e "${YELLOW}测试与443端口的TCP连接...${NC}"
timeout 5 docker exec $CONTAINER_ID bash -c "echo > /dev/tcp/127.0.0.1/443" 2>/dev/null
if [ $? -eq 0 ]; then
  echo -e "${GREEN}TCP连接成功√${NC}"
else
  echo -e "${RED}错误：TCP连接失败×${NC}"
  exit 1
fi

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}VLESS服务器基本连接测试通过！${NC}"
echo -e "${GREEN}服务器配置信息:${NC}"
echo -e "${GREEN}协议: VLESS${NC}"
echo -e "${GREEN}端口: 443${NC}"
echo -e "${GREEN}UUID: ${UUID}${NC}"
echo -e "${GREEN}流控: xtls-rprx-vision${NC}"
echo -e "${GREEN}安全性: tls${NC}"
echo -e "${GREEN}网络: tcp${NC}"
echo -e "${GREEN}SNI: ${SNI}${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${YELLOW}注意：要完全确认服务可用，请在客户端应用中配置并测试实际连接。${NC}" 