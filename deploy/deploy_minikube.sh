#!/bin/bash

# ============================================================
# 1. Minikube 초기화 / 업그레이드
# ============================================================

# 기존 Minikube 중지 및 삭제
minikube stop
minikube delete

# 대시보드 확인
minikube dashboard
minikube dashboard --url

# 최신 버전 다운로드 및 설치
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# ============================================================
# 2. Podman 단일 컨테이너 실행 및 Kubernetes 변환
# ============================================================

# Nginx 테스트 컨테이너 실행
podman run -d --name web -p 8080:80 nginx

# Podman 컨테이너를 Kubernetes YAML로 변환
podman generate kube web > web-pod.yaml

# Kubernetes에 배포
kubectl apply -f web-pod.yaml

# 상태 확인
kubectl get pods
kubectl describe pod web-pod
kubectl get pods -o wide
kubectl get pods --all-namespaces

# 컨테이너 내부 접근
kubectl exec -it web-pod -- /bin/sh

# 로그 확인
kubectl logs -l app=web
kubectl logs -f -l app=web

# 서비스 포트 확인/접속
kubectl get svc
kubectl port-forward svc/web 8080:80
curl http://localhost:8080/

# ============================================================
# 3. Minikube 내부 레지스트리 설정 (Podman 이미지 사용)
# ============================================================

minikube ssh
sudo vi /etc/containers/registries.conf

# 예시 설정
# [registries.insecure]
# registries = ["192.168.139.179:5000", "localhost:5000"]
# [registries.search]
# registries = ["podman.io", "quay.io"]

# ============================================================
# 4. Spring Boot 애플리케이션 빌드 & Podman 이미지 생성
# ============================================================

# 1) JAR 빌드
./gradlew clean build

# 2) Dockerfile 기반 이미지 빌드
podman build -t localhost/spring-server .

# 3) 이미지 내 JAR 확인
podman run --rm -it localhost/spring-server ls -l /app

# 4) 단독 실행 테스트
podman run -d --name spring-server -p 8080:8080 localhost/spring-server

# ============================================================
# 5. Spring Boot Podman Pod / Kubernetes 배포
# ============================================================

# Podman Pod 예시
# podman pod create --name spring-server-pod -p 8080:8080
# podman run -d --pod spring-server-pod --name spring-server localhost/spring-server

# 현재 Pod 및 컨테이너 확인
podman pod ps
podman ps --pod

# Podman Pod를 Kubernetes YAML로 변환
podman generate kube spring-server > spring-server.yaml

# Kubernetes에 배포
kubectl apply -f spring-server.yaml

# 상태 확인
kubectl get pods
kubectl get pods --all-namespaces
kubectl describe pod myapp-5887589fbf-rpvnd
kubectl logs -f myapp-5887589fbf-rpvnd

# 컨테이너 내부 접근
kubectl exec -it myapp-5887589fbf-5np45 -- bash

# 서비스 포트 포워딩
kubectl port-forward pod/spring-server-pod-spring-server 8080:8080
minikube service spring-server --url

# ============================================================
# 6. Cleanup: 모든 Pod / Deployment / Service 삭제
# ============================================================

kubectl delete pod --all
kubectl delete deployment --all
kubectl delete svc --all
kubectl delete all --all

podman ps -q --filter ancestor=spring-server | xargs -r podman stop
podman ps -a -q --filter ancestor=spring-server | xargs -r podman rm
podman images -q spring-server | xargs -r podman rmi -f

# 전체 컨테이너/이미지 삭제 (선택)
podman stop $(podman ps -a -q)
podman rm $(podman ps -a -q)
podman rmi -f $(podman images -q)

# ============================================================
# 7. Alias 설정 (선택)
# ============================================================

alias podman="podman"
alias podman-compose="podman-compose"
