workflow wf_distributed_nexus {
    call taskA
    output {
        taskA.out
    }
}

task taskA {
    String taskName = "taskA"
    String taskOutput = "taskA_output.txt"
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
        cpu: "1"
        memory: "1G"
        disks: "local-disk 10 SSD"
    }
}
