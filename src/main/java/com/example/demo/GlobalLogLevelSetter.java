package com.example.demo;

import ch.qos.logback.classic.Level;
import com.example.demo.util.LogLevelUtil;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class GlobalLogLevelSetter implements CommandLineRunner {

    @Override
    public void run(String... args) throws Exception {
//        LogLevelUtil.setGlobalLogLevel(Level.INFO); // 원하는 로그 레벨 설정
    }

}