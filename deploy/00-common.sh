#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# 로그 함수
step() { echo -e "${YELLOW}\n▶ $1${RESET}"; }
success() { echo -e "${GREEN}\n✅ $1${RESET}"; }
error_exit() { echo -e "${RED}\n❌ $1${RESET}"; exit 1; }


# 호스트 IP (WSL2 → eth0 기준)
export LOCAL_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
if [ -z "$LOCAL_IP" ]; then
  error_exit "LOCAL_IP 감지 실패 (eth0 인터페이스 확인 필요)"
fi

