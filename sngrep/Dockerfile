# FROM debian:bullseye
FROM debian:bullseye-slim@sha256:b771c35d1e6ecf2556718ad3c0f481b4a04c1fbc133c609643acc9dd6743ead2

# COPY sources.list.163.bullseye /etc/apt/sources.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list


RUN apt-get update && \
    apt-get install -y sngrep


ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

ENTRYPOINT [ "tail","-f","/dev/null" ]
