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
        echo "wget -O ${taskOutput} ${dataInput}"
        wget -O ${taskOutput} ${dataInput}
        ls -alt ${taskOutput}
        echo "cat ${taskOutput}"
        cat ${taskOutput}
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
        docker: "us.gcr.io/cloudypipelines-com/nexus-filetransfer:1.0"
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
        docker: "ubuntu:21.04"
    }
}
