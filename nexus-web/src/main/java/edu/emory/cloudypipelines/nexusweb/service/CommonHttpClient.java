package edu.emory.cloudypipelines.nexusweb.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

@Component
public class CommonHttpClient {
    private static final Logger LOGGER = LoggerFactory.getLogger(CommonHttpClient.class);
    final String submissionRootDir = "/tmp/nexusweb/submission";

    @Autowired
    RestTemplate restTemplate;

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder restTemplateBuilder) {
        return restTemplateBuilder.errorHandler(new RestTemplateResponseErrorHandler()).build();
    }

    public <T> ResponseEntity<T> httpGet(String httpUrl, Class<T> responseType) {
        final String methodName = "httpGet():";
        LOGGER.info("{} httpUrl={}", methodName, httpUrl);
        return restTemplate.getForEntity(httpUrl, responseType);
    }

    public String httpDownload2File(String httpFileUrl, String destFilePath) {
        final String methodName = "httpDownload2File():";
        LOGGER.info("{} httpFileUrl={}, destFilePath={}", methodName, httpFileUrl, destFilePath);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setAccept(Arrays.asList(MediaType.APPLICATION_OCTET_STREAM));
            HttpEntity<String> entity = new HttpEntity<>(headers);
            ResponseEntity<byte[]> response = restTemplate.exchange(httpFileUrl, HttpMethod.GET, entity, byte[].class);
            Files.write(Paths.get(destFilePath), response.getBody());
            return destFilePath;
        } catch (Exception e) {
            LOGGER.error("{} Exception: {}", methodName, e.getMessage());
            return "";
        }
    }
}
