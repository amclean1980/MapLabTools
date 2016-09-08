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

classdef CosmoModelFileIO
  
  properties (SetAccess = private, GetAccess = public )
    
    fn = '';  % filename of external text file
    ds = [];  % Cosmo datatset structure
    name = '';
    nrCond = 0;
    conditions = cell(0,1);
    mat = [];
    
  end
  
  methods (Access = public)

    function obj = setFileName(obj, fn)
      obj.fn = fn;
    end
    
    function obj = setName(obj, name)
      obj.name = name;
    end
    
    function obj = setConditions(obj, conds)
      if ~iscell(conds)
        error('Error: conditions names must be a cell array');
      end
      obj.conditions = conds;
      obj.nrCond = length(obj.conditions);
    end
    
    function obj = setNrConditions(obj, n)
      obj.nrCond = n;
    end
    
    function obj = setMatrix(obj, mat)
      obj.mat = mat;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read input file from disk and populate object
    function obj = parse(obj, fn)
      
      if ~exist(fn, 'file')
        error('input file ''%s'' doesn''t exist', fn);
      end
      obj.fn = fn;

      try
        
        fid = fopen(obj.fn,'r');
        while 1
          line = fgetl(fid);
          if (line == -1); break; end % check for eof
          
          % get tokens on either side of the colon then check if it's
          % for the name, nrCond, names, or matrix.
          r = regexp(line,'^(.*):(.*)$','tokens');
          if (~isempty(r))
            if (strcmp(r{1}{1},'name'))
              obj.name = strtrim(r{1}{2});
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
        
        % close the file
        fclose(fid);
        obj.validate();
      catch ME
        fclose(fid);
        rethrow(ME)
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write object to file
    
    function write(obj)
      
      try 
        fid = fopen(obj.fn, 'w')
        fprintf(fid, 'name: %s\n', obj.name);
        fprintf(fid, 'nrCond: %d\n', obj.nrCond);
        fprintf(fid, 'names: ');
        for c = 1:obj.nrCond
          fprintf(fid, '%s, ', obj.conditions{c});
        end
        fprintf(fid,'\n');
        for r = 1:obj.nrCond
          for c = 1:obj.nrCond
            fprintf(fid, '%.6f ', obj.mat(r,c));
          end
          fprintf(fid,'\n');
        end
        fclose(fid);
        
      catch ME
        fclose(fid);
        rethow(ME)
      end
     
    end
    
  end
  
  
  methods (Access = private)
    
    % make sure the everything is the same size
    function good = validate(obj)
      if (obj.nrCond ~= length(obj.conditions) || ...
          obj.nrCond ~= size(obj.mat,1) || ...
          obj.nrCond ~= size(obj.mat,2))
        error('Error: Number mismatch in nrCond, mat or conditions');
      end
    end
    
    
    
  end   % end private methods
end  % end class