classdef RunBashCommand
  
  properties (Constant)
    SCRIPTS_DIR = '/Data/MRI-Data/McLean/MapLabTools/Bash';
    FSL_DIR = '/usr/local/fsl';
  end
  
  properties
    status = false;
    msg = '';
  end
  
  methods
    function obj = RunBashCommand(varargin)
      % make sure the environment variables are setup properly
      obj.checkEnvVars
      
      bashCmd = varargin{1};
      if (obj.isValidCommand(bashCmd))
        str = sprintf('%s ', bashCmd);
        for p = 2:nargin
          curParam = varargin{p};
          if ischar(curParam)
            str = [str ' ' curParam];
          elseif (isnumeric(curParam))
            str = [str ' ' num2str(curParam)];
          elseif (iscell(curParam))
            for p = 1:length(curParam)
              if ischar(curParam{p})
                str = [str ' ' curParam{p}];
              elseif (isnumeric(curParam{p}))
                str = [str ' ' num2str(curParam{p})];
              end
            end
          else
            error('Invalid input:  Only numeric/string inputs permitted');
          end
        end
        
        % run the command
        [obj.status, obj.msg] = system(str,'-echo');
        
      end
    end
  end
  
  methods (Static)
    
    % update environment variables, if necessary.  This 
    % can also be handled in the matlab user startup file.
    function checkEnvVars
      p=getenv('PATH');
      if isempty(strfind(p, RunBashCommand.SCRIPTS_DIR))
        setenv('PATH',[RunBashCommand.SCRIPTS_DIR ':' p])
      end
      if isempty(strfind(p, RunBashCommand.FSL_DIR))
        setenv('PATH',[RunBashCommand.FSL_DIR '/bin:' p])
      end
      
      if isempty(getenv('FSLDIR'))
        setenv('FSLDIR', RunBashCommand.FSL_DIR)
      end
      if isempty(getenv('FSLOUTPUTTYPE'))
        setenv('FSLOUTPUTTYPE','NIFTI_GZ');
      end
    end
    
    % check if command is on the path
    function val = isValidCommand(cmd)
      val = true;
      % check Script dir
      files = dir(RunBashCommand.SCRIPTS_DIR);
      for f = 1:length(files)
        if strcmp(cmd,files(f).name)
          break;
        end
      end
      % check fsl dir
      files = dir(RunBashCommand.FSL_DIR);
      for f = 1:length(files)
        if strcmp(cmd,files(f).name)
          break;
        end
      end
    end
  end
  
end