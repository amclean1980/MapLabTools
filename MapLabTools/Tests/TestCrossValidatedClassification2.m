clear_classes
rootDir = '/Data/MRI-Data/McLean/CosmoToolbox/datadb/tutorial_data/ak6-perrun/ak6';
subjId = 's01'
dataFiles = {...
  'glm_T_stats_run1.nii.gz',...
  'glm_T_stats_run2.nii.gz',...
  'glm_T_stats_run3.nii.gz',...
  'glm_T_stats_run4.nii.gz',...
  'glm_T_stats_run5.nii.gz',...
  'glm_T_stats_run6.nii.gz',...
  'glm_T_stats_run7.nii.gz',...
  'glm_T_stats_run8.nii.gz',...
  'glm_T_stats_run9.nii.gz',...
  'glm_T_stats_run10.nii.gz',...
  };

maskFileNames = {'vt_mask.nii'};
conditionNames = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};

c = CosmoCrossValidatedClassification(subjId, rootDir);
c = c.setInputFileNames(dataFiles);
c = c.setMaskFileNames(maskFileNames);
c = c.setConditionNames(conditionNames);
c = c.execute();