#!/bin/bash
set -e
cd "$(dirname "$0")"

#./01-oracle.sh
./02-minikube-init.sh
./03-registry.sh
./04-build-push.sh
./05-deploy.sh
./06-check-pod.sh
./07-port-forward.sh

echo -e "\033[0;32m✅ 전체 배포 완료: http://localhost:8080\033[0m"
