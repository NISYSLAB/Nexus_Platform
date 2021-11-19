package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service.RuntimeExecutionService;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class UtilHelper {
    private static final Logger LOGGER = LoggerFactory.getLogger(UtilHelper.class);
    public static List<File> listFilesEndsWith(String srcDir, String filePattern) {
        File dir = new File(srcDir);
        File[] files = dir.listFiles((d, name) -> name.endsWith(filePattern));
        return (files == null) ? Collections.emptyList() : Arrays.asList(files);
    }

    public static String getTimestampStr(int numberOfDigits) {
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-HH");
        String timestamp = formatter.format(new Date());
        return (timestamp + UUID.randomUUID().toString()).substring(0, numberOfDigits);
    }

    public static int getRandomNumber(int min, int max) {
        Random random = new Random();
        return random.ints(min, max)
                .findFirst()
                .getAsInt();
    }

    public static String getRandUpperStr(int count) {
        return RandomStringUtils.randomAlphabetic(count).toUpperCase();
    }

    public static String getRandLowerStr(int count) {
        return RandomStringUtils.randomAlphabetic(count).toLowerCase();
    }

    public static void writeStringToFile(String filePath, String content) {
        try {
            FileUtils.writeStringToFile(new File(filePath), content, StandardCharsets.UTF_8);
        } catch (IOException e) {
            LOGGER.error("writeStringToFile{}: Error:", e);

        }

    }

    public static String getFileNameWithoutExtension(String fileName) {
        return FilenameUtils.removeExtension(fileName);
    }
}
