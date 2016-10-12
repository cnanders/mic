purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, [sprintf('..%s', filesep), 'ui-core'])));

% Add functions
addpath(genpath(fullfile(cPath, [sprintf('..%s', filesep), 'functions'])));

h = figure;

uip = UIPopup( ...
    {'Val 1', 'Val 2'}, ...
    'Blah', ...
    false ...
);

uip.build(h, 10, 10, 100, 30);


