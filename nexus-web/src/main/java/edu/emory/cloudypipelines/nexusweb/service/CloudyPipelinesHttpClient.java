package edu.emory.cloudypipelines.nexusweb.service;

import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;

@Component
public class CloudyPipelinesHttpClient {
    public static final String VERSION_V1 = "v1";
    private static final Logger LOGGER = LoggerFactory.getLogger(CloudyPipelinesHttpClient.class);
    @Autowired
    RestTemplate restTemplate;

    @Value("${AUTH_TOKEN}")
    private String AUTH_TOKEN;

    @Value("${cloudypipelines_url}")
    private String API_HOST;

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder restTemplateBuilder) {
        return restTemplateBuilder.errorHandler(new RestTemplateResponseErrorHandler()).build();
    }

    @PostConstruct
    void init() {
        final String methodName = "init():";
        LOGGER.info("{} cloudypipelines_url={}", methodName, API_HOST);

        // testing
        String cromwellId = "2208acca-9e69-4f33-84fa-e6ca90e550bf";
        LOGGER.info("{} getLogsUrlsById={}", methodName, cromwellId);
        LOGGER.info("{} {}", methodName, getLogsUrlByCromwellId(cromwellId));
    }

    ResponseEntity<?> abortByCromwellId(String cromwellId) {
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/v1/{cromwellId}/abort"
        String apiUrl = String.format("%s/api/workflows/v1/%s/abort", API_HOST, cromwellId);
        return restTemplate.exchange(apiUrl,
                HttpMethod.POST,
                new HttpEntity<>(getHttpRequestEmptyMap(), getAuthHeaders(AUTH_TOKEN)),
                new ParameterizedTypeReference<String>() {
                });
    }


    public String getLogsUrlByCromwellId(String cromwellId) {
        final String methodName = "getLogsUrlByCromwellId():";
        if (CommonUtil.isNullOrEmpty(cromwellId)) {
            LOGGER.info("{} cromwellId is null or empty, unable to call API", methodName);
            return "";
        }
        LOGGER.info("{} call CloudyPipelines for cromwellId={}", methodName, cromwellId);
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/VERSION/{cromwellId}/logs"
        String apiUrl = String.format("%s/api/workflows/%s/%s/logs", API_HOST, VERSION_V1, cromwellId);
        return getHttpString(apiUrl);
    }

    public String getHttpString(String apiUrl) {
        ResponseEntity<String> responseEntity = callGetHttp(apiUrl);
        if (!CommonUtil.isHttpRequestSuccessful(responseEntity)) {
            LOGGER.error("getHttpString(): Error from http request for apiUrl={}: {}", apiUrl, responseEntity);
            return "";
        }
        return CommonUtil.getTrimOrDefault(responseEntity.getBody(), "");
    }

    public ResponseEntity<String> callGetHttp(String apiUrl) {
        try {
            return restTemplate.exchange(
                    apiUrl,
                    HttpMethod.GET,
                    new HttpEntity<>(getHttpRequestEmptyMap(), getAuthHeaders(AUTH_TOKEN)),
                    new ParameterizedTypeReference<String>() {
                    });

        } catch (Exception e) {
            LOGGER.error("callGetHttp(): apiUrl={}, Exception: {}", apiUrl, e.getMessage());
            return new ResponseEntity<>("Bad Request", HttpStatus.BAD_REQUEST);
        }
    }

    LinkedMultiValueMap<String, Object> getHttpRequestEmptyMap() {
        LinkedMultiValueMap<String, Object> map = new LinkedMultiValueMap<>();
        return map;
    }

    HttpHeaders getAuthHeaders(String authToken) {
        HttpHeaders headers = new HttpHeaders();
        String oAuth = "OAuth " + authToken;
        headers.add("Authorization", oAuth);
        return headers;
    }

}