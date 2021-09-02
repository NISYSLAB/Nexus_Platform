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
    String taskOutput = "taskC_output.out"
    String dataInputUrl
    command {

        wget -O ${taskOutput} ${dataInputUrl}
        //curl https://pipelineapi.org:9555/api/download/workflows/f5d9492d-e01a-4151-a756-f64abef82a7c/requests/cb378bef-96d4-4f49-ad46-8201be6a9e4a > cp.out
        //wget -O test_ouput.out https://pipelineapi.org:9555/api/download/workflows/f5d9492d-e01a-4151-a756-f64abef82a7c/requests/cb378bef-96d4-4f49-ad46-8201be6a9e4a
        
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
    String taskOutput = "taskC_output.txt"
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
