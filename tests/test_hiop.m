purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'components')));

% Add functions
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'functions')));


h = figure;
test = TestHardwareIOPlus();
test.build(h, 10, 10);


