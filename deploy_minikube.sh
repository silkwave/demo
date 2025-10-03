minikube stop
minikube delete


curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64



podman run -d --name web -p 8080:80 nginx
podman generate kube web > web-pod.yaml
kubectl apply -f web-pod.yaml
kubectl get pods
kubectl describe pod web-pod



kubectl get pods -o wide
kubectl get pods --all-namespaces
kubectl exec -it myapp-5887589fbf-9khs2  -- /bin/sh
kubectl describe pod myapp
kubectl get pods -l app=myapp
kubectl logs -l app=myapp
kubectl get svc myapp
ps aux | grep kubectl
kubectl port-forward svc/myapp 8080:8080
curl http://localhost:8080/



minikube ssh
sudo vi /etc/containers/registries.conf
[registries.insecure]
registries = [
    "192.168.139.179:5000",
    "localhost:5000",
]

[registries.search]
registries = [
    "podman.io",
    "quay.io",
]


podman  run --name spring-server -d 192.168.139.179:5000/spring-server:latest

podman inspect 192.168.139.179:5000/spring-server:latest | jq '.[0].RootFS.Layers'

kubectl apply -f spring-server.yaml
kubectl get pods
kubectl describe pod spring-server

kubectl delete pod --all
kubectl delete deployment --all
kubectl delete svc --all
kubectl delete all --all


podman ps -q --filter ancestor=spring-server | xargs -r podman stop
podman ps -a -q --filter ancestor=spring-server | xargs -r podman rm
podman images -q spring-server | xargs -r podman rmi -f

podman stop `podman ps -a -q`
podman rm   `podman ps -a -q`
podman rmi -f `podman images -q`

alias podman="podman"  # podman 명령어 대신 Podman을 사용하도록 alias를 설정합니다.
alias podman-compose="podman-compose"  # podman Compose 명령어 대신 Podman Compose를 사용하도록 alias를 설정합니다.

=================================================================

# # 1. JAR 빌드
# ./gradlew clean build

# # 2. 이미지 빌드 (Dockerfile 기반)
# podman build -t localhost/spring-server .
# podman build --no-cache -t spring-server .


# # 3. 이미지 안에 JAR 확인
# podman run --rm -it localhost/spring-server ls -l /app

# # 4. 단독 실행 테스트
# podman run -p --name spring-server    8080:8080 localhost/spring-server
# podman run -d --name spring-server -p 8080:8080 localhost/spring-server



# # 5. 쿠버네티스 Pod/Service 실행
# podman pod ps        # 현재 Pod 목록 확인
# podman pod stop spring-server-pod
# podman pod rm spring-server-pod
# podman generate kube spring-server > spring-server.yaml
# podman play kube spring-server.yaml
# podman pod ps        # 현재 Pod 목록 확인
# podman ps            # 현재 컨테이너 목록 확인 
# kubectl create -f spring-server.yaml



# podman ps --pod  

# podman exec -it spring-server-pod-spring-server sh

#현재 컨테이너/Pod 설정을 Kubernetes YAML 매니페스트로 변환.

# podman generate kube spring-server > spring-server.yaml
