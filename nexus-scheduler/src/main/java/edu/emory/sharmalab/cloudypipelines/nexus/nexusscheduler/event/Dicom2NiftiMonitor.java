package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.event;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service.Dicom2NiftiProcess;
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
public class Dicom2NiftiMonitor {
    private static final Logger LOGGER = LoggerFactory.getLogger(Dicom2NiftiMonitor.class);

    @Value("${dicom2nifti_dicom_image_listener_folder}")
    String dicom2niftiDicomImageListenerFolder;

    @Autowired
    Dicom2NiftiProcess dicom2NiftiProcess;

    FileAlterationListener dicom2niftiDicomImagesListener = new FileAlterationListenerAdaptor() {

        @Override
        public void onFileCreate(File file) {
            LOGGER.info("onFileCreate(): new dicom file received: {}", file);
            dicom2NiftiProcess.runConversion(file);
        }

        @Override
        public void onFileDelete(File file) {
            LOGGER.info("onFileDelete(): dicom file deleted: {}", file);
        }

        @Override
        public void onFileChange(File file) {
            LOGGER.info("onFileChange(): dicom file changed: {}", file);
        }
    };

    @PostConstruct
    void init() {
        LOGGER.info("init(): dicom2niftiDicomImageListenerFolder={}", dicom2niftiDicomImageListenerFolder);
        startDicom2NiftiMonitor();
    }

    void startDicom2NiftiMonitor() {
        final String methodName = "startDicom2NiftiMonitor():";

        FileAlterationObserver observer = new FileAlterationObserver(dicom2niftiDicomImageListenerFolder);
        observer.addListener(dicom2niftiDicomImagesListener);
        FileAlterationMonitor monitor = new FileAlterationMonitor(5000);
        monitor.addObserver(observer);

        try {
            LOGGER.info("{} start...", methodName);
            monitor.start();
        } catch (Exception e) {
            LOGGER.error("{} Failed to start. Error: ", methodName, e);
        }
    }
}
