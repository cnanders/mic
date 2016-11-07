purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', 'libs', 'mic')));


test = TestKeithley6517A();
test.build();