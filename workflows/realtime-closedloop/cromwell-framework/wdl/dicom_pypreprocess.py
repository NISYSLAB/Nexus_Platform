"""
Using pyDicom package to read all dcm files in a folder specified by --filepath and convert each of them into a nii file
Outputs a nifty file in --savepath
Keeps track of already converted files in the folder with converted.log and will not generate output for those files.
So assuming each call is in one trial this can separate one folder of dicom into different folders of nii files for each trial.
Arguments:
    --filepath - the path of the input
    --savepath - the path of the output
"""

import os
import argparse
import pydicom as dicom
import numpy as np
import sys, getopt
import nibabel as nib # the library used for handling nifty files
import dicom_numpy

############## Arguments and Hyperparameter selection ############################

full_path, filename = os.path.split(os.path.abspath(__file__))

base_path=os.path.abspath(os.path.dirname(__file__))
parser = argparse.ArgumentParser(description='Arguments for model training')
parser.add_argument('--filepath', type=str, default= None, help="Directory of the dicom files")
parser.add_argument('--savepath', type=str, default= None, help="Directory of the output")
# parser.add_argument('--savename', type=str, default= None, help="Filename of the output")
# parser.add_argument('--header',type=str, default= None, help="The header in front of dicom filenames like xxx001.dcm, xxx002.dcm")

args = parser.parse_args()
file_path = args.filepath
save_path = args.savepath
# save_name = args.savename
# header = args.header

####################################################################################

def loadPreprocess(filepath,savepath):
    """
    :param filepath: file path of dcm files
    :param savepath: path to the output
    :return: None
    """
    old_dir = os.getcwd()
    os.chdir(filepath)
    # files = os.listdir()
    # change it to read all files in the folder
    # files_dicom = [filename + '{:0>3}'.format(count) + '.dcm'] # list containing filenames
    # while (filename + '{:0>3}'.format(count+1) + '.dcm') in files: # filename002.dcm...
    #     count +=1
    #     files_dicom.append(filename + '{:0>3}'.format(count) + '.dcm')
    allfile = os.listdir()
    files_dicom = [file for file in allfile if '.dcm' in file]
    files_dicom.sort()
    # log module for keeping track of converted files
    logname = 'converted.log'
    if os.path.exists(logname):
        with open(logname,'r') as f:
            converted = f.readlines()
    else:
        converted = []
    files_dicom = [file for file in files_dicom if (file+'\n') not in converted]

    # dicom_list = [] # list containing dicom files
    # for i in range(count):
    #     dicom_list.append(dicom.dcmread(files_dicom[i]))
    # dicom_combined = dicom_numpy.combine_slices(dicom_list)
    # # dicom_numpy neatly returns the affine for nifty, but its very stupid when only one slice is given because its missing one dimension
    # # why am I fixing this for their code...
    # if dicom_combined[1][2,2] == 0: # fix the slice interval to be the info contained in dicom file
    #     dicom_combined[1][2,2] = dicom_list[0].SliceThickness
    # nifty_image = nib.nifti1.Nifti1Image(dicom_combined[0],dicom_combined[1])

    # convert each dicom to nifty
    for file in files_dicom:
        dcm = dicom.dcmread(file)
        dcm_affine = dicom_numpy.combine_slices([dcm,])
        dcm_affine[1][2,2] = dcm.SliceThickness
        nifty_image = nib.nifti1.Nifti1Image(dcm_affine[0],dcm_affine[1])
        os.chdir(old_dir)
        nib.save(nifty_image,os.path.join(savepath,(file[:-4] + '.nii')))
        converted.append(file+'\n')
        os.chdir(filepath)
    with open(logname,'w') as f:
        f.writelines(converted)

    return None


def main():
    # main
    loadPreprocess(file_path,save_path)

if __name__ == "__main__":
    main()
