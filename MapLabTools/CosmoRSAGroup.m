classdef CosmoRSAGroup < CosmoModule
  
  properties
    
    distanceMetric = 'correlation'     % opts: 'correlation', 'spearman', 'euclidean', 'mahalanobis'
    modelFileNames = cell(0,1);
    models = cell(0,1);
    subjObjs = cell(0,1);
    subjIds = cell(0,1);
    
  end
  
  methods
    
    function obj = CosmoRSAGroup(rootDir)
      % call superclass constructor
      obj@CosmoModule('',rootDir);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setSubList(obj, s)
      if ~iscell(s)
        error('Error: subjId list must be a cell array');
      end
      
      obj.subjIds = s;
    end
    
    function s = getSubList(obj)
      s = obj.subjIds;
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
    
    function obj = setInputFileNames(obj, fns)
      if ~iscell(fns)
        error('Error: input must be cell array');
      end
      obj.inputFileNames = fns;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setMaskFileNames(obj, fns)
      if ~iscell(fns)
        error('Error: input must be cell array');
      end
      obj.maskFileNames = fns;
    end
    
    
    function obj = execute(obj)
      
      % we want to combine all the di
      
      for s = 1:length(obj.subjIds)
        fprintf('Processing %s....\n', obj.subjIds{s});
        c = CosmoRSA(obj.subjIds{s}, obj.rootDir);
        c = c.setInputFileNames(obj.inputFileNames);
        c = c.setMaskFileNames(obj.maskFileNames);
        c = c.setConditionNames(obj.conditionNames);
        c = c.setDistanceMetric(obj.distanceMetric);
        c = c.setModelFileNames(obj.modelFileNames);
        c = c.execute();
        obj.models{s} = c;
      end
      
      % combine from over rois, subject
      combined = [];
      labels = cell(0,1);
      c = 0;
      for m = 1:length(obj.maskFileNames)
        for s = 1:length(obj.subjIds)
          c=c+1;
          combined(c,:) = obj.models{s}.distances(m,:);
          labels{c} = sprintf('%s-%s', obj.subjIds{s}, obj.maskFileNames{m});
        end
      end
      
      for m = 1:length(obj.models{1}.modelFileNames)
        combined = cat(1,combined,obj.models{m}.models(m,:));
        [~,m]=fileparts(obj.models{1}.modelFileNames{m});
        labels = cat(1, labels(:), m);
      end
      
      figure
      cc = cosmo_corr(combined');
      imagesc(cc)
      set(gca,'XTickLabels',labels);
      set(gca,'YTickLabels',labels);
      
      figure
      cc_models = [cc(1:8,17) cc(9:16,17) cc(1:8,18) cc(9:16,18)];
      labels = {'v1 model~EV','v1 model~VT','behav~EV','behav~VT'};
      figure();
      boxplot(cc_models);
      set(gca,'XTick',[1:4],'XTickLabel',labels);
      
    end
    
  end
  
end