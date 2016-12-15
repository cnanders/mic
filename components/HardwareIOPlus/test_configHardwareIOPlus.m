[cPath, cName, cExt] = fileparts(mfilename('fullpath'));            

% Add mic library
addpath(genpath(fullfile(cPath, '..', '..')));

cPathConfig = fullfile(...
    cPath, ...
    'config-default-stores.json' ...
);
        
tic
config = ConfigHardwareIOPlus();
toc



