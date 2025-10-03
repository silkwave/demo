#!/bin/bash
set -e

# ===============================
# WSL2 + Podman + Minikube 자동 배포
# 🔹 실시간 Pod 진행률 체크
# 🔹 단계별 로그 + 배포 전체 요약
# 🔹 배포 후 자동 포트 포워딩 (localhost:8080)
# ===============================

# 색상 정의
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

# 환경 변수
LOCAL_IP=$(hostname -I | awk '{print $1}')
REGISTRY="${LOCAL_IP}:5000"
IMAGE_NAME="spring-server"
TAG_LATEST="latest"
FULL_IMAGE_LATEST="${REGISTRY}/${IMAGE_NAME}:${TAG_LATEST}"
DEPLOYMENT_NAME="myapp"
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

echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE}🔹 배포 시작${NC}"
echo -e "${YELLOW}로컬 IP : $LOCAL_IP${NC}"
echo -e "${YELLOW}레지스트리 : $REGISTRY${NC}"
echo -e "${YELLOW}이미지(Latest) : $FULL_IMAGE_LATEST${NC}"

# 1️⃣ Minikube 삭제 및 시작
step "1️⃣ Minikube 초기화 및 시작"
minikube delete || true
minikube start \
  --driver="$MINIKUBE_DRIVER" \
  --insecure-registry="${LOCAL_IP}:5000" \
  --apiserver-ips="$APISERVER_IP" \
  --apiserver-name="$APISERVER_NAME" \
  --rootless=true \
  --memory=4096 --cpus=2
success "Minikube 시작 완료"

# 2️⃣ Podman 레지스트리 실행
step "2️⃣ 로컬 Podman 레지스트리"
podman rm -f registry || true
podman run -d --network=host --name registry registry:2
success "Podman 레지스트리 실행 완료"

# 3️⃣ 이미지 빌드 및 Push
step "3️⃣ 이미지 빌드 및 Push"
podman build --layers=false -t ${FULL_IMAGE_LATEST} .
podman push --tls-verify=false ${FULL_IMAGE_LATEST}
minikube image load ${FULL_IMAGE_LATEST}
success "이미지 빌드 및 Push 완료"

# 4️⃣ Deployment 및 서비스 생성
step "4️⃣ Deployment & NodePort 서비스"
kubectl delete deployment ${DEPLOYMENT_NAME} --ignore-not-found
kubectl delete svc ${DEPLOYMENT_NAME} --ignore-not-found
kubectl create deployment ${DEPLOYMENT_NAME} --image=${FULL_IMAGE_LATEST} --replicas=1
kubectl expose deployment ${DEPLOYMENT_NAME} --type=NodePort --port=${SERVICE_PORT}
success "Deployment & 서비스 생성 완료"

# 5️⃣ Pod 상태 실시간 체크 (Pending 시 원인 출력)
step "5️⃣ Pod 상태 확인"
MAX_RETRIES=10; SLEEP_TIME=5
for i in $(seq 1 $MAX_RETRIES); do
    PHASE=$(kubectl get pods -l app=${DEPLOYMENT_NAME} -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Pending")
    [[ "$PHASE" == "Running" ]] && break
    echo -e "${YELLOW}   Pod 준비 중... (${i}/${MAX_RETRIES})${NC}"
    # Pending 상태면 이유 출력
    if [[ "$PHASE" == "Pending" ]]; then
        kubectl get events --sort-by=.metadata.creationTimestamp | tail -n 5
    fi
    sleep $SLEEP_TIME
done

if [[ "$PHASE" == "Running" ]]; then
    success "Pod Running 완료"
else
    fail "Pod Running 실패"
    echo -e "${RED}⚠ Pod Pending 이유 확인 필요: ${NC}"
    kubectl describe pod -l app=${DEPLOYMENT_NAME}
fi

# 6️⃣ 포트 포워딩
step "6️⃣ 포트 포워딩"
kubectl port-forward svc/${DEPLOYMENT_NAME} ${PORT_FORWARD_LOCAL}:${SERVICE_PORT} &
PF_PID=$!
success "포트 포워딩 완료: http://localhost:${PORT_FORWARD_LOCAL} (PID: ${PF_PID})"

# ===============================
# 배포 전체 요약
# ===============================
echo -e "\n${BLUE}==============================${NC}"
echo -e "${BLUE}🔹 배포 전체 요약${NC}"
for s in "${!STAGE_STATUS[@]}"; do
    status=${STAGE_STATUS[$s]}
    case "$status" in
        SUCCESS) echo -e "${GREEN}✔ $s${NC}" ;;
        FAIL) echo -e "${RED}✖ $s${NC}" ;;
    esac
done
echo -e "${GREEN}✅ 배포 완료${NC}"
echo -e "${BLUE}==============================${NC}"
