purge

% Should it be named KeithleyXXXX because that is the hardware it is
% actually reading from?  Unclear how to handle the diode + keithley
% combination.


[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add core
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'ui-core')));

% Add functions
addpath(genpath(fullfile(cPath, sprintf('..%s', filesep), 'functions')));



clock = Clock('Master');
vm = VoltMeter(clock);
h = figure;
vm.build(h, 10, 10);
