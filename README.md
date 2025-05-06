# Docker VLESS Server

这是一个基于 Docker 的 VLESS 服务器设置，使用 Xray 核心。VLESS 是一个轻量级的 VPN 协议，提供安全且高效的网络连接。

## 特点

- 基于 Xray 核心
- 使用 VLESS 协议
- TLS 加密
- 容器启动时自动生成 UUID
- 自动生成自签名 SSL 证书
- 自动化 GitHub Actions 构建和发布

## 前提条件

- Docker
- Docker Compose

## 快速开始

### 方法 1: 使用预构建的 Docker 镜像

```bash
# 创建证书目录
mkdir -p certs

# 创建docker-compose.yml文件
cat > docker-compose.yml << 'EOF'
version: '3'

services:
  vless-server:
    image: ghcr.io/yourusername/vless-server-docker:latest
    container_name: vless-server
    restart: always
    ports:
      - "443:443"
    volumes:
      - ./certs:/etc/xray
    environment:
      - TZ=UTC
EOF

# 启动服务
docker-compose up -d
```

### 方法 2: 从源代码构建

1. 克隆此仓库:

```bash
git clone https://github.com/yourusername/vless-server-docker.git
cd vless-server-docker
```

2. 创建证书目录:

```bash
mkdir -p certs
```

3. (可选) 生成固定的 UUID:

```bash
./generate_uuid.sh
```

4. 构建并启动服务:

```bash
docker-compose up -d
```

5. 查看日志和连接详情:

```bash
docker logs vless-server
```

6. 服务将在端口 443 上运行，并在启动时显示连接信息。

## 客户端配置

您需要以下信息来配置您的 VLESS 客户端:

- 服务器地址: 您的服务器 IP 或域名
- 端口: 443
- 协议: VLESS
- UUID: 在服务器启动日志中查看，或者查看 `certs/uuid.txt` 文件
- 流控: xtls-rprx-direct
- 安全性: TLS
- 网络: TCP

## 支持的客户端应用

- **Windows**: V2rayN, Qv2ray
- **macOS**: V2rayX, ClashX
- **Linux**: Qv2ray, v2rayA
- **Android**: v2rayNG
- **iOS**: Shadowrocket

## 使用您自己的证书

如果您希望使用您自己的证书而不是自签名证书，请将您的证书和密钥文件放在 `certs` 目录中:

1. 将您的证书放在 `certs/server.crt`
2. 将您的密钥放在 `certs/server.key`

然后重新启动容器:

```bash
docker-compose restart
```

## 固定 UUID

默认情况下，容器每次启动时都会检查是否有固定的 UUID 设置:

1. 如果存在 `certs/uuid.txt` 文件，则使用该文件中的 UUID
2. 如果不存在，则生成一个新的 UUID 并保存到 `certs/uuid.txt`

要设置一个固定的 UUID:

```bash
# 方法 1: 使用提供的脚本
./generate_uuid.sh

# 方法 2: 手动创建
echo "your-custom-uuid-here" > certs/uuid.txt
```

## 自动化构建

该项目使用 GitHub Actions 进行自动化构建和发布:

1. 每次推送到主分支时，会自动构建并发布 Docker 镜像到 GitHub Container Registry
2. 当创建带有 `v*.*.*` 格式的标签时，会创建一个新的 Release 并构建对应标签版本的 Docker 镜像

## 注意事项

- 这个设置使用了自签名的 SSL 证书。对于生产环境，建议使用来自受信任的 CA 的证书。
- 首次连接可能会收到证书警告，因为使用了自签名证书。 