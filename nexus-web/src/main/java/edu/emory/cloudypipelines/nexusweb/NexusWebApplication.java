package edu.emory.cloudypipelines.nexusweb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class NexusWebApplication {
    public static void main(String[] args) {
        SpringApplication.run(NexusWebApplication.class, args);
    }
}
