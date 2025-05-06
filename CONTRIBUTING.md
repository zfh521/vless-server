# 贡献指南

感谢您对VLESS服务器Docker项目的关注！我们欢迎各类贡献，无论是功能改进、错误修复还是文档更新。

## 开发流程

1. Fork本仓库
2. 创建您的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建一个Pull Request

## 发布新版本

要发布新版本，请遵循以下步骤：

1. 更新版本号（使用[语义化版本](https://semver.org/)）
2. 创建一个新的标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions会自动：
   - 构建并发布Docker镜像到GitHub Container Registry
   - 创建GitHub Release
   - 更新README中的版本引用

## 代码风格指南

- 请保持Docker镜像尽可能精简
- 使用有意义的提交消息
- 更新文档以反映任何变更

## 测试

在提交PR之前，请确保本地测试：

```bash
docker-compose build
docker-compose up -d
```

验证服务能够正常启动，并能成功生成UUID和证书。 