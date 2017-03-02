[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..');
addpath(genpath(cDirMic));
purge

st1 = struct();
st1.lAsk        = true;
st1.cTitle      = 'Switch?';
st1.cQuestion   = 'Do you want to change from OFF to ON?';
st1.cAnswer1    = 'Yes of course!';
st1.cAnswer2    = 'No not yet.';
st1.cDefault    = st1.cAnswer2;

st2 = struct();
st2.lAsk        = true;
st2.cTitle      = 'Switch?';
st2.cQuestion   = 'Do you want to change from ON to OFF?';
st2.cAnswer1    = 'Yes of course!';
st2.cAnswer2    = 'No not yet.';
st2.cDefault    = st2.cAnswer2;

clock = mic.Clock('Master');

% Configure the mic.ui.common.Toggle instance
ceVararginToggle = {...
    'lAsk', true, ...
    'stF2TOptions', st1, ...
    'stT2FOptions', st2 ...
    'cTextOn', 'Remove', ...
    'cTextOff', 'Insert' ...
};

ui = mic.ui.device.GetSetLogical(...
    'clock', clock, ...
    'ceVararginToggle', ceVararginToggle, ...
    'dWidthToggle', 100, ...
    'cLabel', 'Diode' ...
);

h = figure();
ui.build(h, 10, 10);

 

