%%
% ClassifierSearchlight
% 
% This module allows you to run a searchlight analysis on a single
% subject.  

classdef CosmoClassifierSearchlight < CosmoModule
  
  properties (Access = public)
    
    classiferType = 'lda';                % {lda, svm, nb (naive bayes), nn}
    classifier = @cosmo_classify_lda;     % function handle
    partitionType = 'splithalf';          % {splithalf, nfold}
    partition = @cosmo_nfold_partitioner;
    normalization = [];           % {[],zscore,demean,scale_unit}
    searchlightRadius = 0;                % nr voxels
    searchlightNrVox = 100;

  end
  
  methods (Access = public)
    
    function obj = CosmoClassifierSearchlight(id, pn)
      % call superclass constructor
      obj@CosmoModule(id,pn);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setclassiferType(obj, m)
      switch m
        case 'lda',
          obj.classiferType = 'lda';
          obj.classifer = @cosmo_classify_lda;
        case 'svm'
          obj.classiferType = 'svm';
          if cosmo_check_external('svm',false)
            obj.classifer=@cosmo_classify_svm;
          end
        case 'nn'
          obj.classiferType = 'nn';
          obj.classifer = @cosmo_classify_nn;
        case 'nb'
          obj.classiferType = 'nb';
          obj.classifer = @cosmo_classify_naive_bayes;          
        otherwise
          error('Error: unsported classifier - %', m);
      end
    end
    
    function [type, fh] = getclassiferType(obj)
      type = obj.classiferType;
      fh = obj.classifer;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setPartitionType(obj, p)
      switch p
        case 'half',
          obj.partitionType = 'splithalf';
          obj.partition = @cosmo_oddeven_partitioner;
        case 'nfold'
          obj.partitionType = 'nfold';
          obj.partition = @cosmo_nfold_partitioner;
        otherwise
          error('Error: unsported partition type - %', p);
      end
    end
    
    function [type] = getPartitionType(obj)
      type = obj.partitionType;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setNormalization(obj, n)
      if ~strcmp(n, 'zscore') && ...
         ~strcmp(n, 'demean') && ...
         ~strcmp(n, 'scale_unit')
       error('Error: unsported normalization type - %', n);
      end
    end
    
    function [type] = getNormalization(obj)
      type = obj.normalization;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function obj = execute(obj)
      
      % make sure we can load the data.
      try
        obj = loadDataFiles(obj);
      catch ME
        rethrow(ME);
      end
      
      % set the neighbourhood
      nbrhood=cosmo_spherical_neighborhood(obj.ds,'count', obj.searchlightNrVox);
      
      % setup the measure
      measure = @cosmo_crossvalidation_measure;    
      measure_args = struct();
      measure_args.classifier = obj.classifier;
      measure_args.normalization = obj.normalization;
      if strcmp(obj.partitionType, 'splithalf')
        % we're doing split-half so update the chunk information
        % to be either even or odd.  Just take modulo 2
        %obj.ds.sa.chunks = mod(obj.ds.sa.chunks-1,2)+1;
        measure_args.partitions = cosmo_oddeven_partitioner(obj.ds, 'full');
      else
        measure_args.partitions = cosmo_nfold_partitioner(obj.ds);
      end
      
      
      % run it
      ds_cfy=cosmo_searchlight(obj.ds,nbrhood,measure,measure_args);
      
      % Visualize the results using cosmo_plot_slices
      cosmo_plot_slices(ds_cfy);
      
      % Set output filename
      fn = sprintf('%s_%s_searchlight_accuracy_nvox_%d.nii.gz', obj.classiferType, obj.partitionType, obj.searchlightNrVox);
      obj.outputFileNames = { obj.getFullFileName(fn) };
      % Write output to a NIFTI file using cosmo_map2fmri
      cosmo_map2fmri(ds_cfy, obj.outputFileNames{1});

    end
        
  end % end public methods
end