package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;


import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.UtilHelper;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class CommonProcess {

    private static final Logger LOGGER = LoggerFactory.getLogger(CommonProcess.class);

    @Value("${execution_folder}")
    String executionFolder;

    @Autowired
    RuntimeExecutionService runtimeExecutionService;

    public String getNamingThread() {
        return "[" + Thread.currentThread().getName() + "]";
    }

    public String createProcessFolder(String subfolder) {
        String mountFolder = executionFolder + "/" + subfolder + "_" + UtilHelper.getTimestampStr(16) + UtilHelper.getRandomNumber(1000, 9999);
        mountFolder = mountFolder.replace("//", "/");
        try {
            FileUtils.forceMkdir(new File(mountFolder));
        } catch (IOException e) {
            LOGGER.error("createProcessFolder(): Failed to create directory {}. Error: {}", mountFolder, e.getMessage());
            mountFolder = "";
        }
        return mountFolder;
    }

    public void execSys(String executionFolder, String[] commandArr) {
        final String methodName = "[" + Thread.currentThread().getName() + "] execSys():";
        if (executionFolder == null || executionFolder.isEmpty()) {
            LOGGER.error("{} Failed to create directory {}. Unable to process", methodName, executionFolder);
            return;
        }

        LOGGER.info("{} started process in folder={}: {}", methodName, executionFolder, commandArr);
        long start = System.currentTimeMillis();
        SystemCommandOutput systemCommandOutput = runtimeExecutionService.execSystemCommand(commandArr, null, new File(executionFolder));
        long end = System.currentTimeMillis();
        LOGGER.info("{} process details\n{}", methodName, systemCommandOutput.toString());
        LOGGER.info("{} {} second or {} minutes taken for process: {}", methodName, (end - start) / 1000.0, (System.currentTimeMillis() - start) / (1000 * 60.0), commandArr);

        //UtilHelper.writeStringToFile(executionFolder + "/server_process.log", systemCommandOutput.toString());
    }
}
