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
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

@Getter
@Setter
@NoArgsConstructor
@ToString
@Service
public class Dicom2NiftiProcess extends CommonProcess {
    private static final Logger LOGGER = LoggerFactory.getLogger(Dicom2NiftiProcess.class);

    @Value("${start_dicom2nifti_script}")
    String startDicom2NiftiScript;

    @PostConstruct
    void inti() {
        LOGGER.info("init(): mountDisk={}", mountDisk);
        LOGGER.info("init(): startDicom2NiftiScript={}", startDicom2NiftiScript);
    }

    /**
     * Calling async method from within the same class would trigger the original method and not the intercepted one.
     * You need to create another service with the async method, and call it from your service.
     * @param dicomFile
     */
    @Async("nexusSchedulerExecutor")
    public void runConversion(File dicomFile) {
        final String methodName = getNamingThread() + ": runConversion():";
        LOGGER.info("{} received dicomFile={}", methodName, dicomFile);
        String mountFolder = createProcessFolder("/convert/dicom2nifti" + dicomFile.getName());
        String[]commandArr = new String[]{
                "bash",
                startDicom2NiftiScript,
                dicomFile.getAbsolutePath()
        };
        execSys(mountFolder, commandArr);
    }
}
