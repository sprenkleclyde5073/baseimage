#!/bin/bash
set -e
echo docker building...
echo ${GHTOKEN} | docker login ghcr.io -u ${GHOWNER} --password-stdin
# 构建
# docker build --target=clidev -t ghcr.io/${GHOWNER}/cli .

docker-compose build
docker-compose push