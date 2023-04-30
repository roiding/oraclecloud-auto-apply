FROM python:3.9-alpine
LABEL Author="roiding<dingran@ran-ding.ga>" 
# 添加apply.py进入容器
COPY apply.py .
COPY requirements.txt .
# 判断当前构建的平台是否为 ARM 架构
ARG TARGETPLATFORM
# https://github.com/pyca/cryptography/issues/6347#issuecomment-932082093的解决方案
# 官方认为是qemu在arm架构下的文件限制导致无法正确安装cryptography
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip3 install --no-cache-dir cryptography
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["apply.py","/main.tf"]