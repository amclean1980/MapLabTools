classdef CosmoSplitHalfCorrelation < CosmoModule
  
  properties (Access = public)
    
    %options
    template = [];                % contrast template.  default is diagonal vs non-diagonal
    partitionType = [];           % we're doing split half so don't change.
    correlationType = 'Pearson';  % 'Pearson','Spearman','Kendall'
    outputType = 'correlation';   % 'mean', 'correlation' 'mean_by_fold'
    fisherTransform = true;
    contrastMatrix = [];
    % storage
    corrMatrix=cell(0,1);                % output correlation matrix
    
  end
  
  methods (Access = public)
    
    function obj = CosmoSplitHalfCorrelation(id, pn)
      % call superclass constructor
      obj@CosmoModule(id,pn);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setCorrelationType(obj,type)
      if strcmpi(type, 'pearson') || ...
          strcmpi(type, 'spearman') || ...
          strcmpi(type, 'kendall')
        obj.correlationType = type;
      else
        error('Invalid correlation type: Pearson, Spearman, Kendall');
      end
    end
    
    function type = getCorrelationType(obj)
      type = obj.correlationType;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = useFisherTransform(obj,bool)
      if ~isnumeric(bool) && ~logical(bool)
        error('Use fisher transform requires a boolean input');
      end
      obj.fisherTransform = logical(bool);
    end
    
    function state = getFisherTranformState(obj)
      state = obj.fisherTransform;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setOutputType(obj, type)
      if strcmpi(type, 'mean') || ...
          strcmpi(type, 'correlation') || ...
          strcmpi(type, 'mean_by_fold')
        obj.outputType = type;
      else
        error('Invalid output type: mean, one_minus_corrlelation, mean_by_fold');
      end
    end
    
    function type = getOutputType(obj)
      type = obj.outputType;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read contrast matrix from file
    function obj = setContrastMatrixFilename(obj, fn)
      if ~exist(fn, 'file')
        error('input file %s does not exist', fn);
      end
      
      cm = CosmoModelFileIO();
      cm = cm.parse(fn);
      
      % make sure the conditions are the same
      if numel(obj.conditionNames) ~= numel(cm.conditions)
        error('Error: mismatch in the # of conditions between constrast file and this object');
      end
      
      if all(cellfun(@strcmp, obj.conditionNames(:), cm.conditions(:))) == false
        error('Error: mismatch in conditions between contrast file and this object');
      end
      
      obj.contrastMatrix = cm.getMatrix();
      
    end
    
    % set contrast matrix directly
    function obj = setContrastMatrix(obj, mat)
      % just check the sizes
      if size(mat,1) == obj.nrConds && size(mat,2) == size(mat,1)
        obj.contrastMatrix = mat;
      else
        error('Error: matrix size doesn''t match # conditions')
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function mat = getCorrelationMatrix(obj, maskNr)
      mat = obj.corrMatrix{maskNr};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = execute(obj)
      
      for m = 1:length(obj.maskFileNames)
        
        % make sure we can load the data.
        try
          obj = loadDataFiles(obj,m);
        catch ME
          rethrow(ME);
        end
        
        % make chunks even or odd
        obj = obj.setEvenOddChunks(m);
        
        ds_corr=cosmo_correlation_measure(obj.ds{m});
        fprintf('\nDataset output (correlation difference):\n');
        cosmo_disp(ds_corr);
        
        % set mask_label as filename
        [p,mask_label,e] = fileparts(obj.maskFileNames{m})
        fprintf(['Average correlation difference between matching and '...
          'non-matching categories in %s for %s is %.3f\n'],...
          mask_label, obj.subjId, ds_corr.samples);
        
        
        % Part 2: compute the raw Fisher-transformed correlation matrix,
        % and store the results in 'c_raw'
        %
        % (Hint: use a struct 'args' with args.output='correlation' as second
        % argument for cosmo_correlation_measure)
        args=struct();
        args.output = obj.outputType;
        args.partitions = obj.partitionType;
        args.template = obj.template;
        args.corr_type = obj.correlationType;
        
        c_raw=cosmo_correlation_measure(obj.ds{m},args);
        fprintf('\nDataset output (Fisher-transformed correlations):\n');
        cosmo_disp(c_raw)
        % Because a measure returns .samples as a column vector, the
        % confusion matrix is returned in a flattened form.
        % The data can be put back in matrix form using cosmo_unflatten.
        obj.corrMatrix{m} = cosmo_unflatten(c_raw,1);
        
      end
      
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function showCorrelation(obj, orderVector, maskNr)
      
      [p,mask_label,e] = fileparts(obj.maskFileNames{maskNr})
      label = sprintf('%s %s', obj.subjId, mask_label);
      condNames = obj.conditionNames;
      matrix = obj.corrMatrix{maskNr};
      
      % reorder the output
      if ~isempty(orderVector) && ...
          all(sort(orderVector) == 1:obj.nrConds)
        condNames = condNames(orderVector);
        matrix = matrix(orderVector,:);
        matrix = matrix(:,orderVector);
      end
      
      figure
      imagesc(matrix);
      set(gcf,'name', label);
      t = title(label);
      set(t, 'Interpreter','none');
      set(gca,'XTickLabel',condNames);
      set(gca,'YTickLabel',condNames);
      colorbar();
    end
  end %methods public
  
  
  methods (Access = private)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % data is read in so that the chunk corresponds to the order.
    % Because this is split half, we'll update the chunk to be either 1
    % for even or 2 for odd.
    function obj = setEvenOddChunks(obj, maskNr)
      if isempty(obj.ds{maskNr})
        error('Error: ds field is empty.');
      end
      
      obj.ds{maskNr}.sa.chunks = mod(obj.ds{maskNr}.sa.chunks-1,2)+1;
    end
  end
end