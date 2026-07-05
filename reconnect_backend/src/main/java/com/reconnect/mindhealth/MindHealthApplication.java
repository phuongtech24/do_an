package com.reconnect.mindhealth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import com.reconnect.mindhealth.config.EnvLocalLoader;

@SpringBootApplication
@EnableScheduling
@EnableAsync
public class MindHealthApplication {
    public static void main(String[] args) {
        EnvLocalLoader.loadIntoSystemProperties();
        SpringApplication.run(MindHealthApplication.class, args);
    }
}
