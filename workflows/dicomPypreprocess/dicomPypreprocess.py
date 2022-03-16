"""
Using pyDicom package to read dicom files.
Outputs a nifty file
"""
import os

import pydicom as dicom
import numpy as np
import sys, getopt
# import matplotlib.pyplot as plt # for debugging
import nibabel as nib # the library used for handling nifty files
import dicom_numpy

def loadPreprocess(filepath,filename):
    """
    :param filepath: file path of dcm files
    :param filename: file name of the series - filename001.dcm, filename002.dcm ....
    :return: returns the nifty image if further processing in python is desired
    creates a nifty file named filename.nii
    """
    os.chdir(filepath)
    count = 1
    files = os.listdir()
    files_dicom = [filename + '{:0>3}'.format(count) + '.dcm'] # list containing filenames
    while (filename + '{:0>3}'.format(count+1) + '.dcm') in files: # filename002.dcm...
        count +=1
        files_dicom.append(filename + '{:0>3}'.format(count) + '.dcm')
    dicom_list = [] # list containing dicom files
    for i in range(count):
        dicom_list.append(dicom.dcmread(files_dicom[i]))
    dicom_combined = dicom_numpy.combine_slices(dicom_list)
    # dicom_numpy neatly returns the affine for nifty, but its very stupid when only one slice is given because its missing one dimension
    # why am I fixing this for their code...
    if dicom_combined[1][2,2] == 0: # fix the slice interval to be the info contained in dicom file
        dicom_combined[1][2,2] = dicom_list[0].SliceThickness
    nifty_image = nib.nifti1.Nifti1Image(dicom_combined[0],dicom_combined[1])
    nib.save(nifty_image,(filename + '.nii'))
    return nifty_image


def main():
    # main
    filepath = sys.argv[1]
    filename = sys.argv[2]
    loadPreprocess(filepath,filename)

if __name__ == "__main__":
    main()