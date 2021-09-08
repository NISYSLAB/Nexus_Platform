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
        ##echo "wget -O ${taskOutput} ${dataInput}"
        ##wget -O "${taskOutput}" "${dataInput}"
        echo "curl ${dataInput} > ${taskOutput}"
        curl ${dataInput} > ${taskOutput}
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
        docker: "ubuntu:21.04"
    }
}
