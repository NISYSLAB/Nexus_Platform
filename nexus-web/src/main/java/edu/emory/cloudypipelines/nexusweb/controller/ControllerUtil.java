package edu.emory.cloudypipelines.nexusweb.controller;

import edu.emory.cloudypipelines.nexusweb.bean.ErrorMessage;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class ControllerUtil {
    public static ResponseEntity<?> badRequest(String message) {
        ErrorMessage errorMessage = new ErrorMessage();
        errorMessage.setStatus("BAD_REQUEST");
        errorMessage.setMessage(message);
        return new ResponseEntity(errorMessage, new HttpHeaders(), HttpStatus.BAD_REQUEST);
    }

    public static ResponseEntity<?> conflictRequest(String message) {
        ErrorMessage errorMessage = new ErrorMessage();
        errorMessage.setStatus("CONFLICT");
        errorMessage.setMessage(message);
        return new ResponseEntity(errorMessage, new HttpHeaders(), HttpStatus.CONFLICT);
    }

    public static ResponseEntity<?> unAuthorized(String message) {
        ErrorMessage errorMessage = new ErrorMessage();
        errorMessage.setStatus("UNAUTHORIZED");
        errorMessage.setMessage(message);
        return new ResponseEntity(errorMessage, new HttpHeaders(), HttpStatus.UNAUTHORIZED);
    }

    public static boolean isHttpOk(HttpStatus httpStatus) {
        return httpStatus.is2xxSuccessful();
    }

    public static boolean isHttpOk(int statusCodeValue) {
        return (statusCodeValue > 199 && statusCodeValue < 300);
    }

    public static ResponseEntity<?> OK(Object object) {
        return new ResponseEntity<>(object, new HttpHeaders(), HttpStatus.OK);
    }

    public static ResponseEntity<?> notFound(String message) {
        ErrorMessage errorMessage = new ErrorMessage();
        errorMessage.setStatus("Not Found");
        errorMessage.setMessage(message);
        return new ResponseEntity(errorMessage, new HttpHeaders(), HttpStatus.NOT_FOUND);
    }
}
