
[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cDirThis, '..', '..')));

purge

h = figure;
testObj = TestHardwareIOPlus();
testObj.build(h, 10, 10);

% cb = @(src, evt) (delete(testObj); delete(h));
% set(h, 'CloseRequestFcn', cb);
% addlistener(uip, 'eEnter', cb);


