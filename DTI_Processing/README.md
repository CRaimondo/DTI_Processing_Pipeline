# DTI Processing Pipeline Using DIPY

This Jupyter Notebook provides an updated DTI (Diffusion Tensor Imaging) Processing Pipeline utilizing DIPY, a popular library for the analysis of diffusion MRI data. The pipeline is designed to handle steps from raw DTI data processing to tensor fitting and metric extraction.

## Prerequisites

Before running this pipeline, ensure that you have the following software and libraries installed:

### Software Requirements
- **Python 3.8** or later
- **Jupyter Notebook** or JupyterLab: For running the notebook interface.
- **MRtrix3**: Used for MRI data file conversions and preprocessing.
- **ANTs (Advanced Normalization Tools)**: Required for bias correction in MR images.

Ensure that the `ants-2.5.0` binary is added to your system's PATH. You can do this by adding the following line to your `.bashrc` or `.zshrc`:

```bash
export PATH=$PATH:/path/to/ants-2.5.0/bin
```

Replace `/path/to/ants-2.5.0/bin` with the actual path to your ANTs installation.

### Python Library Requirements
Install the following Python libraries via pip:

```bash
pip install numpy nibabel tqdm dipy
```

- **NumPy**: For numerical operations.
- **NiBabel**: For reading and writing neuroimaging data files.
- **tqdm**: For progress bars during data processing steps.
- **DIPY**: For diffusion MRI data analysis.

## Installation

1. Clone the repository or download the Jupyter Notebook file.
2. Install the required Python libraries.
3. Ensure that MRtrix3 and ANTs are correctly installed and configured as described in the prerequisites section.

## Usage

To use the pipeline, follow these steps:

1. Open the Jupyter Notebook in JupyterLab or Jupyter Notebook.
2. Specify the `base_path` variable to the directory containing your patient DTI data.
3. List the patient directories in the `patient_folders` array.
4. Run the notebook cells sequentially to process each patient's DTI data.

## Pipeline Steps

The pipeline includes the following key operations:

- Conversion to MRtrix format.
- Denoising of DTI data.
- Extraction of b0 images.
- DTI data preprocessing including N4 bias correction.
- Fitting of diffusion tensors using DIPY.
- Calculation and storage of DTI metrics like FA, MD, RD, AD, and eigenvalues.

Each step logs its progress and outputs, facilitating troubleshooting and verification of each stage.

## Output

The pipeline outputs the following files for each patient in their respective directories:

- Denoised DTI data.
- Fractional Anisotropy (FA).
- Mean, axial, and radial diffusivities (MD, AD, RD).
- Primary, secondary, and tertiary eigenvectors (V1, V2, V3).
- Eigenvalues (L1, L2, L3).

These files are saved in NIFTI format.
