workflow wf_containerA {
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