## Matlab Scripts Notes

### Compilation

1. Make sure ```spm12```, ```CanlabCore``` and ```Neu3CA-RT``` library is downloaded and unpacked.
(You might not have Neu3CA-RT [GitHub link](https://github.com/jsheunis/Neu3CA-RT) now)
2. Edit  ```compile_files.m``` and change the paths on the top to be the paths to the actual libraries.
3. Compile matlab scripts
   * Compile at your local development which has Matlab compiler, Run ```compile_files.m```. This script expects the actual preprocessing function `rtPreprocessing_simple_new.m`, and the dACC mask `Wager_ACC_cluster8.nii` to be in the same folder.
   * Compile at BMI VM `mahmoudimatlab.priv.bmi.emory.edu`, go to `/home/pgu6/realtime-closedloop` folder
     * Type ```$ matlab -nodisplay -nosplash``` to enter  Matlab Console
     * ```>> cd /home/pgu6/realtime-closedloop```
     * ```>> compile_files```
     * If the comilation succeeds, it generates following messages
   
```
Parsing file "/home/pgu6/realtime-closedloop/RT_Preproc.m"
(referenced from command line).
Generating file "/home/pgu6/realtime-closedloop/readme.txt".
Generating file "run_RT_Preproc.sh".
```
4. Copy Binaries/Scripts to ```/labs/mahmoudilab/synergy-rt-preproc```, run ```$ ./copy_binaries.sh```

### Execution Command Line

The compiled Matlab function expects 3 inputs:

* full name of trial nii 
* full name of 4D_pre.nii 
* full name to the output file from command line 

An example call would be like:

`./RT_Preproc 
~/trial_instance/4D_trial.nii 
~/experiment/4D_pre.nii 
~/experiment/wWager_ACC_cluster8_thresholded.nii 
~/trial_instance/objective.csv`

From my understanding, the file `4D_pre.nii` is a reference image generated before we run the workflow and would need to be uploaded to the server before we run the workflow.

The compiled program runs slow maybe due to it needs to unpack itself - which consists of the full spm library. But due to the nested nature of the spm library (everything calls spm.m and itself calls a ton of other functions) I currently cannot think of a good way to reduce the size.

### Build Docker images
Logon to VM `synergy1.priv.bmi.emory.edu`
Go to folder `/home/pgu6/app/listener/fMri_realtime/listener_execution/docker`, run
```angular2html
$ ./build_push_docker.sh
```