FROM python:3.9-alpine
LABEL Author="roiding<dingran@ran-ding.ga>" 
# 添加apply.py进入容器
COPY apply.py .
COPY requirements.txt .
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["apply.py","/main.tf"]