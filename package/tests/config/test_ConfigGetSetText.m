[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge

config = mic.config.GetSetText();




