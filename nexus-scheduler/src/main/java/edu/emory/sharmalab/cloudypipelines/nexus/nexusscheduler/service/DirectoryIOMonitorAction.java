package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.File;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class DirectoryIOMonitorAction extends CommonProcess {
    private static final Logger LOGGER = LoggerFactory.getLogger(DirectoryIOMonitorAction.class);

    @Value("${execution_script}")
    String executionScript;

    @Value("${execution_folder}")
    String executionFolder;

    @PostConstruct
    void inti() {
        LOGGER.info("init(): executionFolder={}", executionFolder);
        LOGGER.info("init(): executionScript={}", executionScript);
    }

    /**
     * Calling async method from within the same class would trigger the original method and not the intercepted one.
     * You need to create another service with the async method, and call it from your service.
     *
     * @param file
     */
    @Async("nexusSchedulerExecutor")
    public void process(File file) {
        final String methodName = getNamingThread() + ": process():";
        LOGGER.info("{} received file={}", methodName, file);
        //String mountFolder = createProcessFolder("/tmp" + file.getName());
        String mountFolder = executionFolder;
        String[] commandArr = new String[]{
                "bash",
                executionScript,
                file.getAbsolutePath()
        };
        execSys(mountFolder, commandArr);
    }
}
