[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', 'libs', 'mic')));

% Add classes
addpath(genpath(fullfile(cPath, '..', 'classes')));

purge;

api = ApiKeithley6517a();
api.init()
api.connect()
api.setFunctionToAmps();

cIdentity = api.identity()

api.setIntegrationPeriod(100e-3)
dPeriod = api.getIntegrationPeriod()

api.setAverageState('ON')
cAverageState = api.getAverageState()

api.setAverageCount(12)
u8AverageCount = api.getAverageCount()

api.setAverageMode('MOVING')
cAverageMode = api.getAverageMode()



api.setRange(20e-6)
dRange = api.getRange()

api.setAverageType('NONE')
cAverageType = api.getAverageType()


api.setMedianState('OFF')
api.setMedianRank(3)

cMedianState = api.getMedianState()
u8MedianRank = api.getMedianRank()