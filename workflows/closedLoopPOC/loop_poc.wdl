
task stepA {
  File stepAInput
  String result = "stepA.txt"
  Int value = read_int(stepAInput)
  command {
    echo "stepA started ..."
    echo "Content of stepAInput: ${stepAInput}"
    echo $(( ${value} + 1 )) > ${result}
    echo "stepA ended ..."
  }
  output {
    File out = "${result}"
  }
  runtime {
    docker: "ubuntu:latest"
    zones: "us-east1-d us-west1-b"
  }
}

task stepB {
  File stepBInput
  String result = "stepB.txt"
  Int value = read_int(stepBInput)
  command {
    echo "stepB started ..."
    echo "Content of stepBInput: ${stepBInput}"
    echo $(( ${value} + 1 )) > ${result}
    echo "stepB ended ..."
  }
  output {
    File out = "${result}"
  }
  runtime {
    docker: "ubuntu:latest"
    zones: "us-east1-d us-west1-b"
  }
}

task stepDecision {
  File initInput
  ##File? previousInput
  Int value = read_int(initInput)
  Int maxValue = 10
  ##??
  Boolean continueOrNot = value < maxValue
  ##File dataRef
  String decisionResult = "decision.txt"
  command {
    echo "stepDecision started ..."
    echo "Content of initInput: ${initInput}"
    echo "trueOrFalse : ${continueOrNot}"
    echo "${continueOrNot}" > ${decisionResult}
    echo "stepDecision ended ..."
  }
  output {
    File dataFile = "${initInput}"
    File decisionFile = "${decisionResult}"
  }
  runtime {
    docker: "ubuntu:latest"
    zones: "us-east1-d us-west1-b"
  }
}

workflow wf_loop {
  File dataInput
  call stepA {
    input: stepAInput = dataInput
  }
  call stepB {
    input: stepBInput = stepA.out
  }

  call stepDecision {
    input: initInput = stepB.out
  }

  output {
     stepDecision.dataFile
     stepDecision.decisionFile
  }
}

