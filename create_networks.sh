#!/bin/bash

# 删除现有的网络（如果存在）
docker network rm kamailio-external kamailio-internal 2>/dev/null

# 创建外部网络
docker network create --driver bridge \
  --subnet=192.168.254.0/24 \
  --gateway=192.168.254.1 \
  kamailio-external

# 创建内部网络
docker network create --driver bridge \
  --subnet=172.16.254.0/24 \
  --gateway=172.16.254.1 \
  kamailio-internal

echo "网络创建完成"