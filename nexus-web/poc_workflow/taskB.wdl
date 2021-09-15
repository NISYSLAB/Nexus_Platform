workflow wf_distributed_nexus {
    call transferB
    call taskB {
        input: dataInput = transferB.out
    }
    output {
     taskB.out
    }
}

task transferB {
    String taskName = "transferB"
    String taskOutput = "transferB.out"
    String dataInput
    command {
        
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
    }
}

task taskB {
    String taskName = "taskB"
    String taskOutput = "taskB.out"
    File dataInput
    command {
        cat ${dataInput} > "${taskOutput}"
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
    }
}
