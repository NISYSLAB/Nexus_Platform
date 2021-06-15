workflow wf_fmri_biomarker_predict {
    File trainData
    File testData
    File monitorScript
    String dockerRef = "gcr.io/cloudypipelines-com/fmri_biomarker:1.3"

    call modelPredict {
        input:
            testDataIn = testData,
            usageMonitor = monitorScript,
            dockerInUse = dockerRef
    }

    output {
        modelPredict.results
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



