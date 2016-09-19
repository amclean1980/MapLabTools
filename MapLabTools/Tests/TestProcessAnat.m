classdef TestProcessAnat < matlab.unittest.TestCase
  
  properties (Constant)
    TEST_DATA_DIR = '/Data/MRI-Data/McLean/MapLabTools/TestData/tmp'
  end
  
  methods (Test)
    
    % create a new ProcessAnat class
    function setup
            p = ProcessAnat('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl/002/RF2011-0053192s002a1001.nii.gz');
    end
    
    % test that image is properly oriented to the axial orientation
    function TestReoient2std
      % create new object
      p = p.Reorient2Std
      
      % test that new image against test data
      TEST(imageA=imageB);
    end
    
    % test that the image is properly skull stripped
    function TestBrainExtraction
      % perform BET    
      p = p.BrainExtraction;
      % test that new image against test data
      TEST(imageA=imageB);
    end
    
    
    function TestFlirtAlignmenttoAtlas
      p = p.Register2StdBrain;
  
    end
    
    
    
  end
  
end

p = ProcessAnat('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl/002/RF2011-0053192s002a1001.nii.gz');
p = p.Reorient2Std;
p = p.BrainExtraction;
p = p.Register2StdBrain;