
# **MIRTK Registration Tool**

This Jupyter Notebook is designed to facilitate the registration of MRI patient data to brain atlases and the MNI space.

## Features
Selective Atlas Registration: Dynamically choose which atlas (network, visual, motor) to register based on user settings.
MNI Space Alignment: Aligns patient scans with MNI standard space.

## Requirements
Python 3.6 or newer
Jupyter Notebook
MIRTK: Must be installed and configured in the system's PATH.
Python Libraries: tqdm, os, subprocess.

## Inputs
The tool requires the following inputs:

- Atlas Files: Nifti images (.nii) for each brain region (ROI) you wish to register (specified in atlas_paths).
- MNI File: A Nifti image (.nii) of the MNI template used for alignment.
- Patient Directories: Each directory must contain necessary imaging files, expected to be named or converted as specified in the script (b0.mif or b0.nii).

## Configuration

In the notebook:

- Adjust 'atlas_paths' and 'mni_path' to the locations of your atlas and MNI files.
- Configure 'patient_folders' with paths to the patient data directories.

