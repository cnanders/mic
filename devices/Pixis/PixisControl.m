classdef PixisControl < JavaDevice
    
    % This javadevice will be used to control Cameras through the java
    % interface.  This class needs a lot of work
    %

            
            
	properties (Constant)
       
        
        
    end
    
    properties
        
        uieROIx1
        uieROIx2
        uieROIy1
        uieROIy2
        uieBinning
        
        hioTemperature
        hioExposureTime
        
        uibSetROIToSelection
        uibResetROI
        
        uibSetTemperature
        uibSetTemperatureHot
        uibSetTemperatureCold
        
        uibSetExposureTime
        uibSetExposureTimeShort
        uibSetExposureTimeLong
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (SetAccess = protected)
        cName      = 'CameraControl';
        dHeight
        dWidth      = 310
        
        
        
        u16ROIx1 = uint16(1);
        u16ROIx2 = uint16(2048);
        u16ROIy1 = uint16(1);
        u16ROIy2 = uint16(2048);
        u8Binning = uint8(1);
        
        bCaptureMode = 0; % 1 for continuous, 0 for single image
        dTemperature = 20; % Celcius
        dExposureTime = 0.1; % Seconds
        
        u16Selection = uint16([1, 2048, 1, 2048]);
    end
    
    properties (Access = protected)
        
        clock
        cJavaName           = 'M141';
        cPanelName          = 'Panel Name';
        
        

    
    end
    
    properties (Access = private)
                                
        hMainPanel
        hROIPanel
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = PixisControl( ...
                clock, ... 
                cJavaName, ...
                cPanelName)
            
            
            
            this.clock          = clock;
            this.cJavaName      = cJavaName;
            this.cPanelName     = cPanelName;
            
            % JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'PixisProxy-0.1b.jar');
            this.cPackage           = 'cxro.common.device.Camera';
            this.cConstructFcn      = sprintf('MotionControlProxy(''Pixis:tcp -h met5-pixis.dhcp.lbl.gov -p 10000)''');
            this.cConnectFcn        = 'initCamera(0)';
            this.cDisconnectFcn     = 'disableAxes()';
            
            
            this.init()
            
        end
        
                
        function build(this, hParent, dLeft, dTop, dColor)
            
            % Panel
            
            dSep = 40;
            dTopPad = 20;
            dBotPad = 10;
            
            this.dHeight = dTopPad + MicUtils.dEDITHEIGHT + 5;
            this.dHeight = this.dHeight + 300;
            this.dHeight = this.dHeight + dBotPad;
            
            this.hMainPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cPanelName,...
                'Clipping', 'on',...
                'BackgroundColor', dColor, ...
                'Position', MicUtils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
            
            this.hROIPanel = uipanel(...
                'Parent', this.hMainPanel,...
                'Units', 'pixels',...
                'Title', 'ROI',...
                'Clipping', 'on',...
                'BorderType', 'none', ...
                'Position', MicUtils.lt2lb([ ...
                0 ...
                dTop + 30 ...
                this.dWidth  ...
                105], this.hMainPanel) ...
            );
            drawnow
            
