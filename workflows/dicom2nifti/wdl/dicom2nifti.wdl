workflow wf_dicom2nifti {
    call convert
    output {
        convert.out
    }
}

task convert {
    String dockerRef = "us.gcr.io/cloudypipelines-com/dicom2nifti_python:1.1"
    File inputTar
    String result = "output_nifti"
    String cmdOptions
   
    command {
        cd /app
        chmod a+x run_dicom2nifti_convertion.sh
        ./run_dicom2nifti_convertion.sh "${inputTar}" "${result}" "${cmdOptions}"

        cd -
        mv /app/${result}.tar.gz .
    }
    output {
        File out = "${result}.tar.gz"
    }
    runtime {
        docker: "${dockerRef}"
        memory:  "16 GB"
        cpu: "2"
        bootDiskSizeGb: 30
        disks: "local-disk 30 SSD"
        maxRetries: 0
        preemptible: 1
        zones: "us-west4-a us-west4-b us-west4-c us-west3-a us-west3-b us-west3-c us-west2-a us-west2-b us-west2-c us-west1-a us-west1-b us-west1-c us-east4-a us-east4-b us-east4-c us-east1-a us-east1-b us-east1-c us-central1-a us-central1-b us-central1-c us-central1-f"
    }
}


