workflow wf_containerB {
    call taskB
    output {
     taskB.out
    }
}

task taskB {
    String taskName = "taskB"
    String taskOutput = "taskB_output.txt"
    File dataInput
    command {
        cat ${dataInput} > "${taskOutput}"
        echo "" >> "${taskOutput}"
        echo $(date -u +"%m/%d/%Y:%H:%M:%S") >> "${taskOutput}"
        echo "${taskName} started" >> "${taskOutput}"
        echo $(top -1 -b -n 1) >> "${taskOutput}"
        echo $(df -h) "${taskOutput}"
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