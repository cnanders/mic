[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', '..')));

purge

h = figure;

uip = UIEdit( ...
    'Saved pos', ...
    'd');

uip.build(h, 10, 10, 100, 30);

cb = @(src, evt) (fprintf('pressed enter %1.2f\n', uip.val()));
addlistener(uip, 'eEnter', cb);


