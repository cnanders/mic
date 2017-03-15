[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));            

% Add mic library
cDirLib = fullfile(cDirThis, '..', '..');
addpath(genpath(cDirLib));

cDirThisConfig = fullfile(...
    cDirThis, ...
    'config-inverse.json' ...
);
        
tic
config = ConfigHardwareIOPlus(cDirThisConfig);
toc



