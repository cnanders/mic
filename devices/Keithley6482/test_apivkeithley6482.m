[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add library to path
addpath(genpath(fullfile(cPath, '..', '..')));

purge;

api = APIVKeithley6482();
api.init()
api.connect()
api.identity()


api.setAverageCount(1, 45)
api.getAverageCount(1)

api.setAverageState(1, 'ON')
api.getAverageState(1)

api.setIntegrationPeriodPLC(1)
api.getIntegrationPeriod
