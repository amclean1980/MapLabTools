% Converts an entire sessions dicom files to nifti files.  Conversion uses
% BASH script convertDicoms with a preset options for conversion.
% - After conversion, each series is put into a folder of it's own (this
% is the fsl way) by calling BASH script 'makeRunFolders'

classdef ConvertDicomToNifti < Module
  
  properties (Access = private)
    dicomDir = '';
    niftiDir = '';
    status = false;
  end
  
  methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setters and getters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = setDicomDir(obj, pn)
      if exist(pn) == 7
        obj.dicomDir = pn;
      else
        error([dcmDir ' does not exist!']);
      end
    end
    
    function pn = getDicomDir(obj)
      pn = obj.dicomDir;
    end
    
    function obj = setNiftiDir(obj,pn)
      obj.niftiDir = pn;
    end
    
    function pn = getNiftiDir(obj)
      pn = obj.niftiDir;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % main function to call when you want to convert
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = convert(obj)
      
      try
        r1 = RunBashCommand('convertDicoms', obj.getDicomDir, obj.getNiftiDir);
      catch ME
        disp(r1.msg);
        return;
      end
      
      try
        r2 = RunBashCommand('makeRunFolders', obj.getNiftiDir);
      catch ME
        disp(r2.msg);
        return
      end
      
      obj.status = true;
    end
    
  end
  
  methods (Static)
    
  end
end