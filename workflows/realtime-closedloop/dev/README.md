# RealTime-CloseLoop Dev Environment

#### VM
`mahmoudilab-dev.priv.bmi.emory.edu`

#### Directory
`/labs/mahmoudilab/dev-synergy-rtcl-app`


## Monitor (Listener)
Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/monitor`

* Start monitor
  `$ ./start_monitor.sh`

* Stop monitor
  `$ ./stop_monitor.sh`

## Optimizer
 Optimizer source code is under directory `/labs/mahmoudilab/dev-synergy-rtcl-app/src/optimizer`
If there are any libaries, packages, naming , etc. changes, the Dockerfile `Dockerfile.r2021b` requires modifications accordingly.

## Matlab RT_Prepro 

The folder is under `/labs/mahmoudilab/dev-synergy-rtcl-app/docker/rt_prepro`

Developers' need to
* Provide all required Matlab scripts, libraries, etc. 
* Compile Matlab Scripts successfully
* Provide test scripts together with necessay data
* Run test scripts successfully, so others are able to run the same scripts and produce the same outputs successfully.
  
### Compilation
* Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/docker/rt_prepro`
* Make sure the PATH in `compile_files.m` is set to
`/labs/mahmoudilab/dev-synergy-rtcl-app/src/rt_prepro` or leave them empty  ( Developers to verify which way is correct ??)
* Enter Matlab Console by the command 
  
  `$ matlab -nodisplay -nosplash`

  or the script

  `$ ./enter_matlab_console.sh`
* Comile Matlab scripts inside the Console by the command 

  `compile_files`
* Two files should be generated if the comilation succeeds
  * `run_RT_Preproc.sh`
  * `RT_Preproc`
  
* Exit the console by the command

  `>> exit`

### Testing Scripts (Developers to provide)

#### Testing in Host VM (Developers to provide)

**Developers: please provide testing scripts to test Matlab binary to make sure it works in the host VM**

Here is the sample of testing script, you can create yours.

* Copy the `nii` files converted by `dicom2nii` process in the `nii` foler
* Run the command

  `$ ./test_at_host.sh`

If local testing succeeds, move to next step  `Docker build` 


## Docker Build

* Go to the directory `/labs/mahmoudilab/dev-synergy-rtcl-app`, modify `IMAGE_TAG` to a new relase number, for example: `IMAGE_TAG=4.0` in file `common_settings.sh` and save the changes

* Go to diretory `/labs/mahmoudilab/dev-synergy-rtcl-app/src`
* Modify `Dockerfile.r2021b` accordingly when necessary

* Build new Docker image in Dev by the script

  `$ ./build_in_background.sh`

  Since the docker build usually takes time, this script will run in the background. 
The build details will output to the log file `build_push_docker.log`
* If build succeeds, the new docker image should be created as `gcr.io/cloudypipelines-com/rt-closedloop` with new tag, 
for example: `gcr.io/cloudypipelines-com/rt-closedloop:4.0`  for `IMAGE_TAG=4.0`


## Workflow Pipeline

Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/workflow`

#### Start Pipeline
`$ ./start_pipeline.sh`

#### Stop Pipeline
`$ ./stop_pipeline.sh`

#### Enter Pipeline
`$ ./enter_pipeline.sh`

type `exit` to exit the pipeline

#### Volume Mounting Options
To make some host directories visible to the container or vice versa, the following volume is mounted in the current directory when the pipeline starts: 
 `mount (host) - /mount (container)`

 #### Testing 

 There is one testing script `test_by_dicom.sh` under directory `/labs/mahmoudilab/dev-synergy-rtcl-app/workflow`. This script can be used to test and troubleshoot the pipeline (dicom2nii - > RT_Prepro --> Optimizer).

Developers can create your testing scripts and supply correct test data such as dicom files, 4D_pre.nii, subject_mask.nii, etc.

## Tips

* `docker build` takes time, during the development, you can copy the binaries, scripts into the docker container by the command [docker cp](https://docs.docker.com/engine/reference/commandline/cp/)

* The docker container name in Dev is called `realtime-closedloop-DEV`. 
* All execution scripts and libraries inside the container are under the directory `/synergy-rtcl-app`, such as `CanlabCore,  dcm2niix,  dicom_pypreprocess.py,  fMRI_Bayesian_optimization.py,  Neu3CA-RT,  output_randomcsv.py,  requirements.txt,  RT_Preproc,  run_RT_Preproc.sh, and   spm12`
* You can also enter the docker container by the command `$ docker exec -it realtime-closedloop-DEV /bin/bash` or by the script `./enter_pipeline.sh` under workflow directory.