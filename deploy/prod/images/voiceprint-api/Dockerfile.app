# 【仅生产 ACR】voiceprint-api App：仅复制代码
ARG BASE_IMAGE=registry.cn-beijing.aliyuncs.com/zhiban/voiceprint-api-base:latest
FROM ${BASE_IMAGE}

COPY . .

CMD ["python", "start_server.py"]
