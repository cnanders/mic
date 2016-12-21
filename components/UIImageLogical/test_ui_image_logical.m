[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Mic
cDirMic = fullfile(cDirThis, '..', '..');
addpath(genpath(cDirMic));

purge;

ui = UIImageLogical();

h = figure;
ui.build(h, 10, 10);