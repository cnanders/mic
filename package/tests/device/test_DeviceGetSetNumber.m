[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge

clock = mic.Clock('master');

device = mic.device.GetSetNumber('Test', 10, clock);