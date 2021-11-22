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
public class FmriBiomarkerProcess extends CommonProcess {
    private static final Logger LOGGER = LoggerFactory.getLogger(FmriBiomarkerProcess.class);

    @Value("${fmri_biomarker_model_trained_dataset}")
    String fmriBiomarkerModelTrainedDataset;

    @Value("${start_fmri_biomarker_predict_script}")
    String startFmriBiomarkerPredictScript;

    @Value("${start_fmri_biomarker_feature_activation_map_script}")
    String startFmriBiomarkerFeatureActivationMapScript;

    @PostConstruct
    void inti() {

        LOGGER.info("init(): mountDisk={}", mountDisk);
        LOGGER.info("init(): fmriBiomarkerModelTrainedDataset={}", fmriBiomarkerModelTrainedDataset);
        LOGGER.info("init(): startFmriBiomarkerPredictScript={}", startFmriBiomarkerPredictScript);
        LOGGER.info("init(): startFmriBiomarkerFeatureActivationMapScript={}", startFmriBiomarkerFeatureActivationMapScript);
    }

    /**
     * Calling async method from within the same class would trigger the original method and not the intercepted one.
     * You need to create another service with the async method, and call it from your service.
     *
     * @param dataset
     */
    @Async(NEXUS_SCHEDULER_EXECUTOR)
    public void runPredict(File dataset) {
        final String methodName = getNamingThread() + ": runPredict():";
        LOGGER.info("{} received dataset={}", methodName, dataset);
        String fileNameWithoutExt = UtilHelper.getFileNameWithoutExtension(dataset.getName());
        String mountFolder = createProcessFolder("/predict/" + fileNameWithoutExt);
        String[] commandArr = new String[]{
                "bash",
                startFmriBiomarkerPredictScript,
                fmriBiomarkerModelTrainedDataset,
                dataset.getAbsolutePath()
        };
        execSys(mountFolder, commandArr);
    }

    @Async(NEXUS_SCHEDULER_EXECUTOR)
    public void runFeatureActivationMap(File dataset) {
        final String methodName = getNamingThread() + ": runFeatureActivationMap():";
        LOGGER.info("{} received dataset={}", methodName, dataset);
        String mountFolder = createProcessFolder("/featureactmap/" + dataset.getName());
        String[] commandArr = new String[]{
                "bash",
                startFmriBiomarkerFeatureActivationMapScript,
                fmriBiomarkerModelTrainedDataset,
                dataset.getAbsolutePath()
        };
        execSys(mountFolder, commandArr);
    }
}
