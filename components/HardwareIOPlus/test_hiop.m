
[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..')));

purge

h = figure;
test = TestHardwareIOPlus();
test.build(h, 10, 10);


