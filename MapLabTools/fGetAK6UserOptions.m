function userOptions = fGetAK6UserOptions();

% define user options
userOptions = defineUserOptions();

userOptions.analysisName = 'ak6';
% add in some custom stuff for external nifti files from FSL
userOptions.fslDataRootDir = '/Data/MRI-Data/McLean/CosmoToolbox/datadb/tutorial_data/ak6-perrun/ak6/';
userOptions.fslImageType = 'T'; % either T or beta
userOptions.fslStatImages = {...
  'glm_T_stats_run1',...
  'glm_T_stats_run2',...
  'glm_T_stats_run3',...
  'glm_T_stats_run4',...
  'glm_T_stats_run5',...
  'glm_T_stats_run6',...
  'glm_T_stats_run7',...
  'glm_T_stats_run8',...
  'glm_T_stats_run9',...
  'glm_T_stats_run10',...
  };
userOptions.fslMaskFileNames = {'vt_mask.nii','ev_mask.nii'};
userOptions.fslAnatFileName = 'brain.nii';

% RSA toolbox options
userOptions.subjectNames = {'s01', 's02', 's03', 's04', 's05', 's06', 's07', 's08'};
userOptions.rootPath = '/Data/MRI-Data/McLean/CosmoToolbox/datadb/tutorial_data/ak6-perrun/ak6/RSAtoolbox';
% [[subjectName]] gets replace by subjId and 
% [[betaIdentifier]] replaced by contents of betaCorrespondence struct
userOptions.betaPath = fullfile(userOptions.rootPath, '[[subjectName]]', '[[betaIdentifier]]'); 
userOptions.structuralsPath = fullfile(userOptions.rootPath, '[[subjectName]]/brain.nii');
userOptions.maskPath = fullfile(userOptions.fslDataRootDir, '[[subjectName]]', '[[maskName]]');
userOptions.maskNames={'vt_mask', 'ev_mask'};  % don't worry about extension, we'll take care of it

userOptions.conditionLabels = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};

% generate some different colours
nrCond = length(userOptions.conditionLabels);
nrDivs = ceil(nrCond / 3);
userOptions.conditionColours = [(0:nrCond-1)'/nrCond mod((0:nrCond-1)',nrDivs)/nrDivs floor((0:nrCond-1)'/3)/nrDivs];
userOptions.getSPMData = 0;

% model files - we'll use the CosmoModelFileIO style
userOptions.modelPath = fullfile(userOptions.fslDataRootDir, 'Models');
userOptions.modelFiles = {fullfile(userOptions.modelPath,'behav_sim.txt'),fullfile(userOptions.modelPath,'v1_model.txt')};

