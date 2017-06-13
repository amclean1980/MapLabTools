clear
clc

% set toolbox path
toolboxRoot = '/Data/MRI-Data/McLean/rsatoolbox/Engines'
addpath(genpath(toolboxRoot));

% get options
userOptions = fGetAK6UserOptions();

% make directory for RSAtoolbox, if it doesn't exist
if ~exist(userOptions.rootPath,'dir')
  success = mkdir(userOptions.rootPath, 'RSAtoolbox');
  if ~success
    error('Couldn''t create required directories');
  end
end

% generate beta correspondence
betaCorrespondence = fGenerateBetaCorrespondence(userOptions);

% parse FSL files into RSAtoolbox's format
dataPrepped = false;
if ~dataPrepped
  nrSubs = length(userOptions.subjectNames);
  for s = 1:nrSubs
    fprintf('Preparing file for %s\n', userOptions.subjectNames{s});
    fPrepareDataForRSAToolbox(betaCorrespondence, userOptions, s);
  end
end

%%%%%%%%%%%%%%%%%%%%%%
%% Data preparation %%
%%%%%%%%%%%%%%%%%%%%%%
fullBrainVols = fMRIDataPreparation(betaCorrespondence, userOptions);
binaryMasks_nS = fMRIMaskPreparation_FSL(userOptions);
responsePatterns = fMRIDataMasking(fullBrainVols, binaryMasks_nS, betaCorrespondence, userOptions);

%%%%%%%%%%%%%%%%%%%%%
%% RDM calculation %%
%%%%%%%%%%%%%%%%%%%%%

RDMs = constructRDMs(responsePatterns, betaCorrespondence, userOptions);
sRDMs = averageRDMs_subjectSession(RDMs, 'session');
ssRDMs = averageRDMs_subjectSession(RDMs, 'session', 'subject');

% make 4 more subjects up by averaging some RDMs
sRDMs(1,9) = sRDMs(1,1);
sRDMs(1,9).RDM = (sRDMs(1,1).RDM + sRDMs(1,2).RDM)./2 + (1-eye(6)) .* randn(6,6)*.1;
sRDMs(1,9) = sRDMs(1,1);
sRDMs(1,9).name(end-1:end) = '09';
sRDMs(1,10) = sRDMs(1,1);
sRDMs(1,10).RDM =(sRDMs(1,3).RDM + sRDMs(1,7).RDM)./2 + (1-eye(6)) .* randn(6,6)*.1;
sRDMs(1,10).name(end-1:end) = '10';
sRDMs(1,11) = sRDMs(1,1);
sRDMs(1,11).RDM = (sRDMs(1,4).RDM + sRDMs(1,6).RDM)./2 + (1-eye(6)) .* randn(6,6)*.1;
sRDMs(1,11).name(end-1:end) = '11';
sRDMs(1,12) = sRDMs(1,1);
sRDMs(1,12).RDM = (sRDMs(1,8).RDM + sRDMs(1,5).RDM)./2 + (1-eye(6)) .* randn(6,6)*.1;
sRDMs(1,12).name(end-1:end) = '12';

% read in the model files
Models = [];
for i = 1:length(userOptions.modelFiles)
  c = CosmoModelFileIO();
  c = c.parse(userOptions.modelFiles{i});
  Models = [Models c.getRSAToolboxModel()];
  clear c;
end

%Models = constructModelRDMs(modelRDMs(), userOptions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First-order visualisation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figureRDMs(ssRDMs, userOptions, struct('fileName', 'RoIRDMs', 'figureNumber', 1));
figureRDMs(Models, userOptions, struct('fileName', 'ModelRDMs', 'figureNumber', 2));

MDSConditions(ssRDMs, userOptions);
dendrogramConditions(ssRDMs, userOptions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% relationship amongst multiple RDMs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pairwiseCorrelateRDMs({ssRDMs, Models}, userOptions);
MDSRDMs({ssRDMs, Models}, userOptions);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% statistical inference %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
roiIndex = 1;% index of the ROI for which the group average RDM will serve 
% as the reference RDM. 
for i=1:numel(Models)
    modelsCells{i}=Models(i);
end
userOptions.RDMcorrelationType='Kendall_taua';
userOptions.RDMrelatednessTest = 'subjectRFXsignedRank';
userOptions.RDMrelatednessThreshold = 0.05;
userOptions.figureIndex = [10 11];
userOptions.RDMrelatednessMultipleTesting = 'FDR';
userOptions.candRDMdifferencesTest = 'subjectRFXsignedRank';
userOptions.candRDMdifferencesThreshold = 0.05;
userOptions.candRDMdifferencesMultipleTesting = 'none';
stats_p_r=compareRefRDM2candRDMs(sRDMs(roiIndex,:), models, userOptions);

% sRDMsCells = {};
% for i = 1:size(sRDMs,2)
%   sRDMsCells{i} = sRDMs(1,i);
% end
% stats_p_r=compareRefRDM2candRDMs(models{1}, sRDMsCells, userOptions);
% 













