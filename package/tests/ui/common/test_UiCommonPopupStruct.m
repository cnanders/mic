[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..');

% Add mic
addpath(genpath(cDirMic));

purge

u8Num = 8;
ceOptions = cell(1, u8Num);
for n = 1 : u8Num
                
    stOption = struct( ...
        'cLabel', sprintf('Val %1.0f', n), ...
        'cVal', n ...
    );
    ceOptions{n} = stOption;

    fprintf('{\n');
    fprintf('"name": "%d",\n', n);
    fprintf('"raw": %d\n', n);
    fprintf('},\n');
  
end
            
h = figure();

uiPopup = mic.ui.common.PopupStruct( ...
    'ceOptions', ceOptions ...
);

uiPopup.build(h, 10, 10, 300, 30);

cb = @(src, evt) (fprintf('mic.ui.common.Popup eChange to item %1d\n', src.u8Selected));
addlistener(uiPopup, 'eChange', cb);

