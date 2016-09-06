clear_classes

rootDir = '/Volumes/SSD240GB/MRI-Data/McLean/MotorAuditoryLocalizer/'


subFolder = 'LK_JUN2_2014-fsl'
anatInfo = {2, 'RF201100503304s002a1001.nii.gz', 'RF201100503304s002a1001_std_-B_-m_-f_0.3.nii.gz'};
funcInfo = { ...
  3, 'MotorLocalizer_order1.prt', 'RF201100503304s003a001.nii.gz';...
  5, 'MotorLocalizer_order2.prt', 'RF201100503304s005a001.nii.gz';...
  9, 'MotorLocalizer_order1.prt', 'RF201100503304s009a001.nii.gz';...
  13, 'MotorLocalizer_order2.prt', 'RF201100503304s013a001.nii.gz'};

% process the anat
% p = ProcessAnat(fullfile(rootDir, subFolder, sprintf('%03d', anatInfo{1}), anatInfo{2}));
% p = p.Reorient2Std;
% p = p.BrainExtraction;
% p = p.Register2StdBrain;
%anatInfo{3} = p.betName;

f = cell(size(funcInfo,1));
for r = 1:size(funcInfo,1)
  f{r} = FSLDesignFileGenerator(fullfile(rootDir, subFolder, sprintf('%03d',funcInfo{r,1})));
  f{r} = f{r}.setOutputDir(fullfile(rootDir,subFolder, sprintf('%03d',funcInfo{r,1}), 'analysis'));
  f{r} = f{r}.setPRT(fullfile(rootDir, 'PRTs', funcInfo{r,2}));
  f{r} = f{r}.setTR(2);
  f{r} = f{r}.setNumVols(350);
  f{r} = f{r}.setDeleteVols(2);
  f{r} = f{r}.setSliceTiming('inter');
  f{r} = f{r}.setSmoothing(0);
  % TODO: add high pass frequency
  f{r} = f{r}.useDifferentialPred(true);
  f{r} = f{r}.setFuncFile(fullfile(rootDir,subFolder, sprintf('%03d',funcInfo{r,1}),funcInfo{r,3}));
  f{r} = f{r}.setAnatFile(fullfile(rootDir, subFolder, sprintf('%03d', anatInfo{1}), anatInfo{3}));
  
  f{r} = f{r}.generate();
end
