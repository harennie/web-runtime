# web-runtime

在 dcdeploy 上运行的容器镜像。镜像由 GitHub Actions 自动构建并推送到 `ghcr.io/harennie/web-runtime:latest`，每周一自动重建一次，以更新到最新的上游版本。

配置全部通过环境变量传入，UUID 不会写进仓库或镜像。

## 1. 创建仓库并上传文件

1. 在 GitHub 新建一个 **Public** 仓库，名字填 `web-runtime`，勾选 "Add a README file"，这样会生成 `main` 分支。
2. 进入仓库，点 **Add file → Upload files**，把以下文件拖进去后提交：
   - `Dockerfile`
   - `entrypoint.sh`
   - `.gitattributes`
   - `README_zh.md`（可选）
3. 上传工作流文件 `.github/workflows/docker.yml`，二选一：
   - 在上传页面直接把整个 `.github` 文件夹拖进去（拖文件夹会保留目录结构；用"选择文件"按钮选不了文件夹）。
   - 或者点 **Add file → Create new file**，在文件名框里输入 `.github/workflows/docker.yml`（输入 `/` 时会自动变成目录），再把 `docker.yml` 的内容粘贴进去并提交。

> Windows 的资源管理器默认隐藏以 `.` 开头的文件；如果看不到 `.gitattributes` 和 `.github`，在"查看"里打开"隐藏的项目"。

## 2. 等待构建并把镜像设为公开

1. 打开仓库的 **Actions** 标签页，"Build and push image" 应该已经因为提交自动运行。如果没有，点进该工作流，再点 **Run workflow**。
2. 运行成功（绿色对勾）后，打开 GitHub 个人主页 → **Packages** → `web-runtime` → **Package settings**，在最下面的 Danger Zone 里点 **Change visibility**，改为 **Public**。
   不改成公开的话，dcdeploy 拉不到镜像（除非另外配 Pull Secret）。

## 3. 在 dcdeploy 创建服务

| 字段 | 填写 |
| - | - |
| Source | Docker |
| Image | `ghcr.io/harennie/web-runtime:latest` |
| Pull Secret | 不填 |
| Port | `8080` |
| Protocol | `https` |
| Regions | Germany |
| Machine Type | DCD-1 |
| Environment Variables | 见下 |

环境变量：

```
UUID=<你的 UUID>
APP_PATH=/<随机路径>
PORT=8080
```

- `UUID` 可以用 v2rayN 生成，或者在 PowerShell 里运行 `[guid]::NewGuid()`。
- `APP_PATH` 必须以 `/` 开头，只能用字母、数字和 `. _ ~ / -`。

部署完成后，在服务详情里找到分配的域名，例如 `xxxx.dcdeploy.cloud`。日志里出现 `web-runtime: listening on 0.0.0.0:8080` 和 `... started` 就说明运行正常。

## 4. 客户端链接

```
vless://<UUID>@<服务名>.dcdeploy.cloud:443?encryption=none&security=tls&sni=<服务名>.dcdeploy.cloud&host=<服务名>.dcdeploy.cloud&type=ws&path=%2F<随机路径>&fp=chrome#DCD-DE
```

- 路径里的 `/` 在链接中写成 `%2F`。
- 入口在 Cloudflare 后面，地址可以换成优选 IP，`sni` 和 `host` 保持为 dcdeploy 分配的域名不变。

## 说明

- 直接用浏览器打开域名会显示 404，这是正常的：只有带 WebSocket 升级的请求访问 `APP_PATH` 才会被处理。
- 更新版本：等每周的自动构建，或者在 Actions 里手动 **Run workflow**，然后在 dcdeploy 里重新部署（Redeploy）服务，就会拉取新镜像。
- 仓库 60 天没有任何提交时，GitHub 会自动停用定时任务，需要到 Actions 页面重新启用。
