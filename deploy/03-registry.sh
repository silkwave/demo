#!/bin/bash
source ./00-common.sh

step "3. 로컬 Podman 레지스트리 실행"

# 기존 레지스트리 제거
podman rm -f registry || true

# 레지스트리 실행
podman run -d --network=host --name registry registry:2
success "Podman 레지스트리 실행 완료"

# 실행 중 레지스트리 확인
step "실행 중 레지스트리 컨테이너 확인"
podman ps | grep registry || echo "⚠ 레지스트리 컨테이너 실행 중 아님"

# 레지스트리 저장 이미지 조회
step "로컬 레지스트리 이미지 목록 확인"
podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
