
# **MIRTK Registration Tool**

This Jupyter Notebook is designed to facilitate the registration of MRI patient data to brain atlases and the MNI space.

## Features
- **Multiple Atlas Registration**: Dynamically choose which atlas (network, visual, motor) to register based on user settings.
- **MNI Space Alignment**: Aligns patient scans with MNI standard space.

## Requirements
- Python 3.6 or newer
- Jupyter Notebook
- MIRTK: Must be installed and configured in the system's PATH.
- Python Libraries: tqdm, os, subprocess.

```bash
pip install tqm os subprocess
```

## Inputs
The tool requires the following inputs:

- Atlas Files: Nifti images (.nii) for each brain region (ROI) you wish to register (specified in atlas_paths).
- MNI File: A Nifti image (.nii) of the MNI template used for alignment.
- Patient Directories: Each directory must contain necessary imaging files, expected to be named or converted as specified in the script (b0.mif or b0.nii).

## Configuration


### Set Up Paths and Data

1. **Atlas and MNI Paths**:
    - Adjust `atlas_paths` and `mni_path` within the notebook to point to your atlas files and the MNI space file.

    Example:
    \```python
    atlas_paths = {
        'network': 'path/to/network/atlas.nii',
        'visual': 'path/to/visual/atlas.nii',
        'motor': 'path/to/motor/atlas.nii'
    }
    mni_path = 'path/to/mni_space.nii'
    \```

2. **Patient Data**:
    - Update `patient_folders` with the paths to the directories containing patient data.

    Example:
    \```python
    patient_folders = [
        'path/to/patient1',
        'path/to/patient2',
        'path/to/patient3'
    ]
    \```

