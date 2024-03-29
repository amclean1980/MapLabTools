clear_classes
c = SplitHalfCorrelation;
c.rootDir = '/Data/MRI-Data/McLean/CosmoToolbox/datadb/tutorial_data/ak6-perrun/ak6';
c.subjId = 's01';
c.dataFileNames = {...
  'glm_T_stats_run1.nii.gz',1;...
  'glm_T_stats_run2.nii.gz',2;...
  'glm_T_stats_run3.nii.gz',1;...
  'glm_T_stats_run4.nii.gz',2;...
  'glm_T_stats_run5.nii.gz',1;...
  'glm_T_stats_run6.nii.gz',2;...
  'glm_T_stats_run7.nii.gz',1;...
  'glm_T_stats_run8.nii.gz',2;....
  'glm_T_stats_run9.nii.gz',1;...
  'glm_T_stats_run10.nii.gz',2 };
c.nrRuns=10;
c.nrConds=6;
c.maskFileName = 'vt_mask.nii';
c.conditionNames = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};
c = c.loadDataFiles();
c = c.execute();
c.showCorrelation();