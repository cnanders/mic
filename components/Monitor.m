classdef Monitor < HandlePlus
%MONITOR  Monitoring the reading of a sensor (e.g. diode or stage position)
%   Monitor is a class meant to monitor the reading of a sensor or the 
%   position of a stage without interfering too much with the apparatus
%   (i.e. there's no infinite loop, so the stage can be moved)
%   It is mainly meant to be used for troubleshooting purposes, 
%   e.g. when the motion cannot be seen, heard or perceived by
%   conventional means.
% 
% example of use:
%   g = GalilXZ() %x2;
%   g.build(gcf,0,0)
%   m = Monitor('Galil',g.cl,@() g.positionRAW(1));
%   m.build();
%   m.sampling_freq_Hz = 5;
%   m.duration_s = 10;
%   m.refreshRate_s = 0.2;
%
% See also AXIS, DIODE, CLOCK, SCAN

%   Last update : May 2016
%   Antoine Wojdyla - CXRO/LBNL
%   awojdyla@lbl.gov

    %% Properties
    properties (Constant)
        dWidth = 560    % width of the UIElement
        dHeight = 420   % height of the UIElement
    end
    
	properties (Dependent = true)
        dPeriod_ms      % sampling period
    end

    properties
        duration_s = 10         % monitor window time length
        sampling_freq_Hz = 5    % reading frequency
        fhReadSensor            % function handle for reading
        cl                      % general clock
        filename = 'temp'       % filename for data acquisition purposes
        
        refreshRate_s = 0.2     % figure refrsh rate
        
        time_array              % array that time-stamps the data    
        data_array              % array that contains the data
    end

    properties (SetAccess = private)     
        cName       % name identifier
        hParent     % parent figure handle
        hUI         % panel handle
        hAxes       % axes handle (where the readings plot)
        isRunning = false;
    end

    properties (Access = private)
        idx = 1         % index counter
        lastRefresh_s   % time counter for the last refresh time (relative)
        lIsAcquiring = false % boolean to trigger data acquisition
        
        uibStart % start/stop
        uibClear % 'Clear' button
    end

    events
    end
    

    %% Methods
    
    methods        
        %% Constructor
        function this = Monitor(cName, cl, fhReadSensor)
        %MONITOR Class constructor
        %   my_monitor = Monitor('name', clock, fhReadSensor)
        %       'name' is the Monitor identifier
        %       clock is a general clock for asynchronous operation    
        %       fhReadSensor is a function handle to the sensor 'read' fcn
        %           (out = fhReadSensor())
        % See also INIT, BUILD, DELETE
        
        %Easy setup
        if nargin ==1
            fhReadSensor = cName;
            cName = 'Easy';
            cl = Clock('Easy Monitor');
        end
        
        
            this.cName = cName;
            this.cl = cl;
            
            if length(fhReadSensor)==1
                this.fhReadSensor{1} = fhReadSensor;
            else
                this.fhReadSensor = fhReadSensor;
            end
            
            this.init();
            
            if nargin==1
                this.build
            end
            
        end


        function init(this)
        %INIT Initializes the Monitor
        %   Monitor.init()
        %
        % See also MONITOR, DUILD, DELETE
        
            this.start()
        end

        function start(this)
        %START Starts the monitor
        %   Monitor.start()
        %
        % See also STOP
        
            if ~isempty(this.cl)
                if ~this.cl.has([class(this),':',this.cName])
                    this.cl.add(@this.handleClock, [class(this),':',this.cName], this.dPeriod_ms);
                    this.isRunning = true;
                else
                    disp('Monitor.start : the monitor is already on the Clock tasklist.')
                end
            else
                disp('Monitor.start : there is no clock associated with this Monitor.')
            end
        end
        
        function stop(this)
        %STOP Stops/Pause the Monitor
        %   Monitor.stop()
        %
        % See also START
        
            if ~isempty(this.cl) && isvalid(this.cl)
                if this.cl.has([class(this),':',this.cName])
                    this.cl.remove([class(this),':',this.cName]);
                    this.isRunning = false;
                else
                    disp('Monitor.stop : the monitor is not running')
                end
            else
                disp('Monitor.stop : there is no clock associated with this Monitor.')
            end
            
        end
        
        function clear(this)
            this.idx = 1;
            for i_dim = 1:length(this.fhReadSensor)
                this.data_array(i_dim,:) = this.data_array(i_dim,this.idx);
            end
        end
        
        
        function toggle(this,~,~,~)
            if this.isRunning
                this.stop();
            else
                this.start();
            end
        end
        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the Monitor UIelement
        %   Monitor.build(hParent, dLeft, dTop)
        %
        % See also MONITOR, INIT, DELETE
            
            if nargin == 1
                this.hParent = figure('DeleteFcn',@(x,y,z) this.stop() );
            else
                this.hParent = hParent;
            end
            
            if nargin < 3
                dLeft = 0;
                dTop = 0;
            end

            width  = Monitor.dWidth;
            height = Monitor.dHeight;
            pos = get(this.hParent,'Position');
%             if pos(3)<width
%                 width = pos(3);
%             end
%             if pos(4)<width
%                 width = pos(4);
%             end
            
            this.hUI = uipanel(...
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'BorderWidth',0,... 'BackgroundColor',[0 0 0],...
                'Position', [dLeft dTop width height]...
                );
            
            this.hAxes = axes(...
                'Parent', this.hUI,...
                'ButtonDownFcn',@this.toggle);
            %'Position', Utils.lt2lb([dLeft dTop Monitor.dWidth Monitor.dHeight], hParent) ...
            drawnow
            
            this.uibClear = uicontrol(...
                'Parent',this.hUI,...
                'Style','pushbutton','String','clear',...
                'FontName','Arial','FontSize',10,...
                'BackgroundColor',[1 1 1],...
                'Units', 'pixels', 'Position',[0 0 40 20],...
                'Callback',@(~,~,~) this.clear());
            
        end
        
        
        function handleClock(this)
            %HANDLECLOCK Callback used by the clock to update the monitor
            % example
            %   this.cl.add(@this.handleClock, [class(this),':',this.cName], this.dPeriod_ms);
            
            this.update_data();
            this.update_display();
        end
        
        function update_data(this)
            try
                for i_dim=1:length(this.fhReadSensor)
                    if ~isempty(this.fhReadSensor{i_dim})
                        this.data_array(i_dim,this.idx) = this.fhReadSensor{i_dim}();
                    else
                        this.data_array(i_dim,this.idx) = 0;
                    end
                end
            catch err
                for i_dim=1:length(this.fhReadSensor)
                    this.data_array(i_dim,this.idx) = -1;
                end
                disp('Monitor:read error')
                warning(err.message)
            end
            %TODO : allow for time-stamping
            if this.lIsAcquiring && this.idx == length(this.time_array)
                this.lIsAcquiring = false;
                this.saveToFile(this.filename)
            end
            
            this.idx = mod(this.idx, length(this.time_array))+1;
        end
        
        function update_display(this)
            if isempty(this.lastRefresh_s) || (toc(this.lastRefresh_s))>this.refreshRate_s
                this.lastRefresh_s = tic;
                
                mask = cellfun('isempty',this.fhReadSensor);                
                if sum(~mask)<1
                    mask =0;
                end
                
                if ~isempty(this.hAxes) && ishandle(this.hAxes)
                    plot(this.hAxes, this.time_array, this.data_array(~mask,:), '.-')
                    axis(this.hAxes,'tight')
                    grid(this.hAxes,'on')
                    xlabel(this.hAxes,'time [s]')
                    ylabel(this.hAxes,'signal [a.u.]')
                    title(this.hAxes,sprintf('Monitoring : %s, i = %i ',this.cName, this.idx))
                    drawnow;
                end
            end
        end
        
        function acquire(this)
            if ~this.lIsAcquiring
                this.lIsAcquiring = true;
                this.idx = 1;
            end
        end
        
        function saveToFile(this, filename)
        %SAVETOFILE Saves the currently scanned data to a file
        %   Monitor.saveToFile('filename')
        %
        % See also ACQUIRE

            time_s = this.time_array;
            data = this.data_array;
            save(filename, 'time_s', 'data') 
        end

        function dPeriod = get.dPeriod_ms(this)
            dPeriod = 1/this.sampling_freq_Hz;
        end
        
        
        function time_array = get.time_array(this)
            if isempty(this.time_array)
                time_array = linspace(0,this.duration_s,round(this.duration_s*this.sampling_freq_Hz));
            else
                time_array = this.time_array;
            end
        end
        
        
        function data_array = get.data_array(this)
            if isempty(this.data_array)
                data_array = zeros(length(this.fhReadSensor),length(this.time_array));
                for i_dim=1:length(this.fhReadSensor)
                    data_array(i_dim,:) = this.time_array*0+this.fhReadSensor{i_dim}();
                end
            else
                data_array = this.data_array;
            end
        end
               
        
        function set.duration_s(this, value)
            this.duration_s = value;
            this.updateBounds();
        end
        
        
        function set.sampling_freq_Hz(this, value)
            this.stop()
            this.sampling_freq_Hz = value;
            this.updateBounds()
            this.start()
        end


        function delete(this)
        %DELETE Class destructor
        %   Monitor.delete()
        %
        % See also MONITOR, INIT, BUILD
        
            %this.stop()
        end
        
    end % public methods
    
    methods(Access = private)
        
        function updateBounds(this)
            %UPDATEBOUNDS Updates the time and data array
            %   Monitor.updateBounds()
            
            this.time_array = linspace(0,this.duration_s, this.duration_s*this.sampling_freq_Hz);
            tmp = this.data_array;
            this.data_array = zeros(length(this.fhReadSensor),length(this.time_array));
            for i_dim=1:length(this.fhReadSensor)
                this.data_array(i_dim,:) = this.time_array.*0+this.fhReadSensor{i_dim}();
                this.data_array(1:min([this.idx, size(tmp,2), size(this.data_array,2)])) = ...
                    tmp(1:min([this.idx, size(tmp,2), size(this.data_array,2)]));
            end
            this.idx = mod(this.idx, length(this.time_array))+1;
        end
        
    end %private methods

end

