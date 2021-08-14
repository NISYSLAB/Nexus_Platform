package edu.emory.cloudypipelines.nexusweb.utils;

import org.springframework.http.ResponseEntity;

public class CommonUtil {

    public static boolean isNullOrEmpty(String tested) {
        return (tested == null || tested.trim().isEmpty());
    }

    public static <T> boolean isHttpRequestSuccessful(ResponseEntity<T> responseEntity) {
        if (responseEntity == null) {
            return false;
        }
        int httpStatusValue = responseEntity.getStatusCodeValue();
        return httpStatusValue >= 200 && httpStatusValue <= 299;
    }

    public static String getTrimOrDefault(String process, String replaced) {
        return (process == null) ? replaced : process.trim();
    }
}
