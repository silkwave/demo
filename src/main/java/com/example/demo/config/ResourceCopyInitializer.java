package com.example.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.event.EventListener;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class ResourceCopyInitializer {

    private final ResourceCopyService copyService;

    @Value("${app.source.resource-path}")
    private String sourceResourcePath;

    @Value("${app.target.file-path}")
    private String targetFilePath;

    public ResourceCopyInitializer(ResourceCopyService copyService) {
        this.copyService = copyService;
    }

    /**
     * 애플리케이션 기동 완료 후 리소스 복사
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
     
        log.error("ResourceCopyInitializer onApplicationReady started" , sourceResourcePath, targetFilePath);
        copyService.copyResource(sourceResourcePath, targetFilePath);
    }
}
