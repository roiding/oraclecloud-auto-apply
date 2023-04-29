FROM python:3.9-alpine
LABEL Author="roiding<dingran@ran-ding.ga>" 
# 添加apply.py进入容器
COPY apply.py .
COPY requirements.txt .
# 安装构建依赖项和Rust工具链
RUN apk add --no-cache build-base libffi-dev openssl-dev rust cargo
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["apply.py"]