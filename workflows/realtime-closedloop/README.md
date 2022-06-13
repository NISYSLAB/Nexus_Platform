Matlab script notes:

Compiling the file:

1. Make sure spm12, CanlabCore and Neu3CA-RT library is downloaded and unpacked (You might not have Neu3CA-RT [GitHub link](https://github.com/jsheunis/Neu3CA-RT) now)
2. Go into compile_files.m and change the paths on the top to be the paths to the actual libraries.
3. Run compile_files.m. This script expects the actual preprocessing function `rtPreprocessing_simple_new.m`, and the dACC mask `Wager_ACC_cluster8.nii` to be in the same folder.

Running the compiled file:

The compiled Matlab function expects 3 inputs - full name of trial nii, full name of 4D_pre.nii and full name to the output file from command line. 

An example call would be like:

`./rtPreprocessing_simple_new ~/trial_instance/4D_trial.nii ~/experiment/4D_pre.nii ~/trial_instance/biomarker.csv`

From my understanding, the file 4D_pre.nii is a reference image generated before we run the workflow and would need to be uploaded to the server before we run the workflow.



The compiled program runs slow maybe due to it needs to unpack itself - which consists of the full spm library. But due to the nested nature of the spm library (everything calls spm.m and itself calls a ton of other functions) I currently cannot think of a good way to reduce the size.