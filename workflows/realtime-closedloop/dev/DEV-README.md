# RealTime-CloseLoop Dev Environment

### VM
`mahmoudilab-dev.priv.bmi.emory.edu`

### Directory
`/labs/mahmoudilab/dev-synergy-rtcl-app`


## Directory Monitor (Listener)
Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/monitor`

* Start monitor
  `$ ./start_monitor.sh`

* Stop monitor
  `$ ./stop_monitor.sh`

## Optimizer
 Optimizer source code is under directory `/labs/mahmoudilab/dev-synergy-rtcl-app/src/optimizer`
If there are any libaries, packages, naming , etc. changes, the Dockerfile `Dockerfile.r2021b` requires modifications accordingly.

## Matlab RT_Prepro Build and Testing in Host Environment
### Compilation
* Go to directory `/labs/mahmoudilab/dev-synergy-rtcl-app/docker/rt_prepro`
* Make sure the PATH in `compile_files.m` is set to
`/labs/mahmoudilab/dev-synergy-rtcl-app/src/rt_prepro`
* Enter Matlab Console by the command 
  
  `$ matlab -nodisplay -nosplash`

or

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
* Copy the `nii` files converted by `dicom2nii` process in the `nii` foler
* Run the command

  `$ ./test_at_host.sh`

If local testing succeeds, move to next step  `Docker build` 

## Docker Build

* Go to diretory `/labs/mahmoudilab/dev-synergy-rtcl-app/src`
* Modify `Dockerfile.r2021b` accordingly when necessary
* Modify `IMAGE_TAG` to a new relase number, for example: `IMAGE_TAG=4.0` in file `src_common_settings.sh` and save the changes
* Build new Docker image in Dev by the script

  `$ ./build_in_background.sh`

  Since the docker build usually takes time, this script will run in the background. 
The build details will output to the log file `build_push_docker.log`
* If build succeeds, the new docker image should be created as `gcr.io/cloudypipelines-com/rt-closedloop` with new tag, 
for example: `gcr.io/cloudypipelines-com/rt-closedloop:4.0`  for `IMAGE_TAG=4.0`