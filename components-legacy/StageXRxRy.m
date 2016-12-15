classdef StageXRxRy < JavaDevice
        
	properties (Constant)
       
        dWidth      = 310 
        dHeight     = 190
        
    end
    
    properties
        
        hioX
        hioRx
        hioRy
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                                
        hPanel
        
    end
    
        
    events
        
        
    end
    

    
    methods
                
        function this = StageXRxRy( ...
                cJarPath, ...
                cPackage, ...
                cConstructFcn, ...
                cConnectFcn, ...
                cDisconnectFcn, ...
                cName, ...
                clock)
            
            this.msg('init');
                        
            this.cJarPath           = cJarPath;
            this.cPackage           = cPackage;
            this.cConstructFcn      = cConstructFcn;
            this.cConnectFcn        = cConnectFcn;
            this.cDisconnectFcn     = cDisconnectFcn;
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            this.hioX   = HardwareIO([cName,'-X'], clock, 'X');
            this.hioRx  = HardwareIO([cName,'-Rx'], clock, 'Rx');
            this.hioRy  = HardwareIO([cName,'-Ry'], clock, 'Ry');
            
            this.hioX.api   = APIHardwareIOStageXYZRxRyRz(this, 'x');
            this.hioRx.api  = APIHardwareIOStageXYZRxRyRz(this, 'rx');
            this.hioRy.api  = APIHardwareIOStageXYZRxRyRz(this, 'ry');
                        
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M141 X, Rx, Ry',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;
            
            dButtonWidth = 94;
            dButtonSep = 5;
            dTop = 20;
            
            this.uitConnect.build( ...
                this.hPanel, ...
                10 + 0*(dButtonSep + dButtonWidth), ...
                dTop, ...
                dButtonWidth, ...
                MicUtils.dEDITHEIGHT);
                        
            dSep = 40;
            dLeft = 10;
            dOffset = 60;
                
            this.hioX.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioRx.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioRy.build(this.hPanel, dLeft, dOffset + 2*dSep);
    
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
        
        % Overload
        
        function dReturn = get(this, cAxis)
            % @parameter cAxis 'x', 'rx', 'ry' 
            
            switch cAxis
                case 'x'
                    dReturn = this.jDevice.getAxisPosition(1);
                case 'rx'
                    dReturn = this.jDevice.getAxisPosition(2);
                case 'ry'
                    dReturn = this.jDevice.getAxisPosition(1);
            end

            
        end
        
        % Overload
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'rx', 'ry'
            % @parameter dVal
            
            switch cAxis
                case 'x'
                    this.jDevice.setAxisPosition(1, dVal);
                case 'rx'
                    this.jDevice.setAxisPosition(2, dVal);
                case 'ry'
                    this.jDevice.setAxisPosition(1, dVal);
            end
        end
        
        % Overload
        
        function stop(this, cAxis)
            
            
            switch cAxis
                case 'x'
                    this.jDevice.stopAxisMove(1);
                case 'rx'
                    this.jDevice.stopAxisMove(2);
                case 'ry'
                    this.jDevice.stopAxisMove(1);
            end
        end

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardwareIO(this)
            
            
            this.hioX.turnOff();
            this.hioRx.turnOff();
            this.hioRy.turnOff();
            
            
        end
        
        % Overload
        
        function turnOnHardwareIO(this)
            
            
            this.hioX.turnOn();
            this.hioRx.turnOn();
            this.hioRy.turnOn();
            
            
        end
        
        
        function handleConnect(this, src, evt)
            
            
        end
        
        
        function handleDisconnect(this, src, evt)
            
            
        end
        
        
    end % protected
    
    
    methods (Access = private)
        
        
        
            
        
    end
    
    
end