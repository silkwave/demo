#!/bin/bash
set -e
source ./00-common.sh

# ===============================
# 7️⃣ 포트 포워딩 및 Pod 로그 확인 (TCP 확인 포함)
# ===============================

HOST="localhost"
PORT=8080
MAX_RETRIES=10
SLEEP_TIME=3

# -------------------------------
# Pod Ready 상태 대기
# -------------------------------
step "🔎 Pod Ready 상태 대기"
POD_NAME=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=ready pod/"$POD_NAME" --timeout=120s
success "✅ Pod Ready 상태 확인 완료"

# -------------------------------
# 포트 포워딩 시작
# -------------------------------
step "7️⃣ 포트 포워딩 시작"
kubectl port-forward svc/myapp ${PORT}:${PORT} &
PF_PID=$!
success "✅ 포트 포워딩 시작 완료: http://localhost:${PORT} (PID: ${PF_PID})"

# -------------------------------
# NodePort 서비스 열림 확인
# -------------------------------
step "🔎 서비스 포트 열림 확인"
for i in $(seq 1 $MAX_RETRIES); do
    if timeout 2 bash -c ">/dev/tcp/${HOST}/${PORT}" 2>/dev/null; then
        success "✅ 서비스 포트 열림 확인 완료: ${HOST}:${PORT}"
        break
    else
        echo -e "${YELLOW}   포트 ${PORT} 확인 중... (${i}/${MAX_RETRIES})${NC}"
        sleep $SLEEP_TIME
    fi

    if [[ "$i" -eq "$MAX_RETRIES" ]]; then
        fail "❌ 서비스 포트 ${PORT} 열림 실패"
        exit 1
    fi
done

# -------------------------------
# Pod 로그 확인 (실시간)
# -------------------------------
step "📝 Pod 로그 확인 (Ctrl+C로 종료)"
kubectl logs -f "$POD_NAME"