%             uieBinning
            dLeftCol1       = 10;
            dTop            = 10;
            dROIEditWidth   = 40;
            dROIPad         = 5;
            
            this.uieROIx1.build(this.hROIPanel, dLeftCol1, dTop, dROIEditWidth, MicUtils.dEDITHEIGHT);
            this.uieROIx2.build(this.hROIPanel, dLeftCol1 + dROIEditWidth + dROIPad, dTop, dROIEditWidth, MicUtils.dEDITHEIGHT);
            this.uieROIy1.build(this.hROIPanel, dLeftCol1 + 2*dROIEditWidth + 2*dROIPad, dTop, dROIEditWidth, MicUtils.dEDITHEIGHT);
            this.uieROIy2.build(this.hROIPanel, dLeftCol1 + 3*dROIEditWidth + 3*dROIPad, dTop, dROIEditWidth, MicUtils.dEDITHEIGHT);
            
            this.uieBinning.build(this.hROIPanel, dLeftCol1 + 4*dROIEditWidth + 10*dROIPad, dTop, dROIEditWidth, MicUtils.dEDITHEIGHT);
        
			drawnow;
            
            
            this.uitConnect.build( ...
                this.hMainPanel, ...
                10, ...
                dTopPad, ...
                50, ...
                MicUtils.dEDITHEIGHT);
                        
            % ROI control buttons:
            dTop = dTop + MicUtils.dEDITHEIGHT + 5*dROIPad;
            this.uibSetROIToSelection.build(this.hROIPanel, dLeftCol1, dTop, 3*dROIEditWidth, MicUtils.dEDITHEIGHT);
            this.uibResetROI.build(this.hROIPanel, dLeftCol1 + 3*dROIEditWidth + 2*dROIPad, dTop, 2*dROIEditWidth, MicUtils.dEDITHEIGHT);
        
            % Camera temperature and exposure
            dTop = dTop + 50;
            dTop = dTop + MicUtils.dEDITHEIGHT + 5*dROIPad;
            this.hioTemperature.build(this.hMainPanel, dLeftCol1, dTop);
            
            dTop = dTop + MicUtils.dEDITHEIGHT + 5*dROIPad;
            this.hioExposureTime.build(this.hMainPanel, dLeftCol1, dTop);
            
        end
                 
        
        function show(this)
    
            if ishandle(this.hMainPanel)
                set(this.hMainPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hMainPanel)
                set(this.hMainPanel, 'Visible', 'off');
            end
            
        end 
        
        % Expose hardware methods to the API
        
        function dReturn = get(this, u8JavaIndex)
            
            % @parameter u8JavaIndex (0, 1, 2, 3, ...) 
            
            dReturn = this.jDevice.getAxisPositionRaw(u8JavaIndex);            
        end
        
        function set(this, u8JavaIndex, dVal)
            
            % @parameter u8JavaIndex (0, 1, 2, 3, ...)
            % @parameter dVal
            
            this.jDevice.setAxisTarget(u8JavaIndex, dVal);
            
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
            
            for k = 1:length(this.cehio)
                this.cehio{k}.turnOff();
                
                % eval(sprintf('this.cehio{%1d}.turnOff()', k));
            end
            
        end
        
        % Overload
        
        function turnOnHardware(this)
            
            for k = 1:length(this.cehio)
                this.cehio{k}.turnOn();
                % eval(sprintf('this.cehio{%1d}.turnOn()', k));
            end
            
        end
        
        
        function init(this)
            
            this.uieROIx1       = UIEdit('X1', 'u16');
            this.uieROIx2       = UIEdit('X2', 'u16');
            this.uieROIy1       = UIEdit('Y1', 'u16');
            this.uieROIy2       = UIEdit('Y2', 'u16');
            this.uieBinning     = UIEdit('Binning', 'u8');
            
            this.uibSetROIToSelection    = UIButton('Set ROI to Selection');
            this.uibResetROI             = UIButton('Reset ROI');
            
            this.hioTemperature = HardwareIO('pixis-CCD-temperature', this.clock, 'Temp (C)');
            this.hioExposureTime = HardwareIO('pixis-CCD-exposure', this.clock, 'Exp (s)');
            
            this.uibSetTemperature      = UIButton('Set Temp');
            this.uibSetTemperatureHot   = UIButton('Chill', false, [.7, .2, .2]);
            this.uibSetTemperatureCold  = UIButton('Warm', false, [.2, .2, .7]);
        
            this.uibSetExposureTime     = UIButton('Set Exposure');
            this.uibSetExposureTimeShort = UIButton('Set ROI to Selection');
            this.uibSetExposureTimeLong = UIButton('Set ROI to Selection');
            % Default values:
            this.uieROIx1.setVal(this.u16ROIx1);
            this.uieROIx2.setVal(this.u16ROIx2);
            this.uieROIy1.setVal(this.u16ROIy1);
            this.uieROIy2.setVal(this.u16ROIy2);
            this.uieBinning.setVal(this.u8Binning);
            
            
            
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