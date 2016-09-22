classdef CosmoGroupModule < CosmoModule
 
  properties
    modelFileNames = cell(0,1);
    models = cell(0,1);
    subjObjs = cell(0,1);
    subjIds = cell(0,1);
  end
  
  methods (Access = public)
  
    function obj = CosmoGroupModule(rootdir)
        obj@CosmoModule('', rootDir);
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
  
  
  
end