classdef WagoIOClient < JavaDevice
    
    % np
    
	properties (Constant)
       
        dWidth      = 310 
        ceId        = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
        
    end
    
    properties
        
        hioX
        hioY
        hioZ
        hioRx
        hioRy
        hioRz
        dHeight     
        
    end
    
    properties (SetAccess = private)
    
        
    end
    
    properties (Access = private)
                                
        hPanel
        celAxes
        cName
        clock
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = MotionControl(cName, celAxes, clock)
               
            % cName         char                hardware name, passed into Java
            % celAxes       cell of logical     {x, y, z, rx, ry, rz} which axes to support
            % clock         Clock
            % lShowToggle   logical             show the toggle (connect/disconnect) or not
            
            this.cName      = cName;
            this.celAxes    = celAxes;
            this.clock      = clock;
            
            % JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'MotionControlProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            this.cConstructFcn      = sprintf('MotionControlProxy(''%s'',''iman.lbl.gov'')', cName);
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            
            for k = 1:length(this.ceId)
                if this.celAxes{k}
                    
                    % Build HardwareIO for axis
                    cCode = sprintf( ...
                        'this.hio%s = HardwareIO(''%s-%s'', this.clock, ''%s'')', ...
                        this.ceId{k}, ...
                        this.cName, ...
                        this.ceId{k}, ...
                        this.ceId{k} ...
                    );
               
                    eval(cCode);
                    
                    % Set the API for the axis
                    cCode = sprintf( ...
                        'this.hio%s.api = APIHardwareIOStageXYZRxRyRz(this, ''%s'')', ...
                        this.ceId{k}, ...
                        lower(this.ceId{k}) ...
                    );
                    
                    eval(cCode);
                end
            end 
                      
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % Panel
            
            dSep = 40;
            dTopPad = 20;
            dBotPad = 10;
            
            this.dHeight = dTopPad + Utils.dEDITHEIGHT + 5;
            for k = 1:length(this.celAxes)
                if this.celAxes{k}
                    this.dHeight = this.dHeight + dSep;
                end
            end
            
            this.dHeight = this.dHeight + dBotPad;
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cName,...
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
                        
            
            dCount = 0;
            dOffset = dTopPad + Utils.dEDITHEIGHT + 5;
            for k = 1:length(this.ceId)
                if this.celAxes{k}
                    eval(sprintf( ...
                        'this.hio%s.build(this.hPanel, dLeft, dOffset + %1d*dSep)', ...
                        this.ceId{k}, ...
                        dCount) ...
                    );
                    dCount = dCount + 1;
                end
            end            
                
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
        
        function dReturn = get(this, cAxis)
            % @parameter cAxis 'x', 'rx', 'ry' 
            
            switch cAxis
                case 'x'
                    dReturn = this.jDevice.getAxisPosition(1);
                case 'y'
                    dReturn = this.jDevice.getAxisPosition(2);
                case 'z'
                    dReturn = this.jDevice.getAxisPosition(3);
                case 'rx'
                    dReturn = this.jDevice.getAxisPosition(4);
                case 'ry'
                    dReturn = this.jDevice.getAxisPosition(5);
                case 'rz'
                    dReturn = this.jDevice.getAxisPosition(6);
            end

            
        end
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'rx', 'ry'
            % @parameter dVal
            
            switch cAxis
                case 'x'
                    this.jDevice.setAxisPosition(1, dVal);
                case 'y'
                    this.jDevice.setAxisPosition(2, dVal);
                case 'z'
                    this.jDevice.setAxisPosition(3, dVal);
                case 'rx'
                    this.jDevice.setAxisPosition(4, dVal);
                case 'ry'
                    this.jDevice.setAxisPosition(5, dVal);
                case 'rz'
                    this.jDevice.setAxisPosition(6, dVal);
            end
        end
        
        function stop(this, cAxis)
            
            
            switch cAxis
                case 'x'
                    this.jDevice.stopAxisMove(1);
                case 'y'
                    this.jDevice.stopAxisMove(2);
                case 'z'
                    this.jDevice.stopAxisMove(3);
                case 'rx'
                    this.jDevice.stopAxisMove(4);
                case 'ry'
                    this.jDevice.stopAxisMove(5);
                case 'rz'
                    this.jDevice.stopAxisMove(6);
            end
        end

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardwareIO(this)
            
            for k = 1:length(this.ceId)
                if this.celAxes{k}
                    eval(sprintf('this.hio%s.turnOff()', this.ceId{k}));
                end
            end
            
        end
        
        % Overload
        
        function turnOnHardwareIO(this)
            
            for k = 1:length(this.ceId)
                if this.celAxes{k}
                    eval(sprintf('this.hio%s.turnOn()', this.ceId{k}));
                end
            end
            
        end
        
        
    end % protected
    
    
    methods (Access = private)
        
                
        function handleConnect(this, src, evt)
            
            
        end
        
        function handleDisconnect(this, src, evt)
            
            
        end
            
        
    end
    
    
end