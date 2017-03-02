[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..');
addpath(genpath(cDirMic));

purge

test = TestGetSetText();

h = figure();
test.build(h, 10, 10);


