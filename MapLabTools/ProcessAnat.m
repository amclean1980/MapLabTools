classdef ProcessAnat < Module
  
  properties
    betOptions = {'-B', '-m', '-f', '0.3'};
    stdimage = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain';
    baseName = '';
    stdName = '';
    betName = '';
  end
  
  methods
    
    function obj = ProcessAnat(fn)
      if exist(fn,'file') > 0
        obj.baseName = fn;
      else
        error('Counldn''t find input image %s', fn);
      end
    end
    
    % reorient image to standard orientation
    function obj = Reorient2Std(obj)
      obj.stdName = obj.baseName(1:strfind(obj.baseName,'.nii')-1);
      obj.stdName = [obj.stdName '_std.nii.gz' ];
      r = RunBashCommand('fslreorient2std', obj.baseName, obj.stdName);
    end
    
    % perform brain extraction using bet.
    function obj = BrainExtraction(obj)
      obj.betName = obj.stdName(1:strfind(obj.stdName,'.nii')-1);
      for o = 1:length(obj.betOptions)
        obj.betName = [obj.betName '_' obj.betOptions{o}];
      end
      obj.betName = [obj.betName '.nii.gz'];
      r = RunBashCommand('bet', obj.stdName, obj.betName, obj.betOptions);
    end
    
    % n
    function obj = Register2StdBrain(obj)
      [p,f] = fileparts(obj.baseName);
      regDir = fullfile(p,'reg');
      mkdir(regDir);
      
      stdfn = [regDir '/standard'];
      hires = [regDir '/highres'];
      combo = [regDir '/highres2standard'];
      icombo = [regDir '/standard2highres'];
      
      %make a copy of the original images into the 'reg' dir.  
      r = RunBashCommand('fslmaths', obj.stdimage, stdfn);
      r = RunBashCommand('fslmaths', obj.betName, hires);
      
      % perform registration
      r = RunBashCommand('flirt', '-in', hires, '-ref', stdfn, '-out', combo, '-omat', [combo '.mat']);
      % generate inverse tranformation file.
      r = RunBashCommand('convert_xfm', '-inverse', '-omat', [icombo '.mat'], [combo '.mat']);
      
    end
  end
end