workflow wf_distributed_nexus {
    call transferC
    call taskC {
        input: dataInput = transferC.out
    }
    output {
     taskC.out
    }
}
task transferC {
    String taskName = "transferC"
    String taskOutput = "transferC.out"
    String dataInput
    command {
    
        sleep 90
        /app/util_curl.sh "${dataInput}" "${taskOutput}"
        
        echo "" >> "${taskOutput}"
        echo $(date -u +"%m/%d/%Y:%H:%M:%S") >> "${taskOutput}"
        echo "${taskName} started" >> "${taskOutput}"
        sleep 3
        echo "${taskName} ended" >> "${taskOutput}"
        echo $(date -u +"%m/%d/%Y:%H:%M:%S") >> "${taskOutput}"

    }
    output {
        File out="${taskOutput}"
    }
    runtime {
        docker: "us.gcr.io/cloudypipelines-com/nexus-utils:1.0"
        cpu: "1"
        memory: "1G"
        disks: "local-disk 10 SSD"
    }
}

task taskC {
    String taskName = "taskC"
    String taskOutput = "taskC.out"
    File dataInput
    command {
        cat ${dataInput} > "${taskOutput}"
        echo "" >> "${taskOutput}"
        echo $(date -u +"%m/%d/%Y:%H:%M:%S") >> "${taskOutput}"
        echo "${taskName} started" >> "${taskOutput}"
        sleep 4
        echo "${taskName} ended" >> "${taskOutput}"
        echo $(date -u +"%m/%d/%Y:%H:%M:%S") >> "${taskOutput}"

    }
    output {
        File out="${taskOutput}"
    }
    runtime {
        docker: "us.gcr.io/cloudypipelines-com/nexus-utils:1.0"
        cpu: "1"
        memory: "1G"
        disks: "local-disk 10 SSD"
    }
}
