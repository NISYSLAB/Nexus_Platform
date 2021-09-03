package edu.emory.cloudypipelines.nexusweb.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.DefaultResponseErrorHandler;

import java.io.IOException;

@Component
public class RestTemplateResponseErrorHandler extends DefaultResponseErrorHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(RestTemplateResponseErrorHandler.class);

    @Override
    public boolean hasError(ClientHttpResponse response) throws IOException {
        return super.hasError(response);
    }

    @Override
    public void handleError(ClientHttpResponse clientHttpResponse) throws IOException {
        final String methodName = "handleError(): ";
        LOGGER.error("{} status={}", methodName, clientHttpResponse.getStatusCode());
        //LOGGER.error("{} clientHttpResponse.getBody={}", methodName, clientHttpResponse.getBody().);
        //LOGGER.error("{} clientHttpResponse.getHeaders={}", methodName, clientHttpResponse.getHeaders());
    }
}