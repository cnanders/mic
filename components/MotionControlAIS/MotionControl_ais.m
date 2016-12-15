classdef MotionControl_ais < JavaDevice_ais
    % This wraps the MotionControl Java class.  Every piece of hardware
    % that behaves like a stage is controlled by a MotionControl Java
    % instance instantiated like this:
    %
    % mc = MotionControl('M141', 'iman.lbl.gov')
    %
    % In general, I'll only call a few methods of the MotionControl class
    % shown below. An intiger index is passed to the methods to indicate
    % which channel of the hardware is being accessed.  Java uses
    % zero-indexing.  An exmple is 0 == x, 1 == y, 2 == z.  The index <==>
    % device axis mapping is device dependent.
    %
    % ** getAxisPositionRaw(u8JavaIndex);
    % ** setAxisTarget(u8JavaIndex, dVal);
    % ** stopAxisMove(u8JavaIndex);
    % ** getAxesIsEnabled(); Does this require u8JavaIndex?
    %
    %
    % This class builds a HardwareIO for every control axis passed in and
    % stores them in a cell of HardwareIO.  It also assigns the api propery
    % of every HardwareIO as an APIHardwareIOMotionControl instance, which
    % calls methods of this instance
    %
    % Every hardware class I build will create a MotionController instance
    % and then expose some of its properties as hioX, hioY, for ease of 
    % use throughout the codebase
    %
    % Recall that the JavaDevice class, which this extends, has the 
    % uitConnect toggle. When that changes, it calls turnOnHardwareIO which
    % this class overloads.  In addition, whenever a connect or disconnect
    % happens, JavaDevice dispatches 'eConnect' and 'eDisconnect'.  This
    % class could listen for theose events, but there is nothing additionl
    % that needs to be done
            
            
	properties (Constant)
    end
    
    properties
    end
    
    properties (SetAccess = private)
    end
    
    properties (SetAccess = protected)
        cName      = 'MotionControl';
        cServerName = 'iman.lbl.gov';
    end
    
    properties (Access = protected)
        clock
        cJavaName           = 'M141';
        u8JavaIndex         = uint8([0, 1]);    % The indexes of the implemented Java MotionControl class that will be used
        cPanelName          = 'Panel Name';
        cecUIDispName       = {'X', 'Y'};       % (cell of char) name of each axes for display and and clock purposes
        cecUIType           = {'hio', 'hio'}    % hio, hios
        cehio               % cell of HardwareIO 
    end
    
    properties (Access = private)                       
        hPanel
    end
     
    events
    end
    
    methods
        
        function this = MotionControl_ais( ...    
                clock, ... 
                cJavaName, ...
                u8JavaIndex, ...
                cPanelName, ...
                cecUIDispName, ...
                cecUIType, ...
                cServerName)
         %MOTIONCONTROL Class Constructor
         %  mc = MotionControl(clock, JavaName,JavaIndex, ...
         %       panelName, UIDispName, UIType, ServerName)
            
            if ~exist('cecUIType', 'var')
                cecUIType = cell(1, length(cecUIDispName));
                for n = 1:length(cecUIDispName)
                    cecUIType{n} = 'hio';
                end
            end
            
            if ~exist('cServerName', 'var')
                % Then set server name to the default name:
                cServerName = this.cServerName;
            end
            
            this.clock          = clock;
            this.cJavaName      = cJavaName;
            this.u8JavaIndex    = u8JavaIndex;
            this.cPanelName     = cPanelName;
            this.cecUIDispName  = cecUIDispName;
            this.cecUIType      = cecUIType;
            this.cServerName    = cServerName;
            
            % JavaDevice properties (defined in the superclass Javadecice)
            this.cJarPath           = fullfile(pwd, 'MotionControlProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            this.cConstructFcn      = sprintf('MotionControlProxy(''%s'',''%s'')', this.cJavaName, this.cServerName);
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
            
            this.init();
        end
        
        function init(this)
        %INIT Initializes the MotionControl class (empty)
        %             addlistener(this, 'eConnect', @this.handleConnect);
        %             addlistener(this, 'eDisconnect', @this.handleDisconnect);
            for k = 1:length(this.cecUIDispName) % Build HardwareIO for axis
                switch this.cecUIType{k}
                    case 'hio'
                        this.cehio{k} = HardwareIO(...
                            sprintf('%s-%s', this.cJavaName, this.cecUIDispName{k}), ...
                            this.clock, ...
                            this.cecUIDispName{k} ...
                            );
                    case 'hios'
                        this.cehio{k} = HardwareIOWithSave(...
                            sprintf('%s-%s', this.cJavaName, this.cecUIDispName{k}), ...
                            this.clock, ...
                            this.cecUIDispName{k} ...
                            );
                end
                
                % Set the API for the axis.  Pass in the index of the
                % implemented Java MotionControl class that is associated
                % with this axis direction
                this.cehio{k}.api = APIHardwareIOMotionControl(this, this.u8JavaIndex(k));              
            end
            
        end
        
        function set_javaparams(this, cJarPath, cPackage, cConstructFcn, cConnectFcn)
        %SET_JAVAPARAMS Set Java paramaters for (for connection)
        %   MotionControl.set_javaparams(cJarPath, cPackage, cConstructFcn)
        %
        % See also MOTIONCONTROL.SET_SERVER
        
            this.cJarPath           = cJarPath;
            this.cPackage           = cPackage;
            this.cConstructFcn      = cConstructFcn;
            this.cConnectFcn        = cConnectFcn;
        end
        
        function set_server(this,cServerName)
        %SET_SERVER Set server name
        %   MotionControl.set_server(server_name)
        %
        % See also MOTIONCONTROL.SET_SERVER
            
            this.cServerName = cServerName;
        end
        
        function isHomed(this)
        %ISHOMED Tells if the stage is homes/initialized/referenced
        %  isHomed = MotionControl_ais.isHomed()
        %
        % See also MotionControl_ais.homeAxes
        
            this.dReturn = this.jDevice.smarpod.getAxisIsInitialized;
        end
        
        function dReturn = homeAxes(this)
        %HOMEAXES Homing the axes (intialization of the stage)
        %   MotionControl_ais.homeAxes()
        %
        % See also MotionControl_ais.isHomed
            
        % aw 03/07/16
        %removed 'this.' and added dReturn in the function prototype
            dReturn = this.jDevice.initializeAxes();
        end
        
        
        
                
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the user interface for the MotionControl class
        %   MotionControl.build(parent_handle, left_pos, top_pos)
        %       builds the UI element on a parent handle, with positionning
        % 
        % See also MotionControl.show, MotionControl.hide
        
        
        if this.ais_fork
            if nargin ==1
                hParent = figure('name', 'Motion control',...
                    'Units', 'pixels',...
                    'Position', [100 100 350 350],...
                    'numberTitle','off',...
                    'Toolbar','none',...
                    'handlevisibility','off');
            dLeft = 0;
            dTop = 0;
            end
        end
        
        dWidth = 300;
        
            % Panel
            dSep = 40;
            dTopPad = 20;
            dBotPad = 10;
            
            dHeight = dTopPad + MicUtils.dEDITHEIGHT + 5;
            for k = 1:length(this.cecUIDispName)
                dHeight = dHeight + dSep;
            end
            
            dHeight = dHeight + dBotPad;
            %Container panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cPanelName,...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dLeft dTop dWidth dHeight], hParent) ...
                );
            
            %"Connect" toggle button
            this.uitConnect.build(this.hPanel, 10, dTopPad, 50, MicUtils.dEDITHEIGHT);
            
            %Filling the panel with all elements
            dOffset = dTopPad + MicUtils.dEDITHEIGHT + 5;
            for k = 1:length(this.cecUIDispName)                
                this.cehio{k}.build(this.hPanel, dLeft, dOffset + (k - 1)*dSep);
            end            
            drawnow;
        end
                
        
        function show(this)
        %SHOW Shows the UI element corresponding to the class
        %   MotionControl.show() works if the class is already built
        %
        % See also MotionControl.hide, MotionControl.build
    
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
                drawnow;
            end
        end

        function hide(this)
        %Hide Hides the UI element corresponding to the class
        %   MotionControl.hide() works if the class is already built
        %
        % See also MotionControl.show, MotionControl.build

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
                drawnow
            end
        end 
        
        % Expose hardware methods to the API
        function lIsReady = isReady(this, u8JavaIndex)
        %ISREADY Tells if the stage is ready to perform a motion
        %   isReady = MotionControl.isReady
        %
        % See also ...
        
            % Change this to axis is ready when vamsi implements this
            if ~this.ais_fork
                lIsReady = ~this.jDevice.getAxisIsStopped(u8JavaIndex);
            else
                lIsReady = this.jDevice.getAxisIsReady(u8JavaIndex);
            end
        end
        
        %TODO get all axis positon
        %FIXME : should be named "get position", should have "raw"
        %FIXME : causes a lot of prblem with the clock
        function dReturn = get(this, u8JavaIndex)
            %GET Get single axis position, in raw units
            %   position_raw = MotionControl.get(axis_index)
            %       with axis_index = {0, 1, 2, 3, ...}
            %
            % See also MotionControl.set, MotionControl.stop
            if ~isempty (this.jDevice)
                if ~this.ais_fork
                    dReturn = this.jDevice.getAxisPositionRaw(u8JavaIndex);
                else
                    dReturn = this.jDevice.getAxisPosition(u8JavaIndex);
                end
            else
                warning('unable to get position from : %s',this.cName)
            end
        end
        
        function set(this, u8JavaIndex, dVal)
        %SET Set single axis position
        %   MotionControl.set(axis_index, position_raw)
        %
        % See also MotionControl.get, MotionControl.stop
            
            if ~this.ais_fork
                this.jDevice.setAxisTarget(u8JavaIndex, dVal);
            else
                this.jDevice.moveAxisAbsolute(u8JavaIndex, dVal);
            end
        end
        
        function stop(this, u8JavaIndex)
        %STOP Stop a single axis motion
        %   MotionControl.stop(axis_index)
        %       with axis_index = {0, 1, 2, 3, ...}
        %
        % See also MotionControl.get, MotionControl.set
        
            this.jDevice.stopAxisMove(u8JavaIndex);    
        end
        
        function lReturn = getAxesIsEnabled(this)
        %GETAXESENABLED Check whether an axis is enables
        %   isEnabled = MotionControl.getAxesIsEnabled()
        %
        % See also MotionControl.get, MotionControl.set
            lReturn = this.jDevice.getAxesIsEnabled();
        end

    end
    
    methods (Access = protected)
        
        function turnOnHardware(this)
        %TURNONHARDWARE Turn on the components (HardwareIO as properties)
        %---this method is an overload from JavaDevice.turnOnHardware()---
        %   MotionControl.turnOnHardware()
        %
        % See also MotionControl.TurnOffHardware, JavaDevice.TurnOnHardware
            
            for k = 1:length(this.cehio)
                this.cehio{k}.turnOn();
                % eval(sprintf('this.cehio{%1d}.turnOn()', k));
            end
        end
                
        function turnOffHardware(this)
        %TURNOFFHARDWARE Turn off the components (HardwareIO as properties)
        %---this method is an overload from JavaDevice.turnOffHardware()---
        %   MotionControl.turnOffHardware()
        %
        % See also MotionControl.TurnOfnHardware, JavaDevice.TurnOffHardware    
            
            for k = 1:length(this.cehio)
                this.cehio{k}.turnOff();
            end
        end

    end 
    
    
    methods (Access = private)
%         function handleConnect(this, src, evt)
%         end
%         function handleDisconnect(this, src, evt)
%         end
    end
     
end