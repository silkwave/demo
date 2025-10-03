#!/bin/bash
set -e

# 색상 정의
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

# 환경 변수
LOCAL_IP=$(hostname -I | awk '{print $1}')
SERVICE_PORT=8080
PORT_FORWARD_LOCAL=8080

# Minikube 설정
MINIKUBE_DRIVER="podman"
APISERVER_IP="127.0.0.1"
APISERVER_NAME="localhost"

# 단계별 상태 기록
declare -A STAGE_STATUS
step() { echo -e "\n${BLUE}▶ $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; STAGE_STATUS["$1"]="SUCCESS"; }
fail() { echo -e "${RED}❌ $1${NC}"; STAGE_STATUS["$1"]="FAIL"; }


