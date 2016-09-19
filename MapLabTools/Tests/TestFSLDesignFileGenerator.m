clear_classes
f = FSLDesignFileGenerator();

f = f.setOutputDir('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl/003/analysis');
f = f.setPRT('/Data/MRI-Data/McLean/MapLabTools/TestData/PRTs/MotorLocalizer_order1.prt');
f = f.setTR(2);
f = f.setNumVols(350);
f = f.setDeleteVols(2);
f = f.setSliceTiming('inter');
f = f.setSmoothing(0);
% high pass frequency 
f = f.useDifferentialPred(true);
f = f.setFuncFile('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl/003/RF2011-0053192s003a001_std.nii.gz');
f = f.setAnatFile('/Data/MRI-Data/McLean/MapLabTools/TestData/fsl/002/RF2011-0053192s002a1001_std_-B_-m_-f_0.3.nii.gz');

f = f.generate();

