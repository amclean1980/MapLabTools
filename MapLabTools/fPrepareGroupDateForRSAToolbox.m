function fullBrainVols = fPrepareGroupDateForRSAToolbox(userOptions)

conditionNames = userOptions.conditionLabels;
rsaDir = userOptions.rootPath;

nrSubs = length(userOptions.subjectNames);
outDir = fullfile(rsaDir, 'ImageData');
if ~exist(outDir,'dir')
  success = mkdir(outDir);
  if ~success
    error('Couldn''t create required directories');
  end
end

fullBrainVols = struct();
for s = 1:nrSubs
  
  subjDir = fullfile(rsaDir, userOptions.subjectNames{s});
  
  % load file, should have variable 'subjectMatrix'
  fn = fullfile(subjDir, sprintf('%s_subjectMatrix.mat', userOptions.subjectNames{s}));
  load(fn);
  
  % check to see if the dimensions match
  if (size(subjectMatrix,2) ~= length(conditionNames))
    error('fPrepareGroupDateForRSAToolbox:DimensionMistmatch', 'Number of conditions and subjectMatrix size don''t agrree');
  end
  
  fullBrainVols.( userOptions.subjectNames{s}) = subjectMatrix; clear subjectMatrix;
end

ImageDataFilename = [userOptions.analysisName, '_ImageData.mat'];
save(fullfile(userOptions.rootPath, 'ImageData', ImageDataFilename), 'fullBrainVols', '-v7.3');

timeStamp = datestr(now);
DetailsFilename = [userOptions.analysisName, '_fMRIDataPreparation_Details.mat'];
save(fullfile(userOptions.rootPath, 'Details', DetailsFilename), 'timeStamp', 'userOptions');



