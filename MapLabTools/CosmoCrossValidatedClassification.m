classdef CosmoCrossValidatedClassification  < CosmoModule
  
  properties (Access = private)
    
    classifiers = { ...
      @cosmo_classify_libsvm,...
      @cosmo_classify_nn,...
      @cosmo_classify_naive_bayes,...
      @cosmo_classify_lda};
    
    useFS = true;
    fsMethodType = {'anova'};                     % that's all for now
    fsMethods = {@cosmo_anova_feature_selector};
    fsVoxelsToKeep = 1;                         % for (0-1] -> percent to keep
                                                  % for > 1 -> nr voxels to keep.
    
  end
  
  
  methods (Access = public)
    
    function obj = CosmoCrossValidatedClassification(id, pn)
      % call superclass constructor
      obj@CosmoModule(id,pn);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setFSVoxelsToKeep(obj, nvox)
      if ~isnumeric(nvox)
        error('Error: number of voxels to keep must be numeric');
      end
      obj.fsVoxelsToKeep = nvox;
    end
    
    function nvox = getFSVoxelsToKeep(obj)
      nvox = obj.fsVoxelsToKeep;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function obj = useFeatureSelection(obj,bool)
      if ~isnumeric(bool) && ~logical(bool)
        error('Use feature selection requires a boolean input');
      end
      obj.useFeatureSelection = logical(bool);
    end
    
    function state = getFeatureSelectionState(obj)
      state = obj.useFS;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = execute(obj)
      
      for m = 1:length(obj.maskFileNames)
        
        % make sure we can load the data.
        try
          obj = loadDataFiles(obj, m);
        catch ME
          rethrow(ME);
        end
        
        classifier_names=cellfun(@func2str,obj.classifiers,'UniformOutput',false);
        
        nrClassifiers = length(obj.classifiers);
        
        fprintf('\n\nUsing %d classifiers: %s\n', nrClassifiers, ...
          cosmo_strjoin(classifier_names, ', '));
        
        fig = figure;
        for c = 1:nrClassifiers
          measure = @cosmo_crossvalidation_measure;
          
          args = struct();
          args.classifier= obj.classifiers{c};
          args.partitions=cosmo_nfold_partitioner(obj.ds{m});
          args.output='predictions';

          % feature selection
          if obj.useFS == true
            % need to update the classifier
            args.child_classifier= obj.classifiers{c};
            args.classifier = @cosmo_classify_meta_feature_selection;

            args.feature_selector=obj.fsMethods{1};
            
            % Cosmo treats 1 as one voxel, not 100%.  Seems easier to
            % use proportions as (0-1] because you'd never want just 1
            % voxel anyway.... 
            if obj.fsVoxelsToKeep == 1
              obj.fsVoxelsToKeep = size(obj.ds{m}.samples,2);
            end
            args.feature_selection_ratio_to_keep = obj.fsVoxelsToKeep;
          end
          
          predicted_ds = measure(obj.ds{m}, args);
          confusion_matrix = cosmo_confusion_matrix(predicted_ds);
          accuracy = mean(predicted_ds.samples==predicted_ds.sa.targets);
          
          % visualize confusion matrix and show classification accuracy in the
          % title
          subplot(2,2,c)
          imagesc(confusion_matrix,[0 10]); axis image;
          classifier_name=strrep(classifier_names{c},'_',' '); % no underscores
          desc=sprintf('%s: accuracy %.1f%%', classifier_name, accuracy*100);
          title(desc)
          
          set(gca,'XTickLabel',obj.conditionNames);
          set(gca,'YTickLabel',obj.conditionNames);
          ylabel('target');
          xlabel('predicted');
          colorbar
          
          % print classificationa accuracy in terminal window
          fprintf('%s\n',desc);
          
        end
        
      end % end classifiers
      
    end
    
  end % execture
  
end % class

