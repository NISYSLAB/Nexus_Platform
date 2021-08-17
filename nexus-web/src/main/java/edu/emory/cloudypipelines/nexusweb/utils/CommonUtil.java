package edu.emory.cloudypipelines.nexusweb.utils;

import org.apache.commons.lang3.RandomStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class CommonUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(CommonUtil.class);

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

    public static String makeDestDirWithTimestamp(String parentDir) {
        DateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss");
        String destDir = String.format("%s/%s_%s", parentDir, getTimeStamps(dateFormat), getRandomString(12));
        File file = new File(destDir);
        file.mkdirs();
        return destDir;
    }

    public static String getTimeStamps(DateFormat dateFormat) {
        return dateFormat.format(new Date());
    }

    public static String getRandomString(int length) {
        return RandomStringUtils.random(length);
    }

    public static String saveUploadedFile(MultipartFile multipartFile, String uploadFolder) {
        final String methodName = "saveUploadedFile(): ";
        File newFolder = new File(uploadFolder);
        newFolder.mkdirs();
        if (multipartFile == null || multipartFile.isEmpty()) {
            LOGGER.info("{} {} is blank, skip it", methodName, multipartFile.getName());
            return "";
        }
        byte[] bytes = new byte[0];
        try {
            bytes = multipartFile.getBytes();
        } catch (IOException e) {
            LOGGER.error("{} IOException: {}", methodName, e.getMessage());
            return "";
        }
        String fullPath = uploadFolder +  "/" + multipartFile.getOriginalFilename();
        Path path = Paths.get(fullPath);
        try {
            Files.write(path, bytes);
        } catch (IOException e) {
            LOGGER.error("{} IOException: {}", methodName, e.getMessage());
            return "";
        }
        LOGGER.info("{} Saved to {}", methodName, path.toAbsolutePath());
        return fullPath.replaceAll("//", "/");
    }
}
