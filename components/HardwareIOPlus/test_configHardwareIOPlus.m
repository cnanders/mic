[cPath, cName, cExt] = fileparts(mfilename('fullpath'));            

% Add mic library
addpath(genpath(fullfile(cPath, '..', '..')));

cPathConfig = fullfile(...
    cPath, ...
    'config-default.json' ...
);
        
tic
config = ConfigHardwareIOPlus(cPathConfig);
toc



