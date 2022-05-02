workflow wf_realtim_closedloop{
  String csvFileName
  call dicom2nifti
  call rtpreproc {
    input: niiInut=dicom2nifti.out
  }
  call csvgen {
    input: InputFile=rtpreproc.out, csvOutput = csvFileName
  }
  output {
     csvgen.out
  }
}

task dicom2nifti {
  File dicomInput
  String niiOutput = "$PWD/nii.tar.gz"
  String dicomDir= "/app/dicom"
  String niiDir= "/app/nii"

  command {
    mkdir -p ${dicomDir} && mkdir -p ${niiDir} && mv ${dicomInput} ${dicomDir}/input.tar.gz
    cd ${dicomDir} && tar -xzf input.tar.gz && rm -f input.tar.gz && cd /app
    time python dicom_pypreprocess.py --filepath ${dicomDir} --savepath ${niiDir}
    tar -czf ${niiOutput} ${niiDir}
    rm -rf ${niiDir}
  }
  output {
    File out="${niiOutput}"
  }
  runtime {
    docker: "gcr.io/cloudypipelines-com/fmri_conversion:1.0"
    continueOnReturnCode: 0
  }
}

task rtpreproc {
  File niiInut
  String procOutput = "$PWD/rtcpre.txt"
  String runScript = "run_RT_Preproc.sh"
  String matlab_ver= "/opt/mcr/v911"
  String appDir = "/home/pgu6/realtime-closedloop"

  command {
    mkdir -p ${appDir} &&  mkdir -p ${appDir}/nii
    mv ${niiInut} ${appDir}/nii/input.tar.gz
    cd ${appDir}/nii tar -xzf input.tar.gz && rm -f input.tar.gz && cd ${appDir}
    time ./run_RT_Preproc.sh ${matlab_ver} ${appDir}/nii
    cat "waiting for ML developer good coding" > ${procOutput}
  }
  output {
    File out="${procOutput}"
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

  command {
    cd /app && mkdir -p csv
    python output_randomcsv.py --savepath /app/csv --savename ${rootDir}/${csvOutput}"
  }
  output {
    File out="${rootDir}/${csvOutput}"
  }
  runtime {
    docker: "gcr.io/cloudypipelines-com/fmri_conversion:1.0"
    continueOnReturnCode: 0
  }
}
