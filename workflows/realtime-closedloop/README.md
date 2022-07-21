Matlab script notes:

Compiling the file:

1. Make sure spm12, CanlabCore and Neu3CA-RT library is downloaded and unpacked (You might not have Neu3CA-RT [GitHub link](https://github.com/jsheunis/Neu3CA-RT) now)
2. Go into compile_files.m and change the paths on the top to be the paths to the actual libraries.
3. Run compile_files.m. This script expects the actual preprocessing function `rtPreprocessing_simple_new.m`.

Running the compiled file:

The compiled Matlab function expects 4 inputs - full name of trial nii, full name of 4D_pre.nii, full name of the mask file (wWager...) specific to the subject, and full name to the output file from command line. 

An example call would be like:

`./rtPreprocessing_simple_new ~/trial_instance/4D_trial.nii ~/experiment/4D_pre.nii ~/experiment/wWager_ACC_cluster8_thresholded.nii ~/trial_instance/biomarker.csv`

The file 4D_pre.nii and wWager_ACC_cluster8_thresholded.nii is a reference image generated before realtime workflow and would need to be manually uploaded (via ssh) to the server before we run the workflow.

The size of the compiled program is culled a bit. Hopefully this will make it faster.
