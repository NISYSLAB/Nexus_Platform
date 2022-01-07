package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.UtilHelper;
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
public class GRAPipelineProcess extends CommonProcess {
    private static final Logger LOGGER = LoggerFactory.getLogger(GRAPipelineProcess.class);

    @Value("${gra_container_start_script}")
    String graContainerStartScript;

    @PostConstruct
    void inti() {
        LOGGER.info("init(): mountDisk={}", mountDisk);
        LOGGER.info("init(): graContainerStartScript={}", graContainerStartScript);
    }

    /**
     * Calling async method from within the same class would trigger the original method and not the intercepted one.
     * You need to create another service with the async method, and call it from your service.
     *
     * @param dataset
     */
    @Async(GRA_PIPELINE_EXECUTOR)
    public void runEveryThing(File dataset) {
        final String methodName = getNamingThread() + ": runEveryThing():";
        LOGGER.info("{} received dataset={}", methodName, dataset);
        String fileNameWithoutExt = UtilHelper.getFileNameWithoutExtension(dataset.getName());
        String mountFolder = createProcessFolder("/gra/" + fileNameWithoutExt);
        String[] commandArr = new String[]{
                "bash",
                graContainerStartScript,
                dataset.getName(),
                dataset.getAbsolutePath()
        };
        execSys(mountFolder, commandArr);
    }

}

