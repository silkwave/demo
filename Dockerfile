FROM openjdk:17-jdk

# 앱용 사용자 생성 (CRI-O 친화)
RUN useradd -u 1001 -m appuser

# 작업 디렉토리 생성 & 권한 설정
RUN mkdir -p /app /opt/backup && \
    chown -R appuser:appuser /app /opt/backup

WORKDIR /app

# JAR 복사 + 소유자 변경
COPY --chown=appuser:appuser build/libs/demo-0.0.1-SNAPSHOT.jar /app/app.jar

# 일반 사용자로 실행
USER appuser

# 포트
EXPOSE 8080

# ENTRYPOINT
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
