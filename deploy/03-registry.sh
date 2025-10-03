#!/bin/bash
source ./00-common.sh

step "3️⃣ 로컬 Podman 레지스트리 실행"
podman rm -f registry || true
podman run -d --network=host --name registry registry:2
success "Podman 레지스트리 실행 완료"
