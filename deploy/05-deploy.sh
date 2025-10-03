#!/bin/bash
set -e
source ./00-common.sh

# WSL2 호스트 IP 및 Oracle 포트
# ip addr show eth0   
HOST_IP="192.168.139.179"
DB_PORT=1521

step "5️⃣ Deployment 및 서비스 생성"

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

# 5️⃣ Pod Ready 상태 대기
step "🔎 Pod Ready 상태 대기"
POD_NAME=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=ready pod/"$POD_NAME" --timeout=120s

# 6️⃣ Pod 상태 확인
step "🔎 Pod 상태 확인"
kubectl get pods -l app=myapp -o wide

# 7️⃣ Service 상태 확인
step "🔎 Service 상태 확인"
kubectl get svc myapp

# 8️⃣ TCP 연결 테스트 (패키지 없이)
step "💻 DB TCP 연결 테스트"
TCP_CHECK=$(kubectl exec "$POD_NAME" -- sh -c "
if timeout 5 bash -c '>/dev/tcp/${HOST_IP}/${DB_PORT}'; then
    echo '✅ Oracle DB 포트 열림'
else
    echo '❌ Oracle DB 접속 실패'
fi
")
echo "$TCP_CHECK"

# 9️⃣ Pod 로그 확인 (실시간)
step "📝 Pod 로그 확인 (Ctrl+C로 종료)"
kubectl logs -f "$POD_NAME"
