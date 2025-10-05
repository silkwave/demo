#!/bin/bash
set -e
source ./00-common.sh

step "5. Deployment 및 서비스 생성"

DB_PORT=1521

# 5.1 기존 Deployment/Service 삭제
kubectl delete deployment myapp --ignore-not-found
kubectl delete svc myapp --ignore-not-found

# 5.2 Deployment 생성
kubectl create deployment myapp \
    --image="${LOCAL_IP}:5000/spring-server:latest" \
    --replicas=1

# 5.3 환경 변수 주입
kubectl set env deployment/myapp \
    SPRING_DATASOURCE_URL="jdbc:oracle:thin:@//${LOCAL_IP}:${DB_PORT}/ORCL" \
    SPRING_DATASOURCE_USERNAME="docker" \
    SPRING_DATASOURCE_PASSWORD="ENC(e0RkhL8qEaVissFWEH9ihubfgS9ZLUwm0n6pLKG7r0e1NX5bb/JioOaf/6v2D7OZ)"

# 5.4 NodePort Service 생성
kubectl expose deployment myapp --type=NodePort --port=8080

success "Deployment 및 Service 생성 완료"
