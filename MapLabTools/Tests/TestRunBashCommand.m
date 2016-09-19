clear_classes
r = RunBashCommand('$MAPLABDIR/bin/testScript', 1, 2, 'string');

fprintf(0,'\n');
fprintf(0,'Return status:');
fprintf(0, '---------------------\n');
fprintf(0, '%d', r.status));
disp();
disp(sprintf('Stdout:\n %s', r.msg));
