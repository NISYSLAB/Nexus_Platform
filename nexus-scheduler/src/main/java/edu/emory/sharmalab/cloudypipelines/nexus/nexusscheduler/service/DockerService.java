package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class DockerService {
    private static final Logger LOGGER = LoggerFactory.getLogger(DockerService.class);
    private String imageName = "";
    private String imageTag = "";
    private String digest = "";
    private String command = "";
    private Map<String, String> options = new ConcurrentHashMap<>();

}
