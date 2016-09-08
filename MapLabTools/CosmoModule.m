% base class for a pipeline module.

classdef (Abstract) CosmoModule
  
  properties (Access = protected)
    
    subjId = '';
    rootDir = '';
    
    inputFileNames = cell(0,1);
    outputFileNames = cell(0,1);
    maskFileNames = cell(0,1);
    conditionNames = cell(0,1);
    
    nrConds = 0;
    nrRuns = 0;
    
    logFileName = '';
    ds = [];
    
    % general options
    removeUselessData = true;
    
  end
  
  methods (Access = public)
    
    function obj = CosmoModule(id, pn)
      obj.subjId = id;
      if ~exist(pn,'dir')
        error('Error: input path %s does not exist', pn);
      end
      obj.rootDir = pn;      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setInputFileNames(obj, fns)
      % ensure proper format
      if ~iscell(fns)
        error('Input files must be in a cell array');
      end
      % ensure files exist
      for f = 1:length(fns)
        if ~exist(obj.getFullFileName(fns{f}),'file')
          error('Input file %s does not exist', fns{f});
        end
      end
      obj.inputFileNames = fns(:);
      obj.nrRuns = length(fns);
    end
    
    function fns = getInputFileNames(obj)
      fns = obj.getFullFileName(obj.inputFileNames);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setMaskFileNames(obj, fns)
      % ensure proper format
      if ~iscell(fns)
        error('Input mask files must be in a cell array');
      end
      % ensure files exist
      for f = 1:length(fns)
        if ~exist(obj.getFullFileName(fns{f}),'file')
          error('Input file %s does not exist', fns{f});
        end
      end
      obj.maskFileNames = fns(:);
    end
    
    function fns = getMaskFileNames(obj)
      fns = obj.getFullFileName(obj.maskFileNames);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setRemoveUselessData(obj, bool)
      if b == 0
        obj.removeUselessData = false;
      else
        obj.removeUselessData = true;
      end
    end
    
    function bool = getRemoveUselessData(obj)
      bool = obj.removeUselessData;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setConditionNames(obj, names)
      if ~iscell(names)
        error('Error: invalid input type - use cell array');
      end
      
      obj.conditionNames = names(:);
      obj.nrConds = length(names);

    end
    
    function names = getConditionNames(obj)
      names = obj.conditionNames;
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setDataStructure(obj, ds)
      if ~cosmo_check_dataset(ds)
        error('Error: cosmo dataset is invalid');
      end
      obj.ds = ds;
    end
    
    function ds = getDataStructure(obj)
      ds = obj.ds;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  end % end public methods
  
  methods (Abstract)
    
    execute(obj)
    
  end
  
  methods (Access = protected)
  
    % method to load the input data.  We're assuming
    function obj = loadDataFiles(obj)
      
      % load even runs
      for f = 1:length(obj.inputFileNames)
        fn = obj.getFullFileName(obj.inputFileNames{f,1});
        mfn = obj.getFullFileName(obj.maskFileNames{1});
        current = cosmo_fmri_dataset(fn,...
          'mask', mfn,...
          'targets', 1:obj.nrConds,...
          'chunks', f);
        current.sa.labels = obj.conditionNames;
        
        % merge the datasets.
        if f == 1
          obj.ds = current;
        else
          obj.ds = cosmo_stack({obj.ds, current});
        end
      end % for
      
      % remove bad voxels
      if obj.removeUselessData == true
        obj.ds = cosmo_remove_useless_data(obj.ds);
      end
      
    end % loadDataFiles
    
    % if the input is a relative path, construct full path from
    % the rootDir and subjId.  Of not empty, return unchanged.
    function fn = getFullFileName(obj, inputFileName)
      [p,f,e] = fileparts(inputFileName);
      if isempty(p)
        fn = fullfile(obj.rootDir, obj.subjId, [f e]);
      else
        fn = inputFileName;
      end
    end
    
  end
  
  methods (Static)
    
    function fid = openLogFile(fn)
      
      fid = fopen(fn,'a')
      
    end
    
    function closeLogFile
      
      
    end
    
  end  % end methods
  
  methods (Static)
    
  end
  
end