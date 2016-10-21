[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, '..', 'components')));

% Add functions
addpath(genpath(fullfile(cPath, '..', 'functions')));

cPathConfig = fullfile(...
    cPath, ...
    '..', ...
    'config', ...
    'hiotx', ...
    'default.json' ...
);
        
config = ConfigHardwareIOText(cPathConfig);



