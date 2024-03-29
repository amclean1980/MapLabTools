clear 
clc
clear_classes
dataFileNames = {...
  'glm_T_stats_run1.nii.gz',...
  'glm_T_stats_run2.nii.gz',...
  'glm_T_stats_run3.nii.gz',...
  'glm_T_stats_run4.nii.gz',...
  'glm_T_stats_run5.nii.gz',...
  'glm_T_stats_run6.nii.gz',...
  'glm_T_stats_run7.nii.gz',...
  'glm_T_stats_run8.nii.gz',....
  'glm_T_stats_run9.nii.gz',...
  'glm_T_stats_run10.nii.gz'};

subjId = 'ak6/s01';
rootDir = '/Data/MRI-Data/McLean/CosmoToolbox/datadb/tutorial_data/ak6-perrun';
nrRuns=10;
nrConds=6;
maskFileName = 'brain_mask.nii';
conditionNames = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};


s = CosmoClassifierSearchlight(subjId, rootDir);
s = s.setInputFileNames(dataFileNames);
s = s.setMaskFileNames({maskFileName});
s = s.setConditionNames(conditionNames);
s = s.execute();