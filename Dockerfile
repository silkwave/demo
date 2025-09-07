FROM openjdk:17-jdk
WORKDIR /app

# JAR 복사 (경로 디버깅을 위해 COPY 후 바로 확인)
COPY build/libs/demo-0.0.1-SNAPSHOT.jar /app/app.jar
RUN ls -l /app

RUN mkdir -p /opt/backup && chmod 777 /opt/backup
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]


# # 1. JAR 빌드
# ./gradlew clean build

# # 2. 이미지 빌드 (Dockerfile 기반)
# podman build -t localhost/spring-server .

# # 3. 이미지 안에 JAR 확인
# podman run --rm -it localhost/spring-server ls -l /app

# # 4. 단독 실행 테스트
# podman run -p 8080:8080 localhost/spring-server

# # 5. 쿠버네티스 Pod/Service 실행
# podman play kube spring-pod.yaml

# podman ps --pod  

# podman exec -it spring-pod-spring-container sh
