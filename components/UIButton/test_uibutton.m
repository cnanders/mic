
[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Mic
cDirMic = fullfile(cDirThis, '..', '..');
addpath(genpath(cDirMic));

purge

cPathImg = fullfile(MicUtils.pathAssets(), 'axis-zero-24-2.png');
cPathImg = fullfile(MicUtils.pathAssets(), 'loading-24px.gif');

% u8Zero = imread(cPathImg);
% u8Zero = imread(cPathImg);

[X,map] = imread(cPathImg, 'GIF');
imshow(X,map)


uib = UIButton( ...
    'Zero', ...
    true, ...
    u8Zero ...
);

h = figure;
uib.build(h, 10, 10, 24, 24);
