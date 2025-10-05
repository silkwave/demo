#!/bin/bash
set -e
set +x
cd "$(dirname "$0")"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}🚀 전체 배포 시작...${RESET}"

# 실패 시 정리 함수
cleanup_on_error() {
  echo -e "${RED}\n❌ 배포 중 오류 발생. 로그 확인 후 재시도하세요.${RESET}"
  exit 1
}
trap cleanup_on_error ERR

# -----------------------------------
# 1️⃣ 전체 컨테이너 / 이미지 초기화
# -----------------------------------
echo -e "${YELLOW}\n🧹 기존 Podman 컨테이너/이미지 정리 중...${RESET}"
podman ps -a -q | xargs -r podman stop
podman ps -a -q | xargs -r podman rm
podman images --format "{{.ID}} {{.Repository}}" | grep -v "oracle19c" | awk '{print $1}' | xargs -r podman rmi -f


# -----------------------------------
# 2️⃣ 단계별 실행
# -----------------------------------
echo -e "${YELLOW}\n💾 Oracle DB 컨테이너 기동${RESET}"
./01-oracle.sh

echo -e "${YELLOW}\n📦 Minikube 초기화${RESET}"
./02-minikube-init.sh

echo -e "${YELLOW}\n📡 로컬 레지스트리 기동${RESET}"
./03-registry.sh

echo -e "${YELLOW}\n🛠️  이미지 빌드 및 Push${RESET}"
./04-build-push.sh

echo -e "${YELLOW}\n🚢 애플리케이션 배포${RESET}"
./05-deploy.sh

echo -e "${YELLOW}\n🔍 Pod 상태 확인${RESET}"
./06-check-and-forward.sh

# -----------------------------------
# ✅ 완료 메시지
# -----------------------------------
echo -e "${GREEN}\n✅ 전체 배포 완료!${RESET}"
echo -e "${GREEN}➡️  접속 주소: http://localhost:8080${RESET}"
