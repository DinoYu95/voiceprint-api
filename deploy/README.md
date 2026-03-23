# 声纹服务 voiceprint-api 部署

本目录通过 **Docker Compose** 启动声纹 API 服务：镜像内按 **Dockerfile** 安装 `requirements.txt`（Python 3.10、torch、fastapi、uvicorn 等），启动命令为 **`python start_server.py`**（内部用 uvicorn 跑 FastAPI，默认端口 8005）。

---

## 1. 准备配置

服务依赖 **`data/.voiceprint.yaml`**（端口、MySQL、声纹参数等）。在 `deploy/data/` 下放置该文件，或把项目根目录的 `data/` 拷到 `deploy/data/` 后按需修改。

```bash
mkdir -p deploy/data
# 若项目根目录已有 data/.voiceprint.yaml：
cp -r ../data/.voiceprint.yaml deploy/data/ 2>/dev/null || true
# 或自行创建 deploy/data/.voiceprint.yaml
```

---

## 2. 构建并启动

```bash
cd deploy
cp .env.example .env   # 可选，改 APP_PORT 等
docker compose up -d --build
```

- **不设 `VOICEPRINT_IMAGE`**：使用本地 Dockerfile 从源码构建（安装全部 Python 依赖），再启动。
- **设 `VOICEPRINT_IMAGE`**：拉取该镜像，不构建，直接 `docker compose up -d`。

---

## 3. 各服务如何启动、安装包与环境

| 项目     | 镜像/构建     | 安装与环境 | 启动方式 |
|----------|----------------|------------|----------|
| **app**  | 本仓库 Dockerfile | **构建时**：Python 3.10，`pip install -r requirements.txt`（torch、torchaudio、fastapi、uvicorn、modelscope、librosa 等），多阶段构建 | 容器内 `python start_server.py` → uvicorn 跑 `app.application:app`，端口 8005 |

配置中的端口需与 `.env` 里 `APP_PORT` 一致（默认 8005）。

---

## 4. MySQL：本地 vs Docker

- **本地直接跑**：`data/.voiceprint.yaml` 里 MySQL 保持 `host: 127.0.0.1`，连本机 MySQL（或本机 xiaozhi 的 MySQL 映射到 3306）。
- **Docker 部署**：compose 里已设置 `MYSQL_HOST=host.docker.internal`、`MYSQL_PORT=3306`，会覆盖 yaml，从而连**宿主机**上的 3306。因此需要 xiaozhi-esp32-server 的 MySQL 暴露到宿主机（在 xiaozhi 的 deploy 里 `MYSQL_EXPOSE_PORT=3306` 即可）。  
  本地仍用 yaml 的 127.0.0.1，无需改配置。

---

## 5. 常用命令

```bash
cd deploy
docker compose up -d --build   # 构建并启动
docker compose logs -f app    # 查看日志
docker compose down           # 停止
```
