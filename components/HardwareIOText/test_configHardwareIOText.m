[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic library
addpath(genpath(fullfile(cPath, '..', '..')));

cPathConfig = fullfile(...
    cPath, ...
    'default.json' ...
);
        
config = ConfigHardwareIOText(cPathConfig);



