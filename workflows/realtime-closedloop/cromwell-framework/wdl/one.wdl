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

task rtpreproc {
  File niiInut
  File matlabScript
  String result = "rtcpre.txt"
  File exeScript
  String appDir = "/home/pgu6/realtime-closedloop"
  String matlab_ver= "/opt/mcr/v911"
  String log = "rtpreproc.log"

  command {
    mkdir -p ${appDir}
    chmod a+x ${exeScript}
    cd ${appDir}
    cp ${exeScript} ./exec_rtpreproc.sh
    ./exec_rtpreproc.sh ${matlabScript} ${matlab_ver} ${niiInut} ${result} > ${log} 2>&1
    cd -
    ## TODO:need to find out the output of this process
    cp ${appDir}/${result} .
    cp ${appDir}/${log} .

  }
  output {
    File out = "${result}"
    File logOut = "${log}"
  }
  runtime {
    docker: "us.gcr.io/cloudypipelines-com/closedloop-preprocess-tools:matlab-1.0"
    continueOnReturnCode: 0
  }
}

task csvgen {
  File InputFile
  String csvOutput
  String rootDir = "$PWD"
  String log = "csvgen.log"

  command {
    cd /app && mkdir -p csv
    python output_randomcsv.py --savepath /app/csv --savename ${rootDir}/${csvOutput}" > ${log} 2>&1
  }
  output {
    File out="${rootDir}/${csvOutput}"
  }
  runtime {
    docker: "gcr.io/cloudypipelines-com/fmri_conversion:1.0"
    continueOnReturnCode: 0
  }
}
