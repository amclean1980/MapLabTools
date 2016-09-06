function dm=prt2fsl3(file)
  %file = '/Data/MRI-Data/McLean/MotorAuditoryLocalizer/PRTs/MotorLocalizer_order1.prt'
  prt=xff(file);

  % get fileparts so we can create new filenames easily
  [p,f,e]=fileparts(file);

  maxTime = 0;
  for i = 1:prt.NrOfConditions
    maxTime = max([maxTime, max(prt.Cond(i).OnOffsets(:,2))]);
  end

  % maake the offsets file
  for c = 1:prt.NrOfConditions
    filename = sprintf('%s_%s%s', fullfile(p,f), prt.Cond(c).ConditionName{1}, '.txt');
    fid = fopen (filename,'w');
    for e = 1:prt.Cond(c).NrOfOnOffsets
      onset = prt.Cond(c).OnOffsets(e,1);
      duration = prt.Cond(c).OnOffsets(e,2) - onset;
      weight = 1;
      fprintf(fid, '%.6f\t%.6f\t%.6f\n', onset, duration, weight);
    end
    % write out each column to a text file
    fclose(fid);
  end
end
