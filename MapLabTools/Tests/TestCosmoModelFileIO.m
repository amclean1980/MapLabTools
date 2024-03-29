classdef TestCosmoModelFileIO < matlab.unittest.TestCase
  properties
    % test data
    fn1 = fullfile(getenv('MAPLABDIR'),'Resources', 'sample_model_file.txt');
    fn2 = fullfile(getenv('MAPLABDIR'),'Resources', 'sample_model_file_test.txt');
    
    name = 'v1_model';
    nrCond = 6;
    conds = {'monkey'  'lemur'  'mallard'  'warbler'  'ladybug'  'lunamoth'};
    mat = [      0    0.6099    1.5463    0.8879    1.4972    1.0649;...
            0.6099         0    1.5024    0.9785    1.4228    1.1786;...
            1.5463    1.5024         0    1.4288    0.6442    1.3539;...
            0.8879    0.9785    1.4288         0    1.4713    1.0384;...
            1.4972    1.4228    0.6442    1.4713         0    1.2462;...
            1.0649    1.1786    1.3539    1.0384    1.2462         0];
  end
  methods (Test)
    
    % we'll read in a known file and make sure it matches
    function testParse(testCase)
      c = CosmoModelFileIO();
      c = c.parse(testCase.fn1);
      
      testCase.verifyEqual(c.getName(), testCase.name);
      testCase.verifyEqual(c.getNrConditions(), testCase.nrCond);
      testCase.verifyEqual(c.getConditions(), testCase.conds);
      testCase.verifyEqual(c.getMatrix(), testCase.mat);
      
    end
    
    % we'll read in
    function testWrite(testCase)
      c = CosmoModelFileIO();
      c = c.setName(testCase.name);
      c = c.setConditions(testCase.conds);
      c = c.setMatrix(testCase.mat);
      c = c.setFileName(testCase.fn2);
      c.write();
      
      % read in and compare
      c2 = CosmoModelFileIO();
      c2 = c2.parse(testCase.fn1);
      
      
      testCase.verifyEqual(c.getName(), c2.getName());
      testCase.verifyEqual(c.getNrConditions(), c2.getNrConditions());
      testCase.verifyEqual(c.getConditions(), c2.getConditions());
      testCase.verifyEqual(c.getMatrix(), c2.getMatrix());
    end
    
    
  end
  
end