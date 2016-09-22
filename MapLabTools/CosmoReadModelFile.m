% Read a model from a text file and create a matrix.
%
% File format should be as follows:
% ---------------------------------
% name: v1_model
% nrCond: 6
% names: { 'monkey','lemur','mallard','warbler','ladybug','lunamoth' }
% matrix:
%      0    0.6099    1.5463    0.8879    1.4972    1.0649
% 0.6099         0    1.5024    0.9785    1.4228    1.1786
% 1.5463    1.5024         0    1.4288    0.6442    1.3539
% 0.8879    0.9785    1.4288         0    1.4713    1.0384
% 1.4972    1.4228    0.6442    1.4713         0    1.2462
% 1.0649    1.1786    1.3539    1.0384    1.2462         0
%

classdef CosmoReadModelFile
  
  properties (SetAccess = private, GetAccess = public )
    
    fn = '';  % filename of external text file
    ds = [];  % Cosmo datatset structure
    name = '';
    nrCond = 0;
    conditions = cell(0,1);
    mat = [];
    
  end
  
  methods (Access = public)
    
    function obj = CosmoReadModelFile(fn)
      % make sure the file exists
      if ~exist(fn,'file')
        error('Error:  input file %s does not exist', fn);
      end
      obj.fn = fn;
      obj = obj.parseFile();
    end
    
    function name = getName(obj)
      name = obj.name;
    end
    
    function c = getConditions(obj)
      c = obj.conditions;
    end
    
    function n = getNrConditions(obj)
      n = obj.nrCond;
    end
    
  end
  methods (Access = private)
    
    function obj = parseFile(obj)
      
      fid = fopen(obj.fn,'r');
      
      while 1
        line = fgetl(fid);
        if (line == -1); break; end % check for eof
        
        % get tokens on either side of the colon then check if it's
        % for the name, nrCond, names, or matrix.
        r = regexp(line,'^(.*):(.*)$','tokens');
        if (~isempty(r))
          if (strcmp(r{1}{1},'name'))
            obj.name = deblank(r{1}{2});
          elseif (strcmp(r{1}{1},'nrCond'))
            tmp = str2double(r{1}{2});
            obj.nrCond = tmp;
          elseif (strcmp(r{1}{1}, 'names'))
            %split string using comma as seperator
            obj.conditions = strtrim(regexp(r{1}{2},',','split'));
          elseif (strcmp(r{1}{1}, 'matrix'))
            obj.mat = zeros(obj.nrCond,obj.nrCond);
            % read the next set of lines
            for l = 1:obj.nrCond
              line = fgetl(fid);
              if (line == -1); break; end  % check for eof
              obj.mat(l,:) = str2num(line);
            end
          end
        end
      end
      
      % make sure it's all good.
      if (obj.nrCond ~= length(obj.conditions) || ...
        obj.nrCond ~= size(obj.mat,1) || ...
        obj.nrCond ~= size(obj.mat,2))
        error('Error: file didn''t parse correctly.  Number mismatch in nrCond, mat or conditions');
      end
      
      % close the file
      fclose(fid);
    end
    
  end   % end private methods
end  % end class