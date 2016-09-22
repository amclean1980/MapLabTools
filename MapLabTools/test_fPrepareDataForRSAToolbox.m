% get options
userOptions = fGetAK6UserOptions();

% get betaCorrespondence
betaCorrespondence = fGenerateBetaCorrespondence(userOptions);

% make directory for RSAtoolbox, if it doesn't exist
if ~exist(userOptions.rootPath,'dir')
  success = mkdir(userOptions.rootPath, 'RSAtoolbox');
  if ~success
    error('Couldn''t create required directories');
  end
end

nrSubs = length(userOptions.subjectNames);
betaCorrs = cell(nrSubs);
for s = 1:nrSubs
  fprintf('Preparing file for %s\n', userOptions.subjectNames{s});
  betaCorrs{s} = fPrepareDataForRSAToolbox(betaCorrespondence, userOptions, s);
end

