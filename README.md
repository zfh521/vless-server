# Docker VLESS Server

这是一个基于 Docker 的 VLESS 服务器设置，使用 Xray 核心。VLESS 是一个轻量级的 VPN 协议，提供安全且高效的网络连接。

## 特点

- 基于 Xray 核心
- 使用 VLESS 协议
- TLS 加密
- 容器启动时自动生成 UUID
- 自动生成自签名 SSL 证书
- 自动化 GitHub Actions 构建和发布
- 自动配置 SNI (Server Name Indication)

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

4. (可选) 设置自定义 SNI:

```bash
echo "your-domain.com" > certs/sni.txt
```

5. 构建并启动服务:

```bash
docker-compose up -d
```

6. 查看日志和连接详情:

```bash
docker logs vless-server
```

7. 服务将在端口 443 上运行，并在启动时显示连接信息。

## 测试服务可用性

我们提供了多种工具来测试VLESS服务器的可用性：

### 1. 基本连接测试

运行以下命令执行基本的连接测试，验证服务是否正常运行：

```bash
./test_connection.sh
```

这将检查：
- 服务器容器是否运行
- 443端口是否开放
- Xray进程是否正常
- 基本的TCP连接是否成功

### 2. 生成客户端配置

使用以下命令生成可用于各种客户端的配置文件：

```bash
./generate_client_config.sh
```

这将：
- 自动检测服务器IP和UUID
- 生成适用于多种客户端的配置文件
- 创建易于分享的VLESS链接

### 3. 高级TLS连接测试 (需要Node.js)

如果您安装了Node.js，可以运行高级TLS连接测试，验证TLS握手和证书：

```bash
node test-connectivity.js [hostname] [port] [sni]
```

或者直接运行：

```bash
./test-connectivity.js
```

这将提供详细的TLS连接信息和证书验证结果。

## 客户端配置

您需要以下信息来配置您的 VLESS 客户端:

- 服务器地址: 您的服务器 IP 或域名
- 端口: 443
- 协议: VLESS
- UUID: 在服务器启动日志中查看，或者查看 `certs/uuid.txt` 文件
- 流控: xtls-rprx-vision
- 安全性: TLS
- 网络: TCP
- SNI: 默认为服务器主机名，可通过 `certs/sni.txt` 自定义

## SNI 设置说明

SNI (Server Name Indication) 是 TLS 协议的扩展，允许客户端在 TLS 握手阶段指定它要连接的服务器域名。正确配置 SNI 对于 VLESS 协议非常重要。

### 为什么需要 SNI

1. **绕过封锁**: 某些网络环境可能会根据 SNI 进行流量检测和阻断
2. **证书验证**: 确保客户端和服务器使用相同的域名进行 TLS 握手
3. **多域名共存**: 在同一 IP 上托管多个 HTTPS 服务

### 如何配置 SNI

1. **服务器端**:
   - 默认使用服务器主机名
   - 通过 `certs/sni.txt` 文件自定义
   - 生成的证书会使用此 SNI 值作为 Common Name

2. **客户端**:
   - 使用 `generate_client_config.sh` 脚本生成的配置会自动包含正确的 SNI
   - 手动配置时需要将 SNI 设置为与服务器相同的值

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
3. 确保您的 SNI 设置 (`certs/sni.txt`) 与证书的域名一致

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
- 确保客户端的 SNI 设置与服务器匹配，否则可能导致连接失败。 