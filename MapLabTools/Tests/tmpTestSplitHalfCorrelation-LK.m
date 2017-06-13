clear_classes
c = SplitHalfCorrelation;
c.rootDir = '/Volumes/SSD240GB/MRI-Data/McLean/MotorAuditoryLocalizer';
c.subjId = 'LK_JUN2_2014-fsl'
c.dataFileNames = {...
  'glms/aligned-to-003/003_cope4D.nii.gz', 1;...
  'glms/aligned-to-003/005_cope4D.nii.gz', 2;...
  'glms/aligned-to-003/009_cope4D.nii.gz', 1;...
  'glms/aligned-to-003/013_cope4D.nii.gz', 2 };
c.nrRuns=4;
c.nrConds=8;

%c.maskFileName = 'rois/aligned-to-003/right-Precentral-gyrus-M1-ero3_standard.nii.gz';
%c.maskFileName = 'rois/aligned-to-003/left-Precentral-gyrus-M1-ero3_standard.nii.gz';
%c.maskFileName = 'rois/aligned-to-003/right-Postcentral-gyrus-S1-ero3_standard.nii.gz';
c.maskFileName = 'rois/aligned-to-003/left-Postcentral-gyrus-S1-ero3_standard.nii.gz';

c.conditionNames = {'Arm', 'Eye', 'Finger', 'Grasp', 'Mouth', 'Speech', 'Toes', 'Touch'};
c = c.loadDataFiles;
c = c.execute;
c.showCorrelation([1 3 4 8 7 2 5 6])