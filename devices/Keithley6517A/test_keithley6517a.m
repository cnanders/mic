[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..')));

purge

test = TestKeithley6517a();
test.build();