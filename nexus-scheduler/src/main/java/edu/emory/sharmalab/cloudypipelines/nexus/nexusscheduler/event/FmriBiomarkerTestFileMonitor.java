package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.event;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service.FmriBiomarkerProcess;
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
public class FmriBiomarkerTestFileMonitor {
    private static final Logger LOGGER = LoggerFactory.getLogger(FmriBiomarkerTestFileMonitor.class);

    @Value("${fmri_biomarker_test_dataset_listener_folder}")
    String fmriBiomarkerTestDatasetListenerFolder;

    @Autowired
    FmriBiomarkerProcess fmriBiomarkerProcess;

    FileAlterationListener fmriBiomarkerTestDatasetListener= new FileAlterationListenerAdaptor() {

        @Override
        public void onFileCreate(File file) {

            LOGGER.info("onFileCreate(): new file received: {}", file);
            fmriBiomarkerProcess.runPredict(file);
            //fmriBiomarkerProcess.runFeatureActivationMap(file);
        }

        @Override
        public void onFileDelete(File file) {
            LOGGER.info("onFileDelete(): file deleted: {}", file);
        }

        @Override
        public void onFileChange(File file) {
            LOGGER.info("onFileChange(): file changed: {}", file);
        }
    };

    @PostConstruct
    void init() {
        LOGGER.info("init(): fmriBiomarkerTestDatasetListenerFolder={}", fmriBiomarkerTestDatasetListenerFolder);
        startFmriBiomarkerTestMonitor();
    }

    private void startFmriBiomarkerTestMonitor() {
        final String methodName = "startFmriBiomarkerTestMonitor():";

        FileAlterationObserver observer = new FileAlterationObserver(fmriBiomarkerTestDatasetListenerFolder);
        FileAlterationMonitor monitor = new FileAlterationMonitor(2000);
        observer.addListener(fmriBiomarkerTestDatasetListener);
        monitor.addObserver(observer);

        try {
            LOGGER.info("{} start...", methodName);
            monitor.start();
        } catch (Exception e) {
            LOGGER.error("{} Failed to start. Error: ", methodName, e);
        }
    }
}

