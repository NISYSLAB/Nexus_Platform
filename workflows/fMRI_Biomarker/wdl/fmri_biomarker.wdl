workflow wf_fmri_biomarker {
    File trainData
    File testData
    File monitorScript
    String dockerRef = "gcr.io/cloudypipelines-com/fmri_biomarker:1.3"
    call modelTraining {
        input:
            trainDataIn = trainData,
            testDataIn = testData,
            usageMonitor = monitorScript,
            dockerInUse = dockerRef
    }
    call modelPredict {
        input:
            trainedModelData = modelTraining.out,
            testDataIn = testData,
            usageMonitor = monitorScript,
            dockerInUse = dockerRef
    }
    call modelFeatureActivationMap {
        input:
            trainedModelData = modelTraining.out,
            testDataIn = testData,
            usageMonitor = monitorScript,
            dockerInUse = dockerRef
    }

    call merge {
        input:
            trainedModelData = modelTraining.out,
            trainedSavedResults = modelTraining.results,
            predictSavedResults = modelPredict.results,
            actSavedResults = modelFeatureActivationMap.results
    }

    output {
        merge.out
    }
}

task modelTraining {
    File trainDataIn
    File testDataIn
    String version
    File execScript
    String trainedModelOutputs = "trained_model"
    String savedResults = "trained_model_saved_results"
    File usageMonitor
    String dockerInUse
    command {

        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh

        ####
        mv ${execScript}  /root/work/run_model_training.sh
        cd /root/work
        chmod a+x run_model_training.sh
        echo "./run_model_training.sh ${trainDataIn} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}"
        ./run_model_training.sh ${trainDataIn} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}

        cd -
        mv /root/work/${trainedModelOutputs}.tar.gz .
        mv /root/work/${savedResults}.tar.gz .
    }
    output {
        File out = "${trainedModelOutputs}.tar.gz"
        File results = "${savedResults}.tar.gz"
    }
    runtime {
        docker: "${dockerInUse}"
        memory:  "16 GB"
        cpu: "2"
        bootDiskSizeGb: 30
        disks: "local-disk 30 SSD"
        maxRetries: 0
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

task modelPredict {
    File trainedModelData
    File testDataIn
    String version
    File execScript
    String trainedModelOutputs = "trained_model"
    String savedResults = "predict_saved_results"
    File usageMonitor
    String dockerInUse
    command {
        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh

        ####

        mv ${execScript}  /root/work/run_model_predict.sh
        cd /root/work
        chmod a+x run_model_predict.sh
        echo "./run_model_predict.sh ${trainedModelData} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}"
        ./run_model_predict.sh ${trainedModelData} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}

        cd -
        mv /root/work/${savedResults}.tar.gz .
    }
    output {
        File results = "${savedResults}.tar.gz"
    }
    runtime {
        docker: "${dockerInUse}"
        memory:  "16 GB"
        cpu: "2"
        bootDiskSizeGb: 30
        disks: "local-disk 30 SSD"
        maxRetries: 0
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

task modelFeatureActivationMap {
    File trainedModelData
    File testDataIn
    String version
    File execScript
    String trainedModelOutputs = "trained_model"
    String savedResults = "activation_saved_results"
    File usageMonitor
    String dockerInUse
    command {
        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh

        ####

        mv ${execScript}  /root/work/run_model_feature_activation_map.sh
        cd /root/work
        chmod a+x run_model_feature_activation_map.sh
        echo "./run_model_feature_activation_map.sh ${trainedModelData} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}"
        ./run_model_feature_activation_map.sh ${trainedModelData} ${testDataIn} ${version} ${trainedModelOutputs} ${savedResults}

        cd -
        mv /root/work/${savedResults}.tar.gz .
    }
    output {
        File results = "${savedResults}.tar.gz"
    }
    runtime {
        docker: "${dockerInUse}"
        memory:  "16 GB"
        cpu: "2"
        bootDiskSizeGb: 30
        disks: "local-disk 30 SSD"
        maxRetries: 0
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

task merge {
    File trainedModelData
    File trainedSavedResults
    File predictSavedResults
    File actSavedResults
    String outputs = "fmri_biomarker_outputs"

    command {
        echo "Start compressing files:"
        mkdir -p /app
        mv ${trainedModelData} /app/trainedModelData.tar.gz || echo "Failed: mv ${trainedModelData} /app/trainedModelData.tar.gz, OK to move on"
        mv ${trainedSavedResults} /app/trainedSavedResults.tar.gz || echo "Failed: mv ${trainedSavedResults} /app/trainedSavedResults.tar.gz, OK to move on"
        mv ${predictSavedResults} /app/predictSavedResults.tar.gz || echo "Failed: mv ${predictSavedResults} /app/predictSavedResults.tar.gz, OK to move on"
        mv ${actSavedResults} /app/actSavedResults.tar.gz || echo "Failed: mv ${actSavedResults} /app/actSavedResults.tar.gz, OK to move on"
        cd /app
        ls
        echo "tar -cvzf ${outputs}.tar.gz ./*.tar.gz"
        tar -cvzf ${outputs}.tar.gz ./*.tar.gz || echo "Failed: tar -cvzf ${outputs}.tar.gz ./*.tar.gz"
        echo "rm -rf trainedModelData.tar.gz trainedSavedResults.tar.gz predictSavedResults.tar.gz actSavedResults.tar.gz"
        rm -rf trainedModelData.tar.gz trainedSavedResults.tar.gz predictSavedResults.tar.gz actSavedResults.tar.gz || echo "Failed: rm -rf trainedModelData.tar.gz trainedSavedResults.tar.gz predictSavedResults.tar.gz actSavedResults.tar.gz"
        echo "ls -alt"
        ls -alt
        cd -
        mv /app/${outputs}.tar.gz .
    }
    output {
        File out = "${outputs}.tar.gz"
    }
    runtime {
        docker: "ubuntu:20.04"
        memory:  "4 GB"
        cpu: "2"
        bootDiskSizeGb: 30
        disks: "local-disk 30 SSD"
        maxRetries: 0
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

