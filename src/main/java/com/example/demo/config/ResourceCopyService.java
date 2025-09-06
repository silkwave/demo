package com.example.demo.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;

@Component
@Slf4j
public class ResourceCopyService {

    /**
     * JAR 내부(classpath) 리소스를 외부 파일로 안전하게 복사
     * @param sourceResourcePath 클래스패스 리소스 경로
     * @param targetFilePath 외부 파일 경로
     * @return 복사 성공 여부
     */
    public boolean copyResource(String sourceResourcePath, String targetFilePath) {
        Path target = Paths.get(targetFilePath);

        try {
            // 부모 디렉토리 생성
            Files.createDirectories(target.getParent());

            // ClassPathResource 읽기
            ClassPathResource resource = new ClassPathResource(sourceResourcePath);
            if (!resource.exists()) {
                log.error("복사할 리소스를 찾을 수 없습니다: {}", sourceResourcePath);
                return false;
            }

            // InputStream → 파일 복사
            try (InputStream in = resource.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
                log.info("리소스를 복사했습니다: {} {}", resource.getPath() , target.toAbsolutePath());
                return true;
            } catch (IOException e) {
                log.error("리소스 복사 중 오류 발생: {}", e.getMessage(), e);
            }

        } catch (IOException e) {
            log.error("디렉토리 생성 또는 파일 접근 오류: {}", e.getMessage(), e);
        }
        return false;
    }
}
