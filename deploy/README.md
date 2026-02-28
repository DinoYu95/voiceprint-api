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

## 4. 常用命令

```bash
cd deploy
docker compose up -d --build   # 构建并启动
docker compose logs -f app    # 查看日志
docker compose down           # 停止
```
