[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..', 'libs', 'mic')));
purge();

test = TestKeithley6482();
test.build();