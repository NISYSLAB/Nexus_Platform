package edu.emory.cloudypipelines.nexusweb.utils;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Date;
import java.util.Iterator;

public class CommonUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(CommonUtil.class);
    static DateFormat dateFormat1 = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss");

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
        String destDir = String.format("%s/%s_%s", parentDir, getTimeStamps(dateFormat1), getRandomNumericString(12));
        File file = new File(destDir);
        file.mkdirs();
        return destDir;
    }

    public static String getTimeStamps(DateFormat dateFormat) {
        return dateFormat.format(new Date());
    }

    public static String getRandomString(int length) {
        return RandomStringUtils.randomAlphanumeric(length);
    }

    public static String getRandomNumericString(int length) {
        return RandomStringUtils.randomNumeric(length);
    }

    public static String saveUploadedFile(MultipartFile multipartFile, String uploadFolder) {
        final String methodName = "saveUploadedFile(): ";
        if (multipartFile == null) {
            LOGGER.info("{} multipartFile is null, unable to process it, return", methodName);
            return "";
        }
        LOGGER.info("{} uploadFolder={}", methodName, uploadFolder);
        File newFolder = new File(uploadFolder);
        newFolder.mkdirs();

        byte[] bytes = new byte[0];
        try {
            bytes = multipartFile.getBytes();
        } catch (IOException e) {
            LOGGER.error("{} IOException: {}", methodName, e.getMessage());
            return "";
        }
        String fullPath = uploadFolder + "/" + multipartFile.getOriginalFilename();
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

    public static String copyFileToDirectory(String srcFilePath, String directoryPath) {
        final String methodName = "copyFileToDirectory():";
        String destFilePath = "";
        File srcFile = new File(srcFilePath);
        try {
            FileUtils.copyFileToDirectory(srcFile, new File(directoryPath));
            destFilePath = String.format("%s/%s", directoryPath, srcFile.getName());
        } catch (IOException e) {
            destFilePath = "";
            LOGGER.error("{} Exception: ", methodName, e);
        }
        return destFilePath;
    }

    public static String writePOJO2File(Object object, String destFilePath) {
        final String methodName = "writePOJO2File():";
        String finalFilePath = destFilePath;
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(new File(destFilePath), object);
        } catch (IOException e) {
            finalFilePath = "";
            LOGGER.error("{} Exception: ", methodName, e);
        }
        return finalFilePath;
    }

    public static ZonedDateTime getUTCNow() {
        return ZonedDateTime.now(ZoneId.of("UTC"));
    }

    public static Long getEpochMilli(ZonedDateTime zonedDateTime) {
        return zonedDateTime.toInstant().toEpochMilli();
    }

    public static <T> T json2POJO(String json, Class<T> type) {
        final String methodName = "json2POJO():";
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(json, type);

        } catch (JsonParseException e) {
            LOGGER.error("{} JsonParseException: {}", methodName, e.getMessage());
        } catch (JsonMappingException e) {
            LOGGER.error("{} JsonMappingException: {}", methodName, e.getMessage());
        } catch (IOException e) {
            LOGGER.error("{} IOException: {}", methodName, e.getMessage());
        }
        return null;
    }

    public static String POJO2Json(Object pojo) {
        final String methodName = "POJO2Json():";
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            return objectMapper.writeValueAsString(pojo);
        } catch (JsonProcessingException e) {
            LOGGER.error("{} JsonProcessingException: {}", methodName, e.getMessage());
        }
        return "";
    }

    public static String parseCromwellSingleOutput(String outputsJson) {
        final String methodName = "parseCromwellSingleOutput(): ";
        final String outputsFieldName = "outputs";
        String output = "";
        if (outputsJson == null || outputsJson.isEmpty()) {
            return output;
        }
        ObjectMapper mapper = new ObjectMapper();
        try {
            JsonNode treeNode = mapper.readTree(outputsJson).get(outputsFieldName);
            if (treeNode == null) {
                return output;
            }
            String treeString = treeNode.toString();
            if (treeString == null || treeString.isEmpty()) {
                return output;
            }

            JsonNode outputsNode = mapper.readTree(treeString);
            Iterator<String> fieldNames = outputsNode.fieldNames();
            while (fieldNames.hasNext()) {
                String fieldName = fieldNames.next();
                output = outputsNode.get(fieldName).toString();
            }
        } catch (IOException e) {
            output = "";
            LOGGER.error("{} Exception: ", methodName, e);
        }
        if (output != null) {
            output = output.replaceAll("\"", "");
        }
        return output;
    }

    public static String copyTextToFile(String text, String destFilePath) {
        try {
            FileUtils.writeStringToFile(new File(destFilePath), text, Charset.defaultCharset());
            return destFilePath;
        } catch (IOException e) {
            LOGGER.error("copyTextToFile(): IOException: {}", e.getMessage());
            return "";
        }
    }
}
