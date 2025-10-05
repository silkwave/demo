#!/bin/bash
set -e
source ./00-common.sh

DB_PORT=1521
APP_PORT=8080
HOST="localhost"
MAX_RETRIES=10
SLEEP_TIME=5

step "Pod Ready 상태 확인"

# Pod 존재 확인
POD_COUNT=$(kubectl get pods -l app=myapp --no-headers 2>/dev/null | wc -l)
if [[ "$POD_COUNT" -eq 0 ]]; then
    fail "Pod를 찾을 수 없습니다. (app=myapp)"
    exit 1
fi

# 최신 Pod 이름 조회
POD_NAME=$(kubectl get pods -l app=myapp --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
if [[ -z "$POD_NAME" ]]; then
    fail "최신 Pod를 가져오지 못했습니다."
    exit 1
fi

# Pod Ready 상태 대기
kubectl wait --for=condition=ready pod/"$POD_NAME" --timeout=120s || {
    fail "Pod Ready 대기 실패"
    kubectl describe pod "$POD_NAME"
    exit 1
}
success "Pod Ready 상태 확인 완료"

# Pod 및 서비스 상태 출력
kubectl get pods -l app=myapp -o wide
kubectl get svc myapp

# ===============================
# 7. Oracle DB TCP 연결 테스트
# ===============================
step "DB TCP 연결 테스트"

TCP_CHECK=$(kubectl exec "$POD_NAME" -- sh -c "
if timeout 5 bash -c '>/dev/tcp/${LOCAL_IP}/${DB_PORT}' 2>/dev/null; then
    echo 'Oracle DB 포트(${DB_PORT}) 열림'
else
    echo 'Oracle DB 포트(${DB_PORT}) 접속 실패'
fi
")
echo "$TCP_CHECK"

# ===============================
# 8. 포트 포워딩
# ===============================
step "포트 포워딩 시작"

# 기존 포트포워딩 종료
ps aux | grep '[k]ubectl port-forward' | awk '{print $2}' | xargs -r kill -9
sleep 1

# 포트포워딩 실행 (nohup 백그라운드)
nohup kubectl port-forward svc/myapp ${APP_PORT}:${APP_PORT} > /dev/null 2>&1 &
sleep 1

# ===============================
# 8. 서비스 포트 열림 확인
# ===============================
step "서비스 포트 열림 확인"
for i in $(seq 1 $MAX_RETRIES); do
    if timeout 2 bash -c ">/dev/tcp/${HOST}/${APP_PORT}" 2>/dev/null; then
        success "서비스 포트 열림 확인 완료: ${HOST}:${APP_PORT}"
        break
    else
        echo "포트 ${APP_PORT} 확인 중... (${i}/${MAX_RETRIES})"
        sleep $SLEEP_TIME
    fi

    if [[ "$i" -eq "$MAX_RETRIES" ]]; then
        fail "서비스 포트 ${APP_PORT} 열림 실패"
        exit 1
    fi
done

# ===============================
# 9. 최신 Pod 로그 확인 (실시간, 모든 컨테이너)
# ===============================
step "최신 Pod 로그 확인 (Ctrl+C로 종료)"

# 최신 Pod 이름 재조회
POD_NAME=$(kubectl get pods -l app=myapp --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
if [[ -z "$POD_NAME" ]]; then
    fail "로그 확인할 Pod를 가져오지 못했습니다."
    exit 1
fi

# 로그 명령어 출력
echo "kubectl logs -f \"$POD_NAME\" --all-containers=true"
