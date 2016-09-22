classdef SplitHalfCorrelation
  
  properties
    % input properties
    rootDir = '';
    subjId = '';
    dataFileNames = cell(0,2);
    maskFileName = '';
    conditionNames = cell(0);
    nrRuns = 0;
    nrConds = 0;
    
    %options
    template = [];                % contrast template.  default is diagonal vs non-diagonal
    partitionType = [];           % we're doing split half so don't change.
    correlationType = 'Pearson';  % 'Pearson','Spearman','Kendall'
    outputType = 'correlation';   % 'mean', 'one_minus_correlation' 'mean_by_fold'
    removeUselessData = true;     % let cosmo figure out useless voxels (lots of zeros, etc.)
    
    
    % storage
    ds=[];                        % main data stucture
    corrMatrix=[];                % output correlation matrix
    
  end
  
  methods
    
    % method to load the input data.  We're assuming
    function obj = loadDataFiles(obj)
      
      % load even runs
      for f = 1:length(obj.dataFileNames)
        fn = fullfile(obj.rootDir, obj.subjId, obj.dataFileNames{f,1});
        mfn = fullfile(obj.rootDir, obj.subjId, obj.maskFileName);
        current = cosmo_fmri_dataset(fn,...
          'mask', mfn,...
          'targets', 1:obj.nrConds,...
          'chunks', obj.dataFileNames{f,2});
        current.sa.labels = obj.conditionNames';
        
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
    
    % used to 
    function obj = reorderConditions(obj,order)
      
      
    end
    
    function obj = execute(obj);
      
      ds_corr=cosmo_correlation_measure(obj.ds);
      fprintf('\nDataset output (correlation difference):\n');
      cosmo_disp(ds_corr);
      
      % set mask_label as filename
      [p,mask_label,e] = fileparts(obj.maskFileName)
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
      
      c_raw=cosmo_correlation_measure(obj.ds,args);
      fprintf('\nDataset output (Fisher-transformed correlations):\n');
      cosmo_disp(c_raw)
      % Because a measure returns .samples as a column vector, the
      % confusion matrix is returned in a flattened form.
      % The data can be put back in matrix form using cosmo_unflatten.
      obj.corrMatrix = cosmo_unflatten(c_raw,1);
      
    end
    
    function showCorrelation(obj, orderVector)
      
      [p,mask_label,e] = fileparts(obj.maskFileName)
      label = sprintf('%s %s', obj.subjId, mask_label);
      condNames = obj.conditionNames;
      matrix = obj.corrMatrix;
      
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
    
  end %methods
end