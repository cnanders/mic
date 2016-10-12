classdef MultipleAxesControl < JavaDevice
    
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
        dHeight
        dWidth      = 310;
        
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
        ghio                % global HIO that controls parallel motion
        dNumIOs             % Number of axes controlled by this controller
    
    end
    
    properties (Access = private)
                                
        hPanel

    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = MultipleAxesControl( ...
                clock, ... 
                cJavaName, ...
                u8JavaIndex, ...
                cPanelName, ...
                cecUIDispName, ...
                cecUIType, ...
                cServerName)
            
            this.dNumIOs = length(cecUIDispName);
            if ~exist('cecUIType', 'var')
                
                cecUIType = cell(1, this.dNumIOs);
                for n = 1:this.dNumIOs
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
            
            % JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'MotionControlProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            this.cConstructFcn      = sprintf('MotionControlProxy(''%s'',''%s'')', this.cJavaName, this.cServerName);
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
            
            
            
            for k = 1:this.dNumIOs
                                    
                % Build HardwareIO for axis
                
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
            
            % Create global hio:
            cGhioName = sprintf('%s-global', this.cJavaName);
            this.ghio = GlobalHardwareIO(...
                            cGhioName, ...
                            this.clock, ...
                            'Global' ...
                            );
                        
            % Set both api and apiv here so that we can pass the parent
            this.ghio.api   = APIGlobalHardwareIO(this);
            this.ghio.apiv  = APIVGlobalHardwareIO(this, cGhioName, zeros(1,this.dNumIOs), this.clock);
            
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % Panel
            
            dSep = 40;
            dTopPad = 20;
            dBotPad = 10;
            
            this.dHeight = dTopPad + Utils.dEDITHEIGHT + 5;
            for k = 1:length(this.cecUIDispName) + 1
                this.dHeight = this.dHeight + dSep;
            end
            
            this.dHeight = this.dHeight + dBotPad;
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cPanelName,...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;
            
            
            this.uitConnect.build( ...
                this.hPanel, ...
                10, ...
                dTopPad, ...
                50, ...
                Utils.dEDITHEIGHT);
                        
            
            dOffset = dTopPad + Utils.dEDITHEIGHT + 5;
            for k = 0:length(this.cecUIDispName)
                
                if k == 0 % First time build global
                    this.ghio.build(this.hPanel, dLeft, dOffset);
                else
                    this.cehio{k}.build(this.hPanel, dLeft, dOffset + (k)*dSep);
                end
               
            end            
                
        end
        
        % Methods to poll children status
        function dDest = getChildrenDest(this)
            dDest = zeros(1, this.dNumIOs);
            for k = 1:this.dNumIOs
                dDest(k) = this.cehio{k}.dDest;
            end
        end
        
        function setChildrenAPIVPos(this, dPosVals)
            for k = 1:this.dNumIOs
                this.cehio{k}.apiv.dPos = dPosVals(k);
            end
        end
        function setChildrenAPIVDest(this, dDestVals)
            for k = 1:this.dNumIOs
                this.cehio{k}.apiv.dDest = dDestVals(k);
            end
        end
        
        function lAreReady = areChildrenReady(this)
            lIsReady = zeros(1,this.dNumIOs);
           for k = 1:this.dNumIOs
                lIsReady(k) = this.cehio{k}.lIsThere();
            end
            lAreReady = all(lIsReady);
        end
        
        function lAreThere = areChildrenThere(this)
            lIsThere = zeros(1,this.dNumIOs);
            for k = 1:this.dNumIOs
                lIsThere(k) = this.cehio{k}.lIsThere();
            end
            lAreThere = all(lIsThere);
        end
        

        
        function show(this)
    
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end
            
        end 
        
        % Expose hardware methods to the API
        function lIsReady = isReady(this, u8JavaIndex)
            % Change this to axis is ready when vamsi implements this
            lIsReady = this.jDevice.getAxisIsStopped(u8JavaIndex);
        end
        function dReturn = get(this, u8JavaIndex)
            
            % @parameter u8JavaIndex (0, 1, 2, 3, ...) 
            
            % Get all axes, then return the requested element
            dAllPos = this.jDevice.getAxesPositionRaw();
            dReturn = dAllPos(u8JavaIndex + 1);            
        end
        
        function dReturn = getAll(this)
            dReturn = this.jDevice.getAxesPositionRaw();
        end
        
        function set(this, u8JavaIndex, dVal)
            
            % @parameter u8JavaIndex (0, 1, 2, 3, ...)
            % @parameter dVal
            
            % First get all axes positions, then set them with the updated
            % value
            dAllPos = this.jDevice.getAxesPositionRaw();  
            dAllPos(u8JavaIndex + 1) = dVal;
            this.jDevice.setAxesTarget(dAllPos);
            
        end
        
        function dReturn = setAll(this)
            % Set all reads from the destinations of its HIOs
            dReturn = this.jDevice.setAxesTarget(this.getChildrenDest());
        end
        
        function stop(this, u8JavaIndex)
            this.jDevice.stopAxisMove(u8JavaIndex);
            
        end
        
        function lReturn = getAxesIsEnabled(this)
            lReturn = this.jDevice.getAxesIsEnabled();
        end

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardware(this)
            this.ghio.turnOff();
            for k = 1:length(this.cehio)
                this.cehio{k}.turnOff();
                
                % eval(sprintf('this.cehio{%1d}.turnOff()', k));
            end
            
            
        end
        
        % Overload
        
        function turnOnHardware(this)
            this.ghio.turnOn();

            for k = 1:length(this.cehio)
                this.cehio{k}.turnOn();
                % eval(sprintf('this.cehio{%1d}.turnOn()', k));
            end
            
        end
        
        
        function init(this)
            
            %{
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            %}
            
            
            
        end
        
        
        
        
        
    end % protected
    
    
    methods (Access = private)
        
                
        %{
        function handleConnect(this, src, evt)
            
            
        end
        
        function handleDisconnect(this, src, evt)
            
            
        end
        %}
            
        
    end
    
    
end