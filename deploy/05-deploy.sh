#!/bin/bash
set -e
source ./00-common.sh

step "5️⃣ Deployment 및 서비스 생성"

# WSL2 호스트 IP 자동 감지
HOST_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
DB_PORT=1521

# 1️⃣ 기존 Deployment/Service 삭제
kubectl delete deployment myapp --ignore-not-found
kubectl delete svc myapp --ignore-not-found

# 2️⃣ Deployment 생성
kubectl create deployment myapp \
    --image="${LOCAL_IP}:5000/spring-server:latest" \
    --replicas=1

# 3️⃣ 환경 변수 주입
kubectl set env deployment/myapp \
    SPRING_DATASOURCE_URL="jdbc:oracle:thin:@//${HOST_IP}:${DB_PORT}/ORCL" \
    SPRING_DATASOURCE_USERNAME="docker" \
    SPRING_DATASOURCE_PASSWORD="ENC(e0RkhL8qEaVissFWEH9ihubfgS9ZLUwm0n6pLKG7r0e1NX5bb/JioOaf/6v2D7OZ)"

# 4️⃣ NodePort Service 생성
kubectl expose deployment myapp --type=NodePort --port=8080

success "✅ Deployment & Service 생성 완료"
