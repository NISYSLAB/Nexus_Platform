task modelTraining {
    File trainData
    File testData
    String version
    File execScript
    String outputs = "trained_model"
    command {
        mv ${execScript}  /root/work/run_model_training.sh
        cd /root/work
        chmod a+x run_model_training.sh
        echo "./ run_model_training.sh ${trainData} ${testData} ${version} ${outputs}"
       ./run_model_training.sh ${trainData} ${testData} ${version} ${outputs}
    }
    output {
        File out="${outputs}.tar.gz"
    }
    runtime {
        docker: "gcr.io/cloudypipelines-com/fmri-multiclass:1.0"
        memory:  "16 GB"
        cpu: "4"
        bootDiskSizeGb: 30
        disks: "local-disk 15 SSD"
        maxRetries: 1
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
        ##zones: "us-east1-b us-east1-c us-east1-d us-central1-a us-central1-b us-central1-c us-central1-f us-east4-a us-east4-b us-east4-c us-west1-a us-west1-b us-west1-c us-west2-a us-west2-b us-west2-c"
    }
}

workflow wf_fmri_biomarker {
    call modelTraining
   
    output {
        modelTraining.out
    }
}