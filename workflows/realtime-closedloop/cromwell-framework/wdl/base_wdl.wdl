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
  File dicomInput
  File exeScript
  String csvOutput
  String niiOutput = "nii.tar.gz"
  String log = "process.log"
  String appDir = "/home/pgu6/realtime-closedloop"
  command {
    chmod a+x ${exeScript} && cp ${exeScript} ${appDir}/exec_realtime_loop.sh
    cd ${appDir}
    ./exec_realtime_loop.sh ${dicomInput} ${csvOutput} > ${log} 2>&1
    cd -
    cp ${appDir}/${log} . && cp ${appDir}/${csvOutput} . && cp ${appDir}/${niiOutput} .
  }
  output {
    File out = "${csvOutput}"
    File logOut = "${log}"
    File niiOut = "${niiOutput}"
  }
  runtime {
    docker: "us.gcr.io/cloudypipelines-com/closedloop-preprocess-tools:matlab-1.1"
    continueOnReturnCode: 0
  }
}
