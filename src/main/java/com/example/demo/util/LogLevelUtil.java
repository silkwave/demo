package com.example.demo.util;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class LogLevelUtil {

    private static final org.slf4j.Logger log = LoggerFactory.getLogger(LogLevelUtil.class);

    public static void setGlobalLogLevel(Level level) {
        LoggerContext loggerContext = (LoggerContext) LoggerFactory.getILoggerFactory();
        log.info("전체 로거들의 로그 레벨을 {}로 설정합니다.", level);
        int loggerCount = 0;
        for (Logger logger : loggerContext.getLoggerList()) {
            logger.setLevel(level);
            loggerCount++;
        }
        log.info("총 {}개의 로거의 로그 레벨을 {}로 설정했습니다.", loggerCount, level);
    }
}