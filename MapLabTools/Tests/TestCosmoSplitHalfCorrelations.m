classdef TestCosmoSplitHalfCorrelations  < matlab.unittest.TestCase
  properties
    % test data information
    rootDir = fullfile(getenv('MAPLABDIR'), '/TestData/CosmoData');
    subjId = 's01';
    dataFileNames = {...
      'glm_T_stats_run1.nii.gz'...
      'glm_T_stats_run2.nii.gz'...
      'glm_T_stats_run3.nii.gz'...
      'glm_T_stats_run4.nii.gz'...
      'glm_T_stats_run5.nii.gz'...
      'glm_T_stats_run6.nii.gz'...
      'glm_T_stats_run7.nii.gz'...
      'glm_T_stats_run8.nii.gz'....
      'glm_T_stats_run9.nii.gz'...
      'glm_T_stats_run10.nii.gz' };
    maskFileName = 'vt_mask.nii';
    maskNr = 1;
    conditionNames = {'monkey','lemur','mallard','warbler','ladybug','lunamoth'};
    
    % results location
    resultsDir = fullfile(getenv('MAPLABDIR'), 'TestData/CosmoData/results');
    zMap = 'splithalf-corr-z.txt';
    
  end
  
  methods (Test)
    
    function testZMatrix(testCase)
      
      c = CosmoSplitHalfCorrelation(testCase.subjId, testCase.rootDir);
      c = c.setInputFileNames(testCase.dataFileNames);
      c = c.setMaskFileNames({testCase.maskFileName});
      c = c.setConditionNames(testCase.conditionNames);
      c = c.setRemoveUselessData(true);
      
      c = c.setCorrelationType('Pearson');
      c = c.useFisherTransform(true);
      c = c.setOutputType('correlation');
      c = c.setContrastMatrixFilename(fullfile(testCase.resultsDir, 'splithalf-corr-contrast.txt'));
      c = c.execute();
      c.showCorrelation([], testCase.maskNr);
      
      % do some testing
      z = CosmoModelFileIO();
      z = z.parse(fullfile(testCase.resultsDir, testCase.zMap));
     
      testCase.verifyEqual(z.conditions(:), c.getConditionNames());
      % the output might not be exact so we'll make sure that the
      % abs(mat1 - mat2) is less than the 1/10000th the std.
      mat1 = z.getMatrix();
      mat2 = c.getCorrelationMatrix(testCase.maskNr);
      s = 0.0001 * max(std(mat1(:)), std(mat2(:)));
      testCase.verifyLessThan(abs(mat1-mat2),s);
    end
    
  end
end