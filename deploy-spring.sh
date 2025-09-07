#!/bin/bash
set -e

IMAGE_NAME="spring-server"
LOCAL_IMAGE="localhost/$IMAGE_NAME:latest"
REGISTRY_IMAGE="localhost:5000/$IMAGE_NAME:latest"
DEPLOYMENT_FILE="spring-deployment.yaml"
DEPLOYMENT_NAME="spring-deployment"
SERVICE_NAME="spring-service"

# -------------------------------
# 1. 로컬 registry 실행 확인/생성
# -------------------------------
if ! podman container exists registry; then
  echo "💡 로컬 registry 실행..."
  podman run -d -p 5000:5000 --name registry docker.io/library/registry:2
else
  echo "💡 registry 이미 실행 중"
fi

# -------------------------------
# 2. Podman에서 로컬 이미지 태그 변경 & push
# -------------------------------
echo "💡 이미지 태그 변경: $LOCAL_IMAGE → $REGISTRY_IMAGE"
podman tag "$LOCAL_IMAGE" "$REGISTRY_IMAGE"

echo "💡 이미지 push: $REGISTRY_IMAGE"
podman push "$REGISTRY_IMAGE"

# -------------------------------
# 3. 기존 Deployment/Pod 삭제
# -------------------------------
if kubectl get deployment "$DEPLOYMENT_NAME" &>/dev/null; then
  echo "💡 기존 Deployment 삭제: $DEPLOYMENT_NAME"
  kubectl delete deployment "$DEPLOYMENT_NAME"
fi

if kubectl get pod -l app=spring &>/dev/null; then
  echo "💡 기존 Pod 삭제"
  kubectl delete pod -l app=spring
fi

# -------------------------------
# 4. Deployment YAML 생성
# -------------------------------
cat > $DEPLOYMENT_FILE <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  labels:
    app: spring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spring
  template:
    metadata:
      labels:
        app: spring
    spec:
      containers:
        - name: spring-container
          image: $REGISTRY_IMAGE
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1"
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
spec:
  type: NodePort
  selector:
    app: spring
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30081
EOF

echo "💡 Deployment YAML 생성 완료: $DEPLOYMENT_FILE"

# -------------------------------
# 5. Minikube에 Deployment 적용
# -------------------------------
echo "💡 Minikube에 Deployment 적용..."
kubectl apply -f $DEPLOYMENT_FILE

# -------------------------------
# 6. 배포 상태 확인
# -------------------------------
echo "💡 Pod 상태 확인 중..."
kubectl get pods

# -------------------------------
# 7. 로그 실시간 확인
# -------------------------------
echo "💡 Pod 로그 출력 (Ctrl+C로 종료)"
kubectl logs -l app=spring -f
