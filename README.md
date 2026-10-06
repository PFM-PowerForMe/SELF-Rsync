# SELF-Rsync

rsync

## 用法

服务端（无参数，默认）：把 `/data` 以只读 module 发布到 873 端口

```bash
podman run -d --name rsync-server -v /opt/certs:/data:z ghcr.io/pfm-powerforme/self-rsync:latest
```

客户端（参数 `client`）：把服务端 module 的完整副本同步到本地 `/data`，之后按间隔重复同步

```bash
podman run -d --name rsync-client -e SERVER=rsync.example.com -v /opt/certs:/data:z ghcr.io/pfm-powerforme/self-rsync:latest client
```

## 环境变量

| 变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `SERVER` | 无 | 服务端地址，客户端必填；拼成 `${SYNC_USER}@${SERVER}::${SYNC_MODULE}` |
| `SYNC_USER` | `container-user` | rsync 认证用户名，服务端与客户端必须一致 |
| `SYNC_PASSWORD` | `container-password` | rsync 认证口令，服务端与客户端必须一致。**默认值是公开的，生产环境请改** |
| `SYNC_MODULE` | `volume` | rsync module 名 |
| `SYNC_PATH` | `/data` | 服务端发布的目录 / 客户端落盘目录 |
| `SYNC_BWLIMIT` | `128` | 限速 KB/s，服务端 daemon 与客户端同步都用它 |
| `SYNC_INTERVAL` | `86400` | 客户端同步间隔（秒） |
| `SYNC_RETRIES` | `8` | 客户端每轮同步的最大尝试次数 |
| `SYNC_RETRY_SLEEP` | `15` | 重试退避起始秒数，每次失败 +15 秒 |
| `SYNC_RETRY_SLEEP_MAX` | `300` | 重试退避封顶秒数 |

## 其他约定

| 项 | 值 |
| :--- | :--- |
| 端口 | `873` |
| 卷 | `/data` |
| 同步参数 | `--checksum --archive --recursive --delete --force --compress --bwlimit`（单向镜像：多出来的文件会被删掉） |
| 服务端 module | `read only = yes`、`uid/gid = nobody`、`use chroot = false`、`max connections = 20`、`timeout = 180` |
| 配置文件 | `/etc/rsyncd.conf`、`/etc/rsyncd.secrets`、`/etc/rsync.secrets` 由入口脚本按环境变量生成；已经存在且内容一致的文件（例如挂载进去的）直接沿用，内容对不上就重写，写不进去会报错退出 |
| 启动行为 | 客户端首次同步会一直重试直到成功（等对端就绪）；定时轮失败只记日志，等下一轮 |
| 停止 | 收到 `SIGTERM` / `SIGINT` 后停止当前同步并退出（exit 0） |
