[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, '..', '..', 'components')));
addpath(genpath(fullfile(cPath, '..', '..', 'devices')));

% Add functions
addpath(genpath(fullfile(cPath, '..', '..', 'functions')));

purge();

api = APIKeithley6482();
api.init()
api.connect()
api.identity()
