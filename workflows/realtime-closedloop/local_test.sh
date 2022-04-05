


## Error message: ./RT_Preproc: error while loading shared libraries: libmwlaunchermain.so: cannot open shared object file: No such file or directory

## At physionetmatlab.priv.bmi.emory.edu, the Matlab R2022a software & associated files should all be located in
## /usr/local/MATLAB/R2022a/ and its subdirectories;
INSTALLATION_ROOT=/usr/local/MATLAB/R2021b
MCR_NUM=v911
MCRROOT=${INSTALLATION_ROOT}
## MCRROOT=/opt/mcr/${MCR_NUM}
APP_ROOT=$PWD

export LD_PRELOAD=${MCRROOT}/bin/glnxa64/glibc-2.17_shim.so
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/runtime/glnxa64:${MCRROOT}/bin/glnxa64:${MCRROOT}/sys/os/glnxa64:${MCRROOT}/extern/bin/glnxa64:${APP_ROOT}/spm12:${APP_ROOT}/CanlabCore
export PATH=${PATH}:${APP_ROOT}/spm12:${APP_ROOT}/CanlabCore

echo "LD_PRELOAD=$LD_PRELOAD"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "PATH=$PATH"

echo "Run: ./RT_Preproc('/home/login/nii')"
echo "time ./RT_Preproc $PWD/nii"
time ./RT_Preproc $PWD/nii