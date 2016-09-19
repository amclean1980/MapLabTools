clear_classes
c = ConvertDicomToNifti;
c = c.setDicomDir('/Data/MRI-Data/McLean/MapLabTools/TestData/DCM');
c = c.setNiftiDir('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl');
c = c.convert;
