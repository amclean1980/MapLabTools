function fileOut = fGetNIFTIFileName(fileIn)

  if exist(fileIn,'file')
    fileOut = fileIn;
  elseif exist([fileIn '.nii'], 'file')
    fileOut = [fileIn '.nii'];
  elseif exist([fileIn '.nii.gz'], 'file')
    fileOut = [fileIn '.nii.gz'];
  else
    error('fGetNIFTIFileName:FileNotFount', 'Input file ''%s'' not found', fileIn);
  end
end