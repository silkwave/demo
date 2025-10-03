#!/bin/bash
source ./00-common.sh

step "6️⃣ Pod 상태 확인"

MAX_RETRIES=10
SLEEP_TIME=5

for i in $(seq 1 $MAX_RETRIES); do
    PHASE=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Pending")
    [[ "$PHASE" == "Running" ]] && break

    echo -e "${YELLOW}   Pod 준비 중... (${i}/${MAX_RETRIES})${NC}"
    
    if [[ "$PHASE" == "Pending" ]]; then
        kubectl get events --sort-by=.metadata.creationTimestamp | tail -n 5
    fi
    
    sleep $SLEEP_TIME
done

if [[ "$PHASE" == "Running" ]]; then
    success "✅ Pod Running 완료"
else
    fail "❌ Pod Running 실패"
    kubectl describe pod -l app=myapp
fi
