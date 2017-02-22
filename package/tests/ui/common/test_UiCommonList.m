[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;


testList = TestList();
testList.build(h, 10, 10);

%{
uiList = mic.ui.common.List(...
    'ceOptions', {'one', 'two', 'three', 'four', 'five', 'six', 'seven'}, ...
    'cLabel', 'Hello, World!' ...
);

uiList.build(h, 10, 10, 150, 100);

% Define callback functions

onRefresh = @(src, evt) ({'bob', 'dave', 'joel', 'chris'});
onDelete = @(src, evt) (evt.stData.ceOptions);


addlistener(uiList, 'eDelete', onDelete);
uiList.setRefreshFcn(onRefresh);
%}

