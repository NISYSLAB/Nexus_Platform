workflow wf_fmri_biomarker {
    File trainData
    File testData
    File monitorScript
    call modelTraining {
        input: trainDataIn = trainData, testDataIn = testData, usageMonitor = monitorScript
    }
    call modelPredict {
        input: trainedModelData=modelTraining.out, testDataIn = testData, usageMonitor = monitorScript
    }
    call modelFeatureActivationMap {
        input: trainedModelData=modelPredict.out, testDataIn = testData, usageMonitor = monitorScript
    }
   
    output {
        modelFeatureActivationMap.out
    }
}

task modelTraining {
    File trainDataIn
    File testDataIn
    String version
    File execScript
    String outputs = "trained_model"
    String rootDir = "$PWD"
    File usageMonitor
    command {
        
        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh
        
        echo "rootDir=${rootDir}"
        ####
        mv ${execScript}  /root/work/run_model_training.sh
        cd /root/work
        chmod a+x run_model_training.sh
        echo "./run_model_training.sh ${trainDataIn} ${testDataIn} ${version} ${outputs}"
        ./run_model_training.sh ${trainDataIn} ${testDataIn} ${version} ${outputs}
        ##mv ${outputs}.tar.gz ${rootDir}/
    }
    output {
        File out="${outputs}.tar.gz"
    }
    runtime {
        docker: "gcr.io/cloudypipelines-com/fmri-multiclass:1.0"
        memory:  "28 GB"
        cpu: "4"
        bootDiskSizeGb: 30
        disks: "local-disk 15 SSD"
        maxRetries: 1
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
    String outputs = "trained_model"
    String rootDir = "$PWD"
    File usageMonitor
    command {
        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh
        echo "rootDir=${rootDir}"
        ####

        mv ${execScript}  /root/work/run_model_predict.sh
        cd /root/work
        chmod a+x run_model_predict.sh
        echo "./run_model_predict.sh ${trainedModelData} ${testDataIn} ${version} ${outputs}"
        ./run_model_predict.sh ${trainedModelData} ${testDataIn} ${version} ${outputs}
        ## mv ${outputs}.tar.gz ${rootDir}/
    }
    output {
        File out="${outputs}.tar.gz"
    }
    runtime {
        docker: "gcr.io/cloudypipelines-com/fmri-multiclass:1.0"
        memory:  "28 GB"
        cpu: "4"
        bootDiskSizeGb: 30
        disks: "local-disk 15 SSD"
        maxRetries: 1
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
    String outputs = "trained_model"
    String rootDir = "$PWD"
    File usageMonitor
    command {
        mv ${usageMonitor} ./usage_monitor.sh
        chmod a+x ./usage_monitor.sh
        ./usage_monitor.sh
        echo "rootDir=${rootDir}"
        ####

        mv ${execScript}  /root/work/run_model_feature_activation_map.sh
        cd /root/work
        chmod a+x run_model_feature_activation_map.sh
        echo "./run_model_feature_activation_map.sh ${trainedModelData} ${testDataIn} ${version} ${outputs}"
        ./run_model_feature_activation_map.sh ${trainedModelData} ${testDataIn} ${version} ${outputs}
        ##mv ${outputs}.tar.gz ${rootDir}/
    }
    output {
        File out="${outputs}.tar.gz"
    }
    runtime {
        docker: "gcr.io/cloudypipelines-com/fmri-multiclass:1.0"
        memory:  "28 GB"
        cpu: "4"
        bootDiskSizeGb: 30
        disks: "local-disk 15 SSD"
        maxRetries: 1
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

