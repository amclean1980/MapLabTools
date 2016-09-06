% base class for a pipeline module.

classdef Module
  
  properties
  end
  
  properties (Constant)
    
  end
  
  methods (Access = protected)
    
    function obj = generateLog(obj)
      
      
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