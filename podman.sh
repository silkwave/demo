
Podman 로컬 registry 실행 (HTTP, insecure)
# registry 컨테이너 실행
podman run -d -p 5000:5000 --name registry docker.io/library/registry:2

# Podman 사용자 설정 파일 열기 (rootless 기준):
mkdir -p ~/.config/containers
nano ~/.config/containers/registries.conf

# 아래 내용 추가:
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "localhost:5000"
location = "localhost:5000"
insecure = true


# 변경 적용 확인:
podman info | grep -A5 registries

# 이미지 태그 변경 & push
# 로컬 이미지 태그 변경
podman tag localhost/spring-server:latest localhost:5000/spring-server:latest

# 로컬 registry로 push
podman push localhost:5000/spring-server:latest

# Kubernetes에서 사용할 이미지로 지정
containers:
  - name: spring-container
    image: localhost:5000/spring-server:latest
    imagePullPolicy: IfNotPresent

# Deployment + Service 적용
kubectl apply -f spring-deployment.yaml

# 상태 확인
kubectl get deployments
kubectl get pods
kubectl get svc
