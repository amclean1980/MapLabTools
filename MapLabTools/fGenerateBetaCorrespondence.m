% creates the betaCorrespondence struct for a subject and saves it to
% the details directory.  Only use this if the data has already been
% created by fPrepareDataForRSAToolbox.
% Image Type must be either 'beta' or 'T'
%
% For consistency, we'll always store
% in the following format:
% [subjId]_session[runNr]_[conditionName]_[imageType].mat
function betaCorrespondence = fGenerateBetaCorrespondence(userOptions)

betaCorrespondence = struct('identifier', '');

% make sure imageType is either beta or t
if (~strcmp(userOptions.fslImageType, 'beta') && ~strcmp(userOptions.fslImageType, 'T'))
  error('fPrepareDataForRSAToolbox:ImageType', 'Image type label must be either ''beta'' or ''T''');
end

saveDir = fullfile(userOptions.rootPath,'Details');
if ~exist(saveDir,'dir')
  success = mkdir(saveDir)
  if ~success
    error('fGenerateBetaCorrespondence:MkdirFailure', 'Counldn''t generate Details directory in the RSA folder');
  end
end
  
nrRuns = length(userOptions.fslStatImages);
nrCond = length(userOptions.conditionLabels);
for r = 1:nrRuns
  for c = 1:nrCond
    betaCorrespondence(r,c).identifier = ...
      sprintf('[[subjectName]]_session%d_%s_%s.mat',r, userOptions.conditionLabels{c}, userOptions.fslImageType );
  end
end
 
fn = fullfile(userOptions.rootPath,'Details',sprintf('%s_betaCorrespondence.mat', userOptions.analysisName));
save(fn, 'betaCorrespondence','-v7.3');

end
    
    
    
