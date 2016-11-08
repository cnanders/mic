
[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..', 'mic')));

purge

h = figure( ...
    'Position', [200 200 800 200] ...
);
test = TestKeithley6482();
test.build(h, 10, 10);


