[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add library to path
addpath(genpath(fullfile(cPath, '..', '..')));

purge;

api = ApivKeithley6482();
api.init()
api.connect()
api.identity()


api.setAverageCount(1, 45)
api.getAverageCount(1)

api.setAverageState(1, 'ON')
api.getAverageState(1)

api.setIntegrationPeriodPLC(1)
api.getIntegrationPeriod

fprintf('getting offset state, set to "on", get again');
api.getChannel1OffsetState()
api.setChannel1OffsetState('on')
api.getChannel1OffsetState()

fprintf('getting offset, setting to current reading, getting again');
api.getChannel1OffsetValue()
api.setChannel1OffsetValueToCurrentReading()
api.getChannel1OffsetValue()

fprintf('setting to 1.3e-5 and getting');
api.setChannel1OffsetValue(1.3e-5)
api.getChannel1OffsetValue()

fprintf('read and get calc result');
api.read(1)
api.getChannel1CalcResult()




