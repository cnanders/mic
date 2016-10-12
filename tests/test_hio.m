purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'ui-core')));

% Add functions
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'functions')));


h = figure;

cl = Clock('master');
hio = HardwareIO('Test A', cl);
hio.api = APIVHardwareIO('TestAPI', 0, cl);
hio.build(h, 10, 10);
