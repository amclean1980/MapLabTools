classdef CosmoRSA < CosmoModule
  
  properties
    
    distanceMetric = 'correlation'     % opts: 'correlation', 'spearman', 'euclidean', 'mahalanobis'
    modelFileNames = cell(0,1);
    models = [];
    distances = [];
    
  end
  
  methods
    
    function obj = CosmoRSA(id, pn)
      % call superclass constructor
      obj@CosmoModule(id,pn);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = setDistanceMetric(obj, metric)
      if ~strcmpi(metric, 'correlation') && ...
          ~strcmpi(metric, 'spearman') && ...
          ~strcmpi(metric, 'mahalanobis') && ...
          ~strcmpi(metric, 'euclidean')
        error('Error: not one of the allowed metrics: corrleation, spearman, euclidean, mahalanobis');
      end
    end
    
    function metric = getDistanceMetric(obj)
      metric = obj.distanceMetric;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = setModelFileNames(obj, fns)
      if ~iscell(fns)
        error('Error: model file list must be a cell array');
      end
      for f = 1:length(fns)
        if ~exist(obj.getFullFileName(fns{f}),'file')
          error('Error: "%s" does not exist', fns{f})
        end
      end
      obj.modelFileNames = fns;
    end
    
    function fns = getModelFileNames(obj)
      fns = obj.modelFileNames;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = execute(obj)
      
      % we want to combine all the di
      
      for m = 1:length(obj.maskFileNames)
        
        % make sure we can load the data.
        try
          obj = loadDataFiles(obj, m);
        catch ME
          rethrow(ME);
        end
        
        % compute average for each unique target
        ds=cosmo_fx(obj.ds{m}, @(x)mean(x,1), 'targets', 1);

        % remove constant features
        ds=cosmo_remove_useless_data(ds);

        % demean
        ds.samples = bsxfun(@minus, ds.samples, mean(ds.samples, 1));

        % compute the one-minus-correlation value for each pair of
        % targets.
        obj.distances(m,:) = cosmo_pdist(ds.samples, obj.distanceMetric);
        
      end
      
      % load in the model file
      for f = 1:length(obj.modelFileNames)
        c = CosmoModelFileIO();
        c = c.parse(obj.modelFileNames{f});
        obj.models(f,:) = cosmo_squareform(c.getMatrix());
      end
      
      combined = cat(1, obj.distances,obj.models);
      cc = cosmo_corr(combined');
      figure();
      imagesc(cc);
      title('non-centered')
      
    end
    
  end
  
end