# **DTI Processing Pipeline**

This repository serves as a collection of code, scripts, and notes for DTI processing, constituting a pipeline that can take an dMRI DICOM  all the way to beautifully pre-processed DTI images (and beyond). 

![](Picture1.svg)


## Contents Contained in this repo (running list):

### (1) DTI Processing Pipeline Jupyter Notebook 
- For DTI processing of NIFTI files: 
- Run from Jupyter Notebook and change base path directory to your own.  
- Required Starting files: bval.bval, bvec.bvec, dti.nii files are in each patient folder.

### (2) MIRTK Registration 
- Run from command line

### (3) MAP Processing
- For MAP processing of DTI outputs
- Run fron Matlab in your base path directory.
- Required Starting Files in each dti_outputs folder: bval.bval, bvec.bvec, b0.nii, mask.nii

### (4) Tractography
- For whole brain tractography of DTI outputs
- Run from Jupyter Notebook and change base path directory to your own.
- Required Starting Files: denoise.nii, mask.nii, b0.nii
