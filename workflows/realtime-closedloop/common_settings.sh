#!/usr/bin/env bash

## Customized envs
JUMP_NEBULA=nebula.bmi.emory.edu 
DATALINK=datalink.bmi.emory.edu
JUMP_ODDJOBS=oddjobs.bmi.emory.edu
BMI_VM=cromwell-7.priv.bmi.emory.edu
SYNERGY_1_VM=synergy1.priv.bmi.emory.edu
SYNERGY_2_VM=synergy2.priv.bmi.emory.edu
MATLAB_VM=physionetmatlab.priv.bmi.emory.edu
BMI_MATLAB_SYNERGY_VM=mahmoudimatlab.priv.bmi.emory.edu

##BMI_VM=physionet2020.priv.bmi.emory.edu
USER=${BMI_VM_USER}
PASS=${BMI_VM_PASS}
SSH_ID_FILE=/Users/anniegu/.ssh/bmi_ssh_key

export server_ssl_key_store_path=/home/ssl/keystore.p12
export auth_option=BASIC
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/.ssl/gcr-cloudypipeline-com-sa.json

#### function definitions
################################################


