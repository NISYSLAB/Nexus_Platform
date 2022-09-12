# RealTime ClosedLoop Dev Environment

#### VM
  `mahmoudilab-dev.priv.bmi.emory.edu`

#### Scripting and Execution Directory
  `/labs/mahmoudilab/dev-synergy-rtcl-app`

## Directory Listener( Monitor )

#### Listening directory
  `/labs/mahmoudilab/synergy_remote_data1/DEV-emory_siemens_scanner_in_dir/csv`

#### Start listener (monitor)
  Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/monitor`

  `$ ./start_monitor.sh`

#### Stop listener (monitor)
Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/monitor`

  `$ ./stop_monitor.sh`

## Application Components

### 1. dicom2nii
  The supporting scripts are under the directory `/labs/mahmoudilab/dev-synergy-rtcl-app/src/dicom2nii`

#### Start dicom2nii container
  `$ ./start_dicom2nii.sh`

The name of the instance is `dicom2nii-DEV`, you can enter the container 
by the command:

`$ docker exec -it dicom2nii-DEV /bin/bash`

#### Stop dicom2nii container
  `$./stop_dicom2nii.sh`

#### Testing 
  `unit_test_docker.sh` can be an example to test dicom2nii container, `dicom` and `nii` folders 
are mounted  to `/synergy-rtcl-app/dicom` and `/synergy-rtcl-app/nii`
inside the container.

**Developers** : Please create your testing scripts for your changes together with 
required data files, so others can run your scripts successfully!!!

### 2. Optimizer
 Optimizer source code is under directory `/labs/mahmoudilab/dev-synergy-rtcl-app/src/optimizer`
If there are any libaries, packages, naming , etc. changes, the Dockerfile `Dockerfile.r2021b` requires modifications accordingly.

### 3. Matlab RT_Prepro 

The folder is under `/labs/mahmoudilab/dev-synergy-rtcl-app/docker/rt_prepro`

Developers' need to
* Provide all required Matlab scripts, libraries, etc. 
* Compile Matlab Scripts successfully
* Provide test scripts together with necessay data
* Run test scripts successfully, so others are able to run the same scripts and produce the same outputs successfully.
  
#### Compilation
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

#### Testing Scripts (Developers to provide)

#### Testing in Host VM (Developers to provide)

**Developers: please provide testing scripts to test Matlab binary to make sure it works in the host VM**

Here is the sample of testing script, you can create yours.

* Copy the `nii` files converted by `dicom2nii` process in the `nii` foler
* Run the command

  `$ ./test_at_host.sh`

If local testing succeeds, move to next step  `Docker build` 

## Pipeline Docker Build

* Go to the directory `/labs/mahmoudilab/dev-synergy-rtcl-app`, modify `IMAGE_TAG` to a new relase number, for example: `IMAGE_TAG=4.0` in file `common_settings.sh` and save the changes
* Go to diretory `/labs/mahmoudilab/dev-synergy-rtcl-app/src`
* Modify `Dockerfile.r2021b` accordingly when necessary
* Build new Docker image in Dev by the script

  `$ ./build_in_background.sh`

  Since the docker build usually takes time, this script will run in the background. 
The build details will output to the log file `build_push_docker.log`
* If build succeeds, the new docker image should be created as `gcr.io/cloudypipelines-com/rt-closedloop` with new tag, 
for example: `gcr.io/cloudypipelines-com/rt-closedloop:4.0`  for `IMAGE_TAG=4.0`

## Pipeline Start, Stop, and Test

Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/workflow`

#### Start pipeline
`$ ./start_pipeline.sh`

#### Stop pipeline
`$ ./stop_pipeline.sh`

#### Enter pipeline
`$ ./enter_pipeline.sh`

type `exit` to exit the pipeline

#### Volume Mounting Options
To make some host directories visible to the container or vice versa, the following volume is mounted in the current directory when the pipeline starts: 
 `mount (host) - /mount (container)`

#### Testing 

* Test by supplying dicom tar.gz file

  `$ ./test_by_dicom.sh`

* Test by supplying csv configuration file

  `$ ./test_by_csv_config.sh`  ( under development )

**Developers**  Please create your testing scripts and supply correct test data such as dicom files, 4D_pre.nii, subject_mask.nii, etc., thus others can run your scripts successfully!!!

## Tips

* `docker build` takes time, during the development, you can copy the binaries, scripts into the docker container by the command [docker cp](https://docs.docker.com/engine/reference/commandline/cp/)
* The docker container name in Dev is called `realtime-closedloop-DEV`. 
* All execution scripts and libraries inside the container are under the directory `/synergy-rtcl-app`, such as `CanlabCore,  dcm2niix,  dicom_pypreprocess.py,  fMRI_Bayesian_optimization.py,  Neu3CA-RT,  output_randomcsv.py,  requirements.txt,  RT_Preproc,  run_RT_Preproc.sh, and   spm12`
* You can also enter the docker container by the command `$ docker exec -it realtime-closedloop-DEV /bin/bash` or by the script `./enter_pipeline.sh` under workflow directory.