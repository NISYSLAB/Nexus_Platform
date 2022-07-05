package edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.cron;

import edu.emory.sharmalab.cloudypipelines.nexus.nexusscheduler.UtilHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;


import javax.annotation.PostConstruct;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Component
public class NexusScheduler {
    private static final Logger LOGGER = LoggerFactory.getLogger(NexusScheduler.class);
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private Environment environment;

    @PostConstruct
    void init() {

        LOGGER.info("init(): nexus_monitoring_cron={}", environment.getProperty("nexus_monitoring_cron"));
        LOGGER.info("init(): fmri_biomarker_model_train_cron={}", environment.getProperty("fmri_biomarker_model_train_cron"));

    }

    //@Scheduled(cron = "${nexus_monitoring_cron}")
    public void monitoring() {
        final String methodName = "monitoring():";
        LOGGER.info("{} run at: {}", methodName, dateFormat.format(new Date()));
    }

    /**
    @Scheduled(cron = "${fmri_biomarker_model_train_cron}")
    public void fmriBiomarkerModelTrainMonitoring() {
        final String methodName = "fmriBiomarkerModelTrainMonitoring():";
        LOGGER.info("{} run at: {}", methodName, dateFormat.format(new Date()));
        // collect datasets filse in *.tar.gz format
        List<File> srcDatasets = UtilHelper.listFilesEndsWith(fmriBiomarkerModelTrainDatasetSrcFolder, ".tar.gz");
        LOGGER.info("{} found {} files, srcDatasets={}", methodName, srcDatasets.size(), srcDatasets);
        // which files not processed yet
        // process

    }
    */
}
