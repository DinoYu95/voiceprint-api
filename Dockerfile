# 第一阶段：构建Python依赖
FROM python:3.10-slim AS builder

# 安装系统依赖，包括编译工具
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 先单独安装 pyarrow==15.0.2（pyarrow>=21 移除了 PyExtensionType，modelscope/datasets 会报错）
# 必须最先安装，避免后续依赖安装时被升级
RUN pip install --no-cache-dir pyarrow==15.0.2

# 安装其余依赖（requirements 中已移除 pyarrow，避免版本冲突）
RUN pip install --no-cache-dir -r requirements.txt

# 最后再次强制安装 pyarrow，确保未被其他包覆盖
RUN pip install --no-cache-dir --force-reinstall pyarrow==15.0.2

# 第二阶段：运行阶段
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 从构建阶段复制Python依赖
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# 创建必要的目录
RUN mkdir -p tmp data

# 复制应用代码
COPY . .

# 启动命令
CMD ["python", "start_server.py"]