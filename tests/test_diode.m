purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'ui-core')));

% Add functions
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'functions')));



h = figure;

clock = Clock('master');
di = Diode('test', clock);
di.build(h, 10, 10);
