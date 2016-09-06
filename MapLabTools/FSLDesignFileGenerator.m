classdef FSLDesignFileGenerator < Module
  
  properties (Constant)
    TEMPLATE_FILE = '/Data/MRI-Data/McLean/MapLabTools/template.fsf';
    NEW_FILE = 'design.fsf';
  end
  
  properties (Access=private)
    saveName = fullfile('./', FSLDesignFileGenerator.NEW_FILE);
    prt = [];
    conditions = {};
    tags = struct(...
      'outputDir',       struct('tag', '@OUTPUT_DIR@',           'value', ''),...
      'tr',              struct('tag', '@TR@',                   'value', ''),...
      'numVols',         struct('tag', '@TOTAL_NUM_VOLUMES@',    'value', 0),...
      'deleteVols',      struct('tag', '@NUM_DELETE_VOLS@',      'value', 2),...
      'sliceTiming',     struct('tag', '@SLICE_TIMING@',         'value', 5),...
      'smoothing',       struct('tag', '@SPATIAL_SMOOTING_MM@',  'value', 0),...
      'numCond',         struct('tag', '@NUM_CONDITIONS@',       'value', 1),...
      'differentialPred', 1,...
      'numTotalCond',    struct('tag', '@NUM_TOTAL_CONDITIONS@', 'value', 0),...
      'funcFile',        struct('tag', '@FUNC_FILE@',            'value', ''),...
      'anatFile',        struct('tag', '@ANAT_FILE@',            'value', ''),...
      'currentCondName', struct('tag', '@CUR_EV_NAME@',          'value', ''),...
      'currentEVFile',   struct('tag', '@CUR_EV_FILE@',          'value', ''),...
      'current_id',      struct('tag', '@CUR_ID@'),...
      'loop_id',         struct('tag', '@LOOP_ID@'),...
      'section',         struct('tag', '@@@SECTION@@@'));
    
    topSection = [];
    evSection = [];
    contrastSection = [];
    endSection = [];
    
  end
  
  methods (Access = public)
    
    function obj = FSLDesignFileGenerator(pn)
      if (exist(pn,'dir'))
        obj.saveName = fullfile(pn, FSLDesignFileGenerator.NEW_FILE);
      else
        error('Invalid input path')
      end
      fid = fopen(obj.saveName,'w');
      fclose(fid);
    end
    
    function obj = setSaveLocation(obj,fn)
      
    end
    
    function obj = setPRT(obj, fn)
      obj.prt = xff(fn);
      for c = 1:obj.prt.NrOfConditions
        if strcmp(obj.prt.Cond(c).ConditionName, 'Error') == false && ...
            strcmp(obj.prt.Cond(c).ConditionName, 'ITI') == false && ...
            strcmp(obj.prt.Cond(c).ConditionName, 'Rest') == false
          obj.conditions = [obj.conditions obj.prt.Cond(c).ConditionName];
        end
      end
      % sort conditions alphabetically
      obj.conditions = sort(obj.conditions);
      
      obj.tags.numCond.value = length(obj.conditions)
      if obj.tags.differentialPred
        obj.tags.numTotalCond.value = 2*obj.tags.numCond.value;
      else
        obj.tags.numTotalCond.value = obj.tags.numCond.value;
      end
    end
    
    function fn = getPRT(obj)
      fn = obj.prt
    end
    
    function obj = setOutputDir(obj, pn)
      obj.tags.outputDir.value = pn;
    end
    
    function obj = setTR(obj, val)
      obj.tags.tr.value = val;
    end
    
    function obj = setNumVols(obj, val)
      obj.tags.numVols.value = val;
    end
    
    function obj = setDeleteVols(obj,val)
      obj.tags.deleteVols.value = 2;
    end
    
    function obj = setSmoothing(obj, val)
      obj.tags.smoothing.value = val;
    end
    
    function obj = setSliceTiming(obj, type)
      switch(type)
        case {'asc', 1}
          obj.tags.sliceTiming.value = 1;
        case {'desc',2}
          obj.tags.sliceTiming.value = 2;
        case {'inter', 5}
          obj.tags.sliceTiming.value = 5;
        otherwise
          error('incorrect slice timing value: {asc,1}, {desc,2}, {inter,5}');
      end
    end
    
    function obj = useDifferentialPred(obj, val)
      if val == true
        obj.tags.differentialPred.value = 1;
      else
        obj.tags.differentialPred.value = 0;
      end
    end
    
    function obj = setFuncFile(obj, fn)
      obj.tags.funcFile.value = fn;
    end
    
    function obj = setAnatFile(obj, fn)
      obj.tags.anatFile.value = fn;
    end
    
    
    function obj = readTemplateFile(obj)
      fid = fopen(FSLDesignFileGenerator.TEMPLATE_FILE, 'r');
      c = textscan(fid, '%s', 'Delimiter', '\n');
      c=c{:};
      
      % find sections breaks
      breaks = [];
      for i = 1:length(c)
        if strcmp(c{i}, obj.tags.section.tag) == true
          breaks = [breaks i];
        end
      end
      
      obj.topSection = c(breaks(1)+1:breaks(2)-1);
      obj.evSection = c(breaks(2)+1:breaks(3)-1);
      obj.contrastSection = c(breaks(3)+1:breaks(4) - 1);
      obj.endSection = c(breaks(4)+1:end);
      
    end % end readTemplateFile
    
    
    function obj = printSection(obj, section)
      
      fid = fopen(obj.saveName,'a');
      for l = 1:length(section)
        fprintf(fid, '%s\n', section{l});
      end
      fclose(fid);
    end
    
    function obj = processTopSection(obj)
      
      for l = 1:length(obj.topSection)
        r = regexp(obj.topSection{l}, '(@\w+@)', 'match');
        if ~isempty(r)
          for m = 1:length(r)
            matchedValue = r{m};
            swapValue = [];
            %disp(l)
            switch matchedValue
              case {obj.tags.outputDir.tag}
                swapValue = obj.tags.outputDir.value;
              case {obj.tags.tr.tag}
                swapValue = obj.tags.tr.value;
              case {obj.tags.numVols.tag}
                swapValue = obj.tags.numVols.value;
              case {obj.tags.deleteVols.tag}
                swapValue = obj.tags.deleteVols.value;
              case {obj.tags.sliceTiming.tag}
                swapValue = obj.tags.sliceTiming.value;
              case {obj.tags.smoothing.tag}
                swapValue = obj.tags.smoothing.value;
              case {obj.tags.numCond.tag}
                swapValue = obj.tags.numCond.value;
              case {obj.tags.numTotalCond.tag}
                swapValue = obj.tags.numTotalCond.value;
              case {obj.tags.funcFile.tag}
                swapValue = obj.tags.funcFile.value;
              case {obj.tags.anatFile.tag}
                swapValue = obj.tags.anatFile.value;
              otherwise
                error('How did i get here!')
            end
            if isnumeric(swapValue)
              swapValue = num2str(swapValue);
            end
            tmpStr = obj.topSection{l};
            obj.topSection{l} = strrep(tmpStr, matchedValue, swapValue);
          end
        end
      end
      obj.printSection(obj.topSection);
    end % end processTopSection
    
    
    
    function obj = processEvSection(obj)
      
      for c = 1:length(obj.conditions)
        
        curEvSection = obj.evSection;
        curEvName = obj.conditions{c};
        
        [p,f,e] = fileparts(obj.prt.FilenameOnDisk);
        curEvFile = fullfile(p, sprintf('%s_%s.txt', f, curEvName));
        
        for l = 1:length(curEvSection)
          r = regexp(curEvSection{l}, '(@\w+@)', 'match');
          if ~isempty(r)
            for m = 1:length(r)
              matchedValue = r{m};
              swapValue = [];
              %disp(l)
              switch matchedValue
                case {obj.tags.currentCondName.tag}
                  swapValue = curEvName;
                case {obj.tags.currentEVFile.tag}
                  swapValue = curEvFile;
                case {obj.tags.current_id.tag}
                  swapValue = c;
                case {'@LOOP_OVER_NUM_EVS_START@'}
                  loopStart = l;
                case {'@LOOP_OVER_NUM_EVS_END@'}
                  loopEnd = l;
                case {obj.tags.current_id.tag}
                  % do nothing yet
                  continue
                case {obj.tags.loop_id.tag}
                  % do nothing yet
                  continue
                otherwise
                  error('Why amd i here');
              end
              % change swapValue to string, if it's a number.
              if isnumeric(swapValue)
                swapValue = num2str(swapValue);
              end
              tmpStr = curEvSection{l};
              curEvSection{l} = strrep(tmpStr, matchedValue, swapValue);
            end
          end
        end % for line
        
        % deal with loop section
        loopChunk = curEvSection(loopStart+1:loopEnd-1);
        curEvSection(loopStart:loopEnd) = [];
        
        % we need a copy of loopChuck for each condition, plus EV 0
        % 
        for ev = 0:length(obj.conditions)
          for l = 1:length(loopChunk)
            r = regexp(loopChunk{l}, '(@\w+@)', 'match');
            if ~isempty(r)
              for m = 1:length(r)
                matchedValue = r{m};
                swapValue = [];
                %disp(l)
                switch matchedValue
                  case {obj.tags.current_id.tag}
                    swapValue = c;
                  case {obj.tags.loop_id.tag}
                    swapValue = ev;
                  otherwise
                    error('Why amd i here');
                end
                % change swapValue to string, if it's a number.
                if isnumeric(swapValue)
                  swapValue = num2str(swapValue);
                end
                tmpStr = loopChunk{l};
                curEvSection = [ curEvSection; strrep(tmpStr, matchedValue, swapValue)];
              end
            end
          end
        end
        
        
        obj.printSection(curEvSection);
      end % for conditions
    end % function

    function obj = processContrastSection(obj)
      
      %%% ugh... too complicated....
      
      c = {};
      c = [c; '# Contrast & F-tests mode'];
      c = [c; '# real : control real EVs'];
      c = [c; '# orig : control original EVs'];
      c = [c; 'set fmri(con_mode_old) orig'];
      c = [c; 'set fmri(con_mode) orig';''];
      
      for ev = 1:obj.tags.numCond.value
        c = [c; sprintf('# Display images for contrast_real %d',ev)];
        c = [c; sprintf('set fmri(conpic_real.%d) 1', ev);''];
        c = [c; sprintf('# Title for contrast_real %d', ev)];
        c = [c; sprintf('set fmri(conname_real.%d) ""', ev);''];
        
        for rev = 1:obj.tags.numTotalCond.value
           c = [c; sprintf('# Real contrast_real vector %d element %d', ev, rev)];
           
           if rev == 2*ev-1
             val = 1;
           else
             val = 0;
           end
           c = [c; sprintf('set fmri(con_real%d.%d) %d',ev, rev, val);' '];
        end
        
      end
      
      for ev = 1:obj.tags.numCond.value
        c = [c; sprintf('# Display images for contrast_orig %d',ev)];
        c = [c; sprintf('set fmri(conpic_orig.%d) 1', ev);''];
        c = [c; sprintf('# Title for contrast_orig %d', ev)];
        c = [c; sprintf('set fmri(conname_orig.%d) ""', ev);''];
        
        for ev2 = 1:obj.tags.numCond.value
           c = [c; sprintf('# Real contrast_orig vector %d element %d', ev, ev2)];
           if ev2 == ev
             val = 1;
           else
             val = 0;
           end
           c = [c; sprintf('set fmri(con_orig%d.%d) %d',ev, ev2, val);' '];
        end
        
      end
      
      c = [c; '# Contrast masking - use >0 instead of thresholding?'];
      c = [c; 'set fmri(conmask_zerothresh_yn) 0'; ''];
      
      for i = 1:obj.tags.numCond.value
        for j = 1:obj.tags.numCond.value
          if i ~= j
            c = [c; sprintf('# Mask real contrast/F-test %d with real contrast/F-test %d?',i,j)];
            c = [c; sprintf('set fmri(conmask%d_%d) 0',i,j);''];
          end
        end
      end
      
      
      c = [c; '# Do contrast masking at all?'];
      c = [c; 'set fmri(conmask1_1) 0';''];
      
      c = [c; '##########################################################'];
      c = [c; '# Now options that don''t appear in the GUI';''];
      
      c = [c; '# Alternative (to BETting) mask image'];
      c = [c; 'set fmri(alternative_mask) ""';''];
      
      c = [c; '# Initial structural space registration initialisation transform'];
      c = [c; 'set fmri(init_initial_highres) ""';''];
      
      c = [c; '# Structural space registration initialisation transform'];
      c = [c; 'set fmri(init_highres) ""';''];
      
      c = [c; '# Standard space registration initialisation transform'];
      c = [c; 'set fmri(init_standard) ""';''];
      
      c = [c; '# For full FEAT analysis: overwrite existing .feat output dir?'];
      c = [c; 'set fmri(overwrite_yn) 0';''];
      
      obj.printSection(c)
    end
  
    function obj = generate(obj)
      obj = obj.readTemplateFile();
      obj = obj.processTopSection();
      obj = obj.processEvSection();
      obj = obj.processContrastSection();
    end
    
  end  % methods
end % classdef
