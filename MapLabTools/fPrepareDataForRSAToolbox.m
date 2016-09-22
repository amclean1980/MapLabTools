% standard subject info

function fPrepareDataForRSAToolbox(betaCorrespondence, userOptions, subjNr)

dataFiles = userOptions.fslStatImages;
conditionNames = userOptions.conditionLabels;
imageType = userOptions.fslImageType;
rsaDir = userOptions.rootPath;
rootDir = userOptions.fslDataRootDir;
subjId = userOptions.subjectNames{subjNr};

nrRuns = length(dataFiles);
nrCond = length(conditionNames);

% make sure imageType is either beta or t
if (~strcmp(imageType, 'beta') && ~strcmp(imageType, 'T'))
  error('fPrepareDataForRSAToolbox:ImageType', 'Image type label must be either ''beta'' or ''T''');
end

subjDir = fullfile(rsaDir,subjId);
if ~exist(subjDir,'dir')
  success = mkdir(subjDir);
  if ~success
    error('Couldn''t create required directories');
  end
end

subjectMatrix = [];
for r = 1:nrRuns
  
  
  fn = fGetNIFTIFileName(fullfile(rootDir, subjId, dataFiles{r}));
  if ~exist(fn,'file')
    error('fPrepareDataForRSAToolbox:FileNotFound', 'Input file %s does not exist', fn);
  end
  % load nifti file with beta/t-values
  nii = load_untouch_nii(fn);
  
  % check that dims match, i.e. nrVols = nrCond
  if (nii.hdr.dime.dim(5) ~= nrCond)
    error('fPrepareDataForRSAToolbox:DimensionMismatch', 'Input file %s doesn''t have the right # volumes.', fn);
  end
  
  nrVox = prod(nii.hdr.dime.dim(2:4));
  
  % if run 1, allocate array for all runs
  if (r == 1)
    subjectMatrix = zeros(nrVox, nrCond, nrRuns);
  end
  
  % save off the single file containing the full volume for a single cond.
  for c = 1:nrCond
    betaImage = nii.img(:,:,:,c);
    identifier = replaceWildcards(betaCorrespondence(r,c).identifier, '[[subjectName]]', subjId);
    fn = replaceWildcards(userOptions.betaPath, '[[betaIdentifier]]', identifier, '[[subjectName]]', subjId);
    save(fullfile(subjDir, identifier), 'betaImage','-v7.3');
    clear betaImage;
  end
  
  % save data matrix as .mat file to variable betaImage
  subjectMatrix(:,:,r) = reshape(nii.img, nrVox, nrCond);
  
end

% save subject brain volumes
outFileName = fullfile(subjDir, sprintf('%s_subjectMatrix.mat', subjId));
save(outFileName, 'subjectMatrix', '-v7.3');

end

