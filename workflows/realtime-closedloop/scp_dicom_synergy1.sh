#!/bin/bash

function tarfile() {
    local dir=$1
    echo "start process $dir"
    cd $HOME/Downloads/$dir
    echo "files in Current Dir: $PWD"
    ls
    rm -rf *.tar.gz
    local newname="${dir/OneDrive/dcm}"
    tar -czvf ${newname}.tar.gz *.dcm
    echo "files in Current Dir: $PWD"
    ls
    mv ${newname}.tar.gz $HOME/Downloads/
    cd $HOME/Downloads

    scp_to_vm $HOME/Downloads/${newname}.tar.gz ${dest}/${newname}.tar.gz ${BMI_SYNERGY_1_VM}

}

tarfile OneDrive_1_5-6-2022
## tarfile OneDrive_2_5-6-2022
## tarfile OneDrive_3_5-6-2022

exit 0
src1=/Users/anniegu/Downloads/OneDrive_1_5-6-2022.tar.gz
src2=/Users/anniegu/Downloads/OneDrive_2_5-6-2022.tar.gz
src3=/Users/anniegu/Downloads/OneDrive_3_5-6-2022.tar.gz

dest=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/dcm

time scp_to_vm $src1 $dest/OneDrive_1_5-6-2022.tar.gz $BMI_SYNERGY_1_VM
time scp_to_vm $src2 $dest/OneDrive_2_5-6-2022.tar.gz $BMI_SYNERGY_1_VM
time scp_to_vm $src3 $dest/OneDrive_3_5-6-2022.tar.gz $BMI_SYNERGY_1_VM
