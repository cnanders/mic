%% General purpose test script
    % Do whatever you want here...



%% scroll control test
set(gcf,'WindowScrollWheelFcn',@MicUtils.scroll_increment)

%% making all object courier instead of MS sans Serif

list = findobj('FontName','MS Sans Serif');
for i=1:length(list)
    set(list(i),'FontName','courier')
end
drawnow


%%

clock = Clock('Clock');

hs = HeightSensor('Height Sensor',clock);

%%
hs.build();

%%
xx = findall(ho.setup.hFigure,'Style','uipanel')



while(get(master_handle,'Parent')~=0)
    master_handle = get(master_handle,'Parent');
end
eboxes = findall(master_handle,'Style','edit');