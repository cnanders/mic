purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, [sprintf('..%s', filesep), 'ui-core'])));

% Add functions
addpath(genpath(fullfile(cPath, [sprintf('..%s', filesep), 'functions'])));


h = figure( ...
    'Position', [200 200 800 200] ...
);
test = TestKeithley6482();
test.build(h, 10, 10);


