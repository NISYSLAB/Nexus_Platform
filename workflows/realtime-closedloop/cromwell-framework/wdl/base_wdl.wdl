workflow wf_realtime_v1{
  String csvFileName
  File dicomFileInput
  File script
  call run {
    input: dicomInput = dicomFileInput, csvOutput = csvFileName, exeScript = script
  }
  output {
     run.out
  }
}

task run {
  String csvOutput
  File dicomInput
  File exeScript
  String log = "process.log"
  String appDir = "/home/pgu6/realtime-closedloop"
  command {
    chmod a+x ${exeScript} && cp ${exeScript} ${appDir}/exec_realtime_loop.sh
    cd ${appDir}
    ./exec_realtime_loop.sh ${dicomInput} ${csvOutput} > ${log} 2>&1
    cd -
    cp ${appDir}/${log} .
    cp ${appDir}/${csvOutput} .
  }
  output {
    File out = "${csvOutput}"
    File logOut = "${log}"
  }
  runtime {
    docker: "us.gcr.io/cloudypipelines-com/closedloop-preprocess-tools:matlab-1.1"
    continueOnReturnCode: 0
  }
}
