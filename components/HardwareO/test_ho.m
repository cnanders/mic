purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'ui-core')));

% Add functions
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'functions')));



h = figure;

cName = 'Test';
cl = Clock('master');
ho = HardwareO(cName, cl);% 
stParams = {};
stParams.cName = 'TestAPI';
stParams.clock = cl;
ho.api = APIVHardwareO(stParams);
ho.build(h, 10, 10);
