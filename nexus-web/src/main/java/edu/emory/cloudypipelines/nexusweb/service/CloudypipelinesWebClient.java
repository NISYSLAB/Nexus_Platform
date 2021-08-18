package edu.emory.cloudypipelines.nexusweb.service;

import edu.emory.cloudypipelines.nexusweb.utils.CommonUtil;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

import java.time.Duration;
import java.util.concurrent.TimeUnit;


@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class CloudypipelinesWebClient {
    public static final String VERSION_V1 = "v1";
    private static final Logger LOGGER = LoggerFactory.getLogger(CloudypipelinesWebClient.class);

    @Value("${cloudypipelines_url}")
    String baseUrl;

    @Value("${cloudypipelines_timeout_in_seconds}")
    int timeOutInSeconds;

    @Value("${AUTH_TOKEN}")
    private String AUTH_TOKEN; // this one might pull from each users
    private WebClient webClient;

    //@PostConstruct
    void init() {
        final String methodName = "init():";
        LOGGER.info("{} creating webClient: baseUrl={}, timeOutInSeconds={}", methodName, baseUrl, timeOutInSeconds);
        HttpClient httpClient = HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, timeOutInSeconds * 1000)
                .responseTimeout(Duration.ofMillis(timeOutInSeconds * 1000))
                .doOnConnected(conn ->
                        conn.addHandlerLast(new ReadTimeoutHandler(timeOutInSeconds * 1000, TimeUnit.MILLISECONDS))
                                .addHandlerLast(new WriteTimeoutHandler(timeOutInSeconds * 1000, TimeUnit.MILLISECONDS)));

        webClient = WebClient.builder()
                .baseUrl(baseUrl)
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .build();

        // testing
        String cromwellId = "2208acca-9e69-4f33-84fa-e6ca90e550bf";
        LOGGER.info("{} getLogsUrlsById={}", methodName, cromwellId);
        LOGGER.info("{} {}", methodName, getLogsUrlByCromwellId(cromwellId));
    }

    public String getLogsUrlByCromwellId(String cromwellId) {
        final String methodName = "getLogsUrlByCromwellId():";
        if (CommonUtil.isNullOrEmpty(cromwellId)) {
            LOGGER.info("{} cromwellId is null or empty, unable to call API", methodName);
            return null;
        }
        LOGGER.info("{} call CloudyPipelines for cromwellId={}", methodName, cromwellId);
        //curl -k -H "Authorization: OAuth ${TOKEN}"  "${API_HOST}/api/workflows/VERSION/{cromwellId}/logs"
        String apiUrl = String.format("/api/workflows/%s/%s/logs", VERSION_V1, cromwellId);
        return getHttpString(apiUrl, AUTH_TOKEN);
    }

    String getHttpString(String apiUrl, String authToken) {
        LOGGER.info("getHttpString(): apiUrl={}", apiUrl);
        return "??";
    }

    private WebClient getDefaultWebClient() {
        return WebClient.builder()
                .baseUrl(baseUrl)
                .build();
    }

    HttpHeaders getAuthHeaders(String authToken) {
        HttpHeaders headers = new HttpHeaders();
        String oAuth = "OAuth " + authToken;
        headers.add("Authorization", oAuth);
        return headers;
    }

}
