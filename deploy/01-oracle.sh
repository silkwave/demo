#!/bin/bash
source ./00-common.sh

step "1. Oracle 19c 컨테이너 실행"

# 기존 컨테이너 제거
podman rm -f oracle19c-ko || true

# 컨테이너 실행
podman run -d \
  --name oracle19c-ko \
  --network bridge \
  -p 1521:1521 \
  -e ORACLE_SID=ORCL \
  -e ORACLE_PWD=oraclepassword \
  -e ORACLE_CHARACTERSET=UTF8 \
  -v ${HOME}/oradata/:/opt/oracle/oradata \
  neo365/oracle19c-ko

success "Oracle 19c 컨테이너 실행 완료"
echo -e "${YELLOW}[INFO] JDBC URL: jdbc:oracle:thin:@//${LOCAL_IP}:1521/ORCL${RESET}"
