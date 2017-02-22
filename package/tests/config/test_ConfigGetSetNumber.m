[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge

cPathConfig = fullfile(...
    mic.Utils.pathConfig(), ...
    'get-set-number', ...
    'config-default.json' ...
);
        
tic
config = mic.config.GetSetNumber('cPath', cPathConfig);
toc



