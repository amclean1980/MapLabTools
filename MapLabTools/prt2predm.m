function dm=prt2fsl(file)
  %file = '/Data/MRI-Data/McLean/MotorAuditoryLocalizer/PRTs/MotorLocalizer_order1.prt'
  prt=xff(file);

  % get fileparts so we can create new filenames easily
  [p,f,e]=fileparts(file);

  maxTime = 0;
  for i = 1:prt.NrOfConditions
    maxTime = max([maxTime, max(prt.Cond(i).OnOffsets(:,2))]);
  end

  % generate a matrix representing time vs condition
  dm = zeros(maxTime, prt.NrOfConditions);
  for c = 1:prt.NrOfConditions
    for e = 1:prt.Cond(c).NrOfOnOffsets
      dm(prt.Cond(c).OnOffsets(e,1):prt.Cond(c).OnOffsets(e,2),c) = 1;
    end
    % write out each column to a text file
    nfn = sprintf('%s_%s%s', fullfile(p,f), prt.Cond(c).ConditionName{1}, '.txt');
    dlmwrite(nfn, dm(:,c), '\t');
  end
  nfn = fullfile(p,[f '.txt']);
  dlmwrite(nfn, dm, '\t');
end
