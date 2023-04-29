FROM python:3.9-alpine
MAINTAINER roiding<dingran@ran-ding.ga>
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["apply.py"]