purge

[cPath, cName, cExt] = fileparts(mfilename('fullpath'));

% Add mic
addpath(genpath(fullfile(cPath, '..', 'lib', 'mic')));

% Add classes
addpath(fullfile(pwd, 'classes'));

h = figure( ...
    'Position', [20 20 1250 720] ... % left bottom width height
);


zpa = ZoomPanAxes(-1, 1, -.5, .5, 1200, 700, 10);
zpa.build(h, 10, 10);

% set(this.hPanel, 'CurrentAxes', this.hAxes)

% There are two options, one exposes the axes and lets you add anything you
% want to it, the other exposes a hggroup property and lets you modify it.
% I am leanign towards the later

hHggroup = hggroup('Parent', zpa.hHggroup);

dt = pi/1000;
t = [0*pi/180:dt:70*pi/180,...
    110*pi/180:dt:170*pi/180,...
    190*pi/180:dt:360*pi/180];

% Rotate 90-degrees

d = 0.5; % diameter
hPatch1 = patch( ...
    d/2*sin(t), ...
    d/2*cos(t), ...
    [0.1, 0.1, 0.1], ...
    'Parent', hHggroup, ...
    'EdgeColor', 'none' ...
);
hPatch2 = patch( ...
    0.8*[-1 -1 1 1], ...
    0.1*[-1 1 1 -1], ...
    [0.3, 0.3, 0.3], ...
    'EdgeColor', 'none', ...
    'Parent', hHggroup ...
);




% zpa.hHggroup = hHggroup;
