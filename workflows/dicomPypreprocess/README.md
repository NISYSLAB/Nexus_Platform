# This folder contains the python code to preprocess dicom files.
Python libraries required:

Numpy

Pydicom

DICOM-numpy (only available on pip)

NiBabel


This will load a bunch of dicom slices of different depth of the same scan beginning with the same names and combine them into a nifty file. The script accepts 2 inputs from terminal: filepath and filename.

My assumption is that each scan will be sent via a tar containing all slices named in a manner of filename001.dcm, filename002.dcm...

Normalization - typically they do temporal normalization, which is unavailable for the file converting codes, and spatial normalization is bad (https://www.frontiersin.org/articles/10.3389/fnins.2019.01249/full).

Judging by nibabel.nicom.csareader, Simens scan does not contain csa header info for nifty files, so no meta info is written to the header. 
