[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge;

h = figure;

uiPopup = mic.ui.common.Popup( ...
    'ceOptions', {'Val 1' 'Val 2'}, ...
    'cLabel', 'Blah' ...
);

uiPopup.build(h, 10, 10, 100, 30);


cb = @(src, evt) (fprintf('mic.ui.common.Popup eChange to item %1d\n', src.u8Selected));
addlistener(uiPopup, 'eChange', cb);