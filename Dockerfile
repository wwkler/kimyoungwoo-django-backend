# Docker Image 정의서

## alpine 3.19 버전의 리눅스를 구축하는데, 파이썬 버전은 3.11로 설치하라.
## alpine - 경량화된 리눅스 버전 => 가볍다 => 이미지 자체를 가볍게 만듦 => 이미지 자체가 무거우면 빌드 속도가 느려진다. 
FROM python:3.11-alpine3.19

LABEL maintainer='kimyoungwoo'


# Image에 환경 변수를 등록한다. 
## Python이 표준 입출력 버퍼링을 비활성화하게 하여, 로그가 즉시 콘솔에 출력되게 합니다.
## 이는 Docker Container에서 로그를 더 쉽게 볼 수 있게 한다. 
ENV PYTHONUNBUFFERED 1


# Container 경로에 파일을 전달한다. 
## tmp에 넣는 이유 : tmp는 파일이나 폴더를 일시적으로 저장하는 곳이기 떄문에 경량 상태로 유지할 수 있다.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app 

# Container의 작업 경로를 /app으로 설정한다. .이 곧 /app를 의미한다. 
WORKDIR /app

# Container에서 사용되는 포트 번호를 명시한다. 
EXPOSE 8000

# DEV 변수를 false로 설정한다. 
ARG DEV=false

# Image가 만들어지는 과정에서 수행한다. 
Run python -m venv /py && \  
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    if [ "$DEV" = "true"]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user


# 환경 변수를 등록한다. 
ENV PATH="/py/bin:$PATH"


# USER 명을 정의한다. 
USER django-user


