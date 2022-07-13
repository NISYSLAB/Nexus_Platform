package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.event;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.service.DirectoryIOMonitorAction;
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
import java.util.concurrent.ConcurrentHashMap;

@Component
public class DirectoryIOMonitor {
    private static final Logger LOGGER = LoggerFactory.getLogger(DirectoryIOMonitor.class);

    @Value("${monitoring_directory}")
    String monitoringDirectory;

    @Value("${event_on_file_change}")
    boolean eventOnFileChange;

    @Value("${event_on_file_delete}")
    boolean eventOnFileDelete;

    @Value("${event_on_file_create}")
    boolean eventOnFileCreate;

    @Value("${executor_check_interval}")
    int executorCheckInterval;

    @Value("${check_file_stable}")
    boolean checkFileStable;

    ConcurrentHashMap<String, Long> fileHashMap = new ConcurrentHashMap<>();

    @Autowired
    DirectoryIOMonitorAction directoryIOMonitorAction;

    FileAlterationListener fileAlterationListener = new FileAlterationListenerAdaptor() {

        @Override
        public void onFileCreate(File file) {
            if (eventOnFileCreate) {
                LOGGER.info("onFileCreate(): new file received: {}", file);
                takeAction(file);
            }
        }

        @Override
        public void onFileDelete(File file) {
            if (eventOnFileDelete) {
                LOGGER.info("onFileDelete(): file deleted: {}", file);
                takeAction(file);
            }
        }

        @Override
        public void onFileChange(File file) {
            if (eventOnFileChange) {
                LOGGER.info("onFileChange(): file changed: {}", file);
                takeAction(file);
            }
        }
    };

    @PostConstruct
    void init() {
        LOGGER.info("init(): monitoringDirectory={}", monitoringDirectory);
        LOGGER.info("init(): eventOnFileCreate={}", eventOnFileCreate);
        LOGGER.info("init(): eventOnFileChange={}", eventOnFileChange);
        LOGGER.info("init(): eventOnFileDelete={}", eventOnFileDelete);
        LOGGER.info("init(): executorCheckInterval={}", executorCheckInterval);
        LOGGER.info("init(): checkFileStable={}", checkFileStable);

        startDirectoryIOMonitor();
    }

    public void takeAction(File file) {
        if (!checkFileStable) {
            directoryIOMonitorAction.process(file);
            return;
        }
        try {
            waitAndTakeAction(file);
            return;
        } catch (InterruptedException e) {
            fileHashMap.remove(file.getAbsolutePath());
            LOGGER.error("takeAction(): InterruptedException: ", e.getMessage());
        }
    }

    private void waitAndTakeAction(File file) throws InterruptedException {
        final String methodName = "waitAndTakeAction(): ";
        LOGGER.info("{} processing: {}", methodName, file);
        long fileLength = file.length();
        String hashKey = file.getAbsolutePath();
        fileHashMap.putIfAbsent(hashKey, fileLength);

        for (int i = 0; i < 100; i++) {
            Thread.sleep(500);
            long oldLen = fileHashMap.getOrDefault(hashKey, 0l);
            long newLen = file.length();
            if (oldLen != newLen) {
                LOGGER.info("{} Index {}: file is changing: oldLen={}, newLen={}, {}", methodName, i, oldLen, newLen, file.getAbsolutePath());
                fileHashMap.replace(hashKey, newLen);
                Thread.sleep(500);
            } else {
                LOGGER.info("{} Index {}: file is stable: oldLen={}, newLen={}, {}", methodName, i, oldLen, newLen, file.getAbsolutePath());
                directoryIOMonitorAction.process(file);
                fileHashMap.remove(hashKey);
                return;
            }
        }
        directoryIOMonitorAction.process(file);
    }

    void startDirectoryIOMonitor() {
        final String methodName = "startDirectoryIOMonitor():";
        FileAlterationObserver observer = new FileAlterationObserver(monitoringDirectory);
        observer.addListener(fileAlterationListener);
        FileAlterationMonitor monitor = new FileAlterationMonitor(executorCheckInterval);
        monitor.addObserver(observer);

        try {
            LOGGER.info("{} start...", methodName);
            monitor.start();
        } catch (Exception e) {
            LOGGER.error("{} Failed to start. Error: ", methodName, e);
        }
    }
}
