# OCI A1 Instance Auto Grab

利用 GitHub Actions 定时自动抢占 Oracle Cloud 免费 A1 (ARM) 实例，并渐进式扩容到满配。

## 背景

本项目按当前账户可用额度申请 2 OCPU / 12GB 内存的 ARM (Ampere A1) 实例。热门区域（如东京 ap-tokyo-1）资源紧张，手动创建经常遇到 "Out of host capacity" 错误。本项目通过定时任务自动重试，在资源释放时抢占实例。

## 策略

采用渐进式创建 + 扩容：

1. **无实例** → 尝试创建 1C/6G（小规格更容易抢到）
2. **已有 1C/6G** → 扩容到 2C/12G
3. **已达 2C/12G** → 无需操作

每次运行只执行一步，创建成功后等下次运行再扩容。

## 定时调度

全天每 15 分钟运行一次，每天最多自动尝试 96 次。每次运行只发起一次创建或扩容请求，任务之间还通过 `concurrency` 禁止重叠，避免同时向 OCI 提交多个请求。也支持手动触发（`workflow_dispatch`）。

如果 OCI 返回 `429 TooManyRequests`，说明触发了 API 限流，可将 cron 调整为 `*/30 * * * *`，降低到每 30 分钟一次。`Out of host capacity` 只表示当前没有可用主机容量，等待下一次任务重试即可。

Workflow 会缓存独立的 OCI CLI Python 环境。首次运行需要安装 OCI CLI，之后的任务会直接恢复缓存，以缩短启动时间。OCI 配置和 API 私钥不会进入缓存，仍会在每个临时 Runner 中按 Secrets 重新生成。

## 配置

在仓库 Settings → Secrets and variables → Actions 中添加以下 Secrets：

| Secret | 说明 | 获取方式 |
|--------|------|----------|
| `OCI_CLI_USER` | User OCID | Identity → Users → 你的用户 → OCID |
| `OCI_CLI_TENANCY` | Tenancy OCID | Governance → Tenancy Details → OCID |
| `OCI_CLI_FINGERPRINT` | API Key 指纹 | Identity → Users → API Keys → Fingerprint |
| `OCI_CLI_KEY_CONTENT` | API 私钥内容 (PEM 格式) | 添加 API Key 时下载的私钥文件内容 |
| `OCI_CLI_REGION` | 区域 | 如 `ap-tokyo-1` |
| `OCI_COMPARTMENT_ID` | Compartment OCID | Identity → Compartments → OCID（无自定义则同 Tenancy OCID） |
| `OCI_SUBNET_ID` | 子网 OCID | Networking → VCN → Subnets → OCID |
| `OCI_AVAILABILITY_DOMAIN` | 可用域 | `oci iam availability-domain list` 查询 |
| `OCI_IMAGE_ID` | ARM 镜像 OCID | Compute → Images，选择 Ampere (aarch64) 架构的镜像 |
| `OCI_SSH_PUBLIC_KEY` | SSH 公钥 | `~/.ssh/id_rsa.pub` 或 `~/.ssh/id_ed25519.pub` 的内容 |

## 使用

1. Fork 本仓库
2. 配置上述 Secrets
3. 手动触发 workflow 测试：Actions → OCI A1 Instance Auto Grab → Run workflow
4. 确认日志正常后，定时任务会自动运行

## 注意事项

- 每次失败（Out of capacity）都是正常的，workflow 不会报错退出
- 定时任务全天每 15 分钟尝试一次，但 GitHub Actions 可能有数分钟调度延迟
- 如果日志出现 `429 TooManyRequests`，应降低运行频率
- 扩容需要先停止实例再修改配置，会有短暂停机
- 当前任务目标额度为 2 OCPU / 12GB
- 本项目假设只创建 1 个实例并用满全部额度
