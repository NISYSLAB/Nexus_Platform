package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.event;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service.GRAPipelineProcess;
import org.apache.commons.io.monitor.FileAlterationListener;
import org.apache.commons.io.monitor.FileAlterationListenerAdaptor;
import org.apache.commons.io.monitor.FileAlterationMonitor;
import org.apache.commons.io.monitor.FileAlterationObserver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.File;

@Component
public class GRAPipelineMonitor {
    private static final Logger LOGGER = LoggerFactory.getLogger(GRAPipelineMonitor.class);

    @Value("${gra_pipeline_listener_folder}")
    String graPipelineListenerFolder;
    @Autowired
    GRAPipelineProcess graPipelineProcess;
    FileAlterationListener graDataInputListener = new FileAlterationListenerAdaptor() {

        @Override
        public void onFileCreate(File file) {
            LOGGER.info("onFileCreate(): new file received: {}", file);
            graPipelineProcess.runEveryThing(file);
        }

        @Override
        public void onFileDelete(File file) {
            LOGGER.info("onFileDelete(): file deleted: {}", file);
        }

        @Override
        public void onFileChange(File file) {
            LOGGER.info("onFileChange(): file changed: {}, do not process, since it might be copying", file);
            //graPipelineProcess.runEveryThing(file);
        }
    };
    @Value("${gra_check_interval}")
    private Integer graCheckInterval;

    @PostConstruct
    void init() {
        LOGGER.info("init(): graCheckInterval={}", graCheckInterval);
        LOGGER.info("init(): graPipelineListenerFolder={}", graPipelineListenerFolder);
        startGRAPipelineMonitor();
    }

    private void startGRAPipelineMonitor() {
        final String methodName = "startGRAPipelineMonitor():";

        FileAlterationObserver observer = new FileAlterationObserver(graPipelineListenerFolder);
        FileAlterationMonitor monitor = new FileAlterationMonitor(graCheckInterval);
        observer.addListener(graDataInputListener);
        monitor.addObserver(observer);

        try {
            LOGGER.info("{} start...", methodName);
            monitor.start();
        } catch (Exception e) {
            LOGGER.error("{} Failed to start. Error: ", methodName, e);
        }
    }
}


