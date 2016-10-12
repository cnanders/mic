classdef TempSensor < JavaDevice
            
	properties (Constant)
               
    end
    
    properties
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (SetAccess = protected)
        cName      = 'TempSensor';
        dHeight
        dWidth      = 310
    end
    
    properties (Access = protected)
        
        clock
        cJavaName           = 'PO';               % Data Translation Unit 1
        u8JavaIndex         = uint8([0, 1]);        % The indexes of the implemented Java VoltMeter class that will be used
        cecUIDispName       = {'1', '2'};      % (cell of char) name of each axes for display and and clock purposes
        cecUIType           = {'ho', 'ho'};  
        cex                 % cell of UI elements (HardwareIOToggle, HardwareO, Diode)
        cPanelName          = 'Panel Name';
    
    end
    
    properties (Access = private)
                                
        hPanel

    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TempSensor( ...
                clock, ... 
                cJavaName, ...
                u8JavaIndex, ...
                cecUIDispName, ...
                cecUIType, ...
                cPanelName ...
        )
            
            % Default inputs
            
            if ~exist('cJavaName', 'var')
                cJavaName = this.cJavaName;
            end
            
            if ~exist('u8JavaIndex', 'var')
                u8JavaIndex = this.u8JavaIndex;
            end
            
            if ~exist('cecUIDispName', 'var')
                cecUIDispName = this.cecUIDispName;
            end
            
            if ~exist('cecUIType', 'var')
                cecUIType = this.cecUIType;
            end
            
            if ~exist('cPanelName', 'var')
                cPanelName = this.cPanelName;
            end
            
            % Override properties with inputs
            
            this.clock              = clock;
            this.cJavaName          = cJavaName;
            this.u8JavaIndex        = u8JavaIndex;
            this.cecUIDispName      = cecUIDispName;
            this.cecUIType          = cecUIType;
            this.cPanelName         = cPanelName;
            
            % Modular Java properties
            this.cJarPath           = fullfile(pwd, 'TempSensor.jar');
            this.cPackage           = 'cxro.common.device';
            this.cConstructFcn      = sprintf('TempSensor(''%s'',''iman.lbl.gov'')', this.cJavaName);
            
            % Singular Java properties
            this.cConstructFcn2     = sprintf('getTempSensor(''%s'')', this.cJavaName);
            
            % Common Java properties
            this.cConnectFcn        = 'enable()';
            this.cDisconnectFcn     = 'disable()';
            
            for k = 1:length(this.cecUIDispName)
                                    
                % Build HardwareIO for axis
                
                switch this.cecUIType{k}
                    
                    case 'ho'
                        this.cex{k} = HardwareO(...
                            sprintf('%s-%s', this.cJavaName, this.cecUIDispName{k}), ...
                            this.clock, ...
                            this.cecUIDispName{k} ...
                        );
                    
                        
                end
                        

                % Set the API for the axis.  Pass in the index of the
                % implemented Java MotionControl class that is associated
                % with this axis direction
                
                this.cex{k}.api = APITempSensor(this, this.u8JavaIndex(k));
                    
                
            end
            
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % Panel
            
            dSep = 28;
            dTopPad = 20;
            dBotPad = 10;
            
            this.dHeight = dTopPad + Utils.dEDITHEIGHT + 5;
            for k = 1:length(this.cecUIDispName)
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
            for k = 1:length(this.cecUIDispName)                
                this.cex{k}.build(this.hPanel, dLeft, dOffset + (k - 1)*dSep);                
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
        
        function dReturn = get(this, u8JavaIndex)
            
            % @parameter u8JavaIndex (0, 1, 2, 3, ...) 
            
            dReturn = this.jDevice.get(u8JavaIndex);            
        end
        
                
        function lReturn = isEnabled(this)
            lReturn = this.jDevice.isEnabled();
        end

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardware(this)
            
            for k = 1:length(this.cex)
                this.cex{k}.turnOff();
            end
            
        end
        
        % Overload
        
        function turnOnHardware(this)
            
            for k = 1:length(this.cex)
                this.cex{k}.turnOn();
            end
            
        end
        
        
        function init(this)
            
            
            
        end
        
        
        
        
        
    end % protected
    
    
    methods (Access = private)
        
                
        
        
    end
    
    
end