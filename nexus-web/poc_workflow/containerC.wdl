workflow wf_containerC {
    call taskCFileTransfer
    call taskC {
        input: dataInput = taskCFileTransfer.out
    }
    output {
     taskC.out
    }
}
task taskCFileTransfer {
    String taskName = "taskCFileTransfer"
    String taskOutput = "taskCFileTransfer.out"
    String dataInputUrl
    command {
        ##echo "wget -O ${taskOutput} ${dataInputUrl}"
        ##wget -O "${taskOutput}" "${dataInputUrl}"
        echo "curl ${dataInputUrl} > ${taskOutput}"
        curl "${dataInputUrl}/" > ${taskOutput}
        ls -alt "${taskOutput}"
        echo "cat ${taskOutput}"
        cat "${taskOutput}"
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
