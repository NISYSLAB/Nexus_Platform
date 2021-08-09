package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.event;

import org.apache.commons.io.monitor.FileAlterationListener;
import org.apache.commons.io.monitor.FileAlterationListenerAdaptor;
import org.apache.commons.io.monitor.FileAlterationMonitor;
import org.apache.commons.io.monitor.FileAlterationObserver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.File;

@Component
public class FmriBiomarkerModelTrainFileMonitor {
    private static final Logger LOGGER = LoggerFactory.getLogger(FmriBiomarkerModelTrainFileMonitor.class);

    @Value("${fmri_biomarker_model_train_dataset_listener_folder}")
    String fmriBiomarkerModelTrainDatasetListenerFolder;

    FileAlterationListener fmriBiomarkerModelTrainDatasetListener = new FileAlterationListenerAdaptor() {

        @Override
        public void onFileCreate(File file) {
            LOGGER.info("onFileCreate(): new file received: {}", file);
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
        LOGGER.info("init(): vfmriBiomarkerModelTrainDatasetListenerFolder={}", fmriBiomarkerModelTrainDatasetListenerFolder);
        startFmriBiomarkerModelTrainMonitor();
    }

    void startFmriBiomarkerModelTrainMonitor() {
        final String methodName = "startFmriBiomarkerModelTrainMonitor():";

        FileAlterationObserver observer = new FileAlterationObserver(fmriBiomarkerModelTrainDatasetListenerFolder);
        FileAlterationMonitor monitor = new FileAlterationMonitor(5000);
        observer.addListener(fmriBiomarkerModelTrainDatasetListener);
        monitor.addObserver(observer);

        try {
            LOGGER.info("{} start...", methodName);
            monitor.start();
        } catch (Exception e) {
            LOGGER.error("{} Failed to start. Error: ", methodName, e);
        }
    }
}
