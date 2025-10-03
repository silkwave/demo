#!/bin/bash
set -e
source ./00-common.sh

HOST_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
DB_PORT=1521

step "6️⃣ Pod 상태 확인 및 DB TCP 연결 테스트"

# Pod Ready 상태 대기
POD_NAME=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
MAX_RETRIES=10; SLEEP_TIME=5
for i in $(seq 1 $MAX_RETRIES); do
    PHASE=$(kubectl get pod "$POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Pending")
    [[ "$PHASE" == "Running" ]] && break
    echo -e "${YELLOW}   Pod 준비 중... (${i}/${MAX_RETRIES})${NC}"
    if [[ "$PHASE" == "Pending" ]]; then
        kubectl get events --sort-by=.metadata.creationTimestamp | tail -n 5
    fi
    sleep $SLEEP_TIME
done

[[ "$PHASE" == "Running" ]] && success "✅ Pod Running 완료" || { fail "❌ Pod Running 실패"; kubectl describe pod "$POD_NAME"; exit 1; }

# Pod 상태 확인
kubectl get pods -l app=myapp -o wide
kubectl get svc myapp

# TCP 연결 테스트
TCP_CHECK=$(kubectl exec "$POD_NAME" -- sh -c "
if timeout 5 bash -c '>/dev/tcp/${HOST_IP}/${DB_PORT}'; then
    echo '✅ Oracle DB 포트 열림'
else
    echo '❌ Oracle DB 접속 실패'
fi
")
echo "$TCP_CHECK"
