purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, '..', 'components')));

% Add functions
addpath(genpath(fullfile(cPath, '..', 'functions')));


h = figure;
test = TestHardwareIOText();
test.build(h, 10, 10);


