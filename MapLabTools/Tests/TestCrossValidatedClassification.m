clear_classes
rootDir = '/Volumes/SSD240GB/MRI-Data/McLean/MotorAuditoryLocalizer';
subjId = 'LK_JUN2_2014-fsl';
dataFiles = {...
  'glms/aligned-to-003/003_cope4D.nii.gz', ...
  'glms/aligned-to-003/005_cope4D.nii.gz', ...
  'glms/aligned-to-003/009_cope4D.nii.gz', ...
  'glms/aligned-to-003/013_cope4D.nii.gz' };

maskFileNames = { ...
  'rois/aligned-to-003/right-Precentral-gyrus-M1-ero3_standard.nii.gz',...
  'rois/aligned-to-003/left-Precentral-gyrus-M1-ero3_standard.nii.gz',...
  'rois/aligned-to-003/right-Postcentral-gyrus-S1-ero3_standard.nii.gz',...
  'rois/aligned-to-003/left-Postcentral-gyrus-S1-ero3_standard.nii.gz',...
  'rois/aligned-to-003/left-M1-S1-dil5.nii.gz' };

c = CosmoCrossValidatedClassification(subjId, rootDir);
c = c.setInputFileNames(dataFiles);
c = c.setMaskFileNames(maskFileNames(4));
c = c.setConditionNames({'Arm', 'Eye', 'Finger', 'Grasp', 'Mouth', 'Speech', 'Toes', 'Touch'});
c = c.execute();