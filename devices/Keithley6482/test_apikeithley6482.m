[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..')));

purge();

api = ApiKeithley6482();
api.init()
api.connect()
api.identity()

%{
api.getSingleMeasurement()

u8AverageCount1 = api.getAverageCount(1)
api.setAverageCount(1, 3)
u8AverageCount1 = api.getAverageCount(1)

cAutoRange1B = api.getAutoRangeState(1)
cAutoRange2B = api.getAutoRangeState(2)

api.setAutoRangeState(1, 'off')

cAutoRange1A = api.getAutoRangeState(1)
cAutoRange2A = api.getAutoRangeState(2)
%}