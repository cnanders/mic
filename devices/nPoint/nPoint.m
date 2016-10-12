classdef nPoint < JavaDevice
    
    % np
    
	properties
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                
        hioCh1P
        hioCh1I
        hioCh1D
        
        hioCh2P
        hioCh2I
        hioCh2D
        
        cl
        cJavaName             % name of device (use to construct proper Java instance)
        
        
        hPanel
        uitEnable
        uitStart
                
    end
    
        
    events
        
        
    end
    

    
    methods
        
        % 2014.02 Need to pass in additional flat 'pupil', 'field' that
        % will let us construct a jDevice that talks to a different
        % physical nPoint scanners maybe the cxro.common.device.nPointProxy();
        % method can take an argument that determines which device it is
        % connected to
        
        function this = nPoint(cl, cJavaName)
            
            this.cl = cl;
            this.cJavaName = cJavaName;
            this.init();  % all JavaDevice properties initialized here
            
            % this = this@JavaDevice();

        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % 2014.02.11 CNA temporary msg box to alert settings required 
            % to hook up to nPoint over ICE
            
            h = msgbox( ...
                'To connect to nPoint over ICE, you need to TURN OFF WIFI and TURN OFF VPN (for some reason, we cannot reach met-dev.dhcp.lbl.gov when VPN is on) and plug an ethernet cable into the computer.', ...
                'nPoint ICE connection help', ...
                'warn' ...
            ); 

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'nPoint',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop 310 330], hParent) ...
            );
        
			drawnow;
            
            dButtonWidth = 94;
            dButtonSep = 5;
            dTop = 20;
            
            this.uitConnect.build(this.hPanel, 10 + 0*(dButtonSep + dButtonWidth), dTop, dButtonWidth, Utils.dEDITHEIGHT);
            this.uitEnable.build(this.hPanel, 10 + 1*(dButtonSep + dButtonWidth), dTop, dButtonWidth, Utils.dEDITHEIGHT);
            this.uitStart.build(this.hPanel, 10 + 2*(dButtonSep + dButtonWidth), dTop, dButtonWidth, Utils.dEDITHEIGHT);
            
            this.uitEnable.hide();
            this.uitStart.hide();
            
            % Build axis
                        
            dSep = 40;
            dLeft = 10;
            dOffset = 60;
                
            this.hioCh1P.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioCh1I.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioCh1D.build(this.hPanel, dLeft, dOffset + 2*dSep);
            
            dOffset = dOffset + 2*dSep + 60; 
            
            this.hioCh2P.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioCh2I.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioCh2D.build(this.hPanel, dLeft, dOffset + 2*dSep); 
            
        end
        

        function lReturn = setWavetable(this, i32Vx, i32Vy)
            
            if ~this.uitConnect.lVal
                lReturn = false;
                return;
            end
            
            
            %{
            Stages have 20-bit precision throughout their range.  Positions
            are 20-bit signed (+/-524287). When signal is at +/- 524287,
            the stage is at its max range.   For example, if an axis has a
            range of +/- 50 um and you want to command the stage to move to
            +15 microns from center, you would set "signal" to 0x26666 (=
            524287/50*15).

            User passes in pre-scaled array of integers

            The maximum buffer size is 83,333 points, 2 seconds of data at
            full loop speed (1 clock cycle every 24 ?sec).
            
            i32Vx = int32(this.dVx/this.uieVoltsScale.val()*2^20/2);
            i32Vy = int32(this.dVy/this.uieVoltsScale.val()*2^20/2);
                        
            figure
            hold on
            plot(i32Vx, 'r');
            plot(i32Vy, 'b');
            plot(ones(size(i32Vx))*2^20/2, 'k');
            plot(-ones(size(i32Vx))*2^20/2, 'k');
            legend({'ch1', 'ch2'});
            %}
            
            % Stop and disable if it is active
            
            if this.isScanning()
                this.stop();
                this.disable();
            end
            
            lReturn = this.jDevice.setWavetable(1, i32Vx, length(i32Vx)) && this.jDevice.setWavetable(2, i32Vy, length(i32Vy));
            
            % Enable and start
            
            lReturn = lReturn && this.enable() && this.start();
                       
        end
        
        
        function lReturn = enable(this)
                        
            this.msg('enable()');            
            lReturn = this.jDevice.setWavetableEnable(1, 1) && this.jDevice.setWavetableEnable(2, 1);
            
        end
        
        function lReturn = disable(this)
                        
            this.msg('disable()');
            lReturn = this.jDevice.setWavetableEnable(1, 0) && this.jDevice.setWavetableEnable(2, 0);
            
        end
        
        function lReturn = isEnabled(this)
            lReturn = this.jDevice.getWavetableEnable(1) && this.jDevice.getWavetableEnable(2);
        end
        
        
        function lReturn = start(this)
            
            this.msg('start()');
            lReturn = this.jDevice.setTwoWavetablesActive(1);
            % lReturn = this.jDevice.setWavetableActive(1, 1) && this.jDevice.setWavetableActive(2, 1);
        end
        
        function lReturn = stop(this)
            
            this.msg('nPoint.stop()');
            lReturn = this.jDevice.setTwoWavetablesActive(0);
            % lReturn = this.jDevice.setWavetableActive(1, 0) && this.jDevice.setWavetableActive(2, 0);
        end
        
        function lReturn = isScanning(this)
            lReturn = this.jDevice.getWavetableActive(1) && this.jDevice.getWavetableActive(2);
        end
        
        
        function status(this)
             
            % this.attach();
            
            this.msg('nPoint.status()');
            
            cMsg = sprintf( ...
                'Ch1 \n\t Enabled = %1.0f \n\t Active = %1.0f \n\t Servo %1.0f \n\t PID = (%1.2f, %1.2f, %1.2f) \n\t analog_scale = %1.2f \n\t analog_offset = %1.0f \n\t digital_scale = %1.2f \n\t digital_scale_inv = %1.2f \n\t digital_offset = %1.0f \n\t monitor_scale = %1.2f \n\t monitor_offset = %1.0f', ...
                this.jDevice.getWavetableEnable(1), ...
                this.jDevice.getWavetableActive(1), ...
                this.jDevice.getServoState(1), ...
                this.jDevice.getGain(1, 'P'), ...
                this.jDevice.getGain(1, 'I'), ...
                this.jDevice.getGain(1, 'D'), ...
                this.jDevice.getFloatValueFromString(1, 'analog_scale'), ...
                this.jDevice.getIntValueFromString(1, 'analog_offset'), ...
                this.jDevice.getFloatValueFromString(1, 'digital_scale'), ...
                this.jDevice.getFloatValueFromString(1, 'digital_scale_inv'), ...
                this.jDevice.getIntValueFromString(1, 'digital_offset'), ...
                this.jDevice.getFloatValueFromString(1, 'monitor_scale'), ...
                this.jDevice.getIntValueFromString(1, 'monitor_offset') ...
            );
        
        
            this.msg(cMsg);
            
            cMsg = sprintf( ...
                'Ch2 \n\t Enabled = %1.0f \n\t Active = %1.0f \n\t Servo %1.0f \n\t PID = (%1.2f, %1.2f, %1.2f) \n\t analog_scale = %1.2f \n\t analog_offset = %1.0f \n\t digital_scale = %1.2f \n\t digital_scale_inv = %1.2f \n\t digital_offset = %1.0f \n\t monitor_scale = %1.2f \n\t monitor_offset = %1.0f', ...
                this.jDevice.getWavetableEnable(2), ...
                this.jDevice.getWavetableActive(2), ...
                this.jDevice.getServoState(2), ...
                this.jDevice.getGain(2, 'P'), ...
                this.jDevice.getGain(2, 'I'), ...
                this.jDevice.getGain(2, 'D'), ...
                this.jDevice.getFloatValueFromString(2, 'analog_scale'), ...
                this.jDevice.getIntValueFromString(2, 'analog_offset'), ...
                this.jDevice.getFloatValueFromString(2, 'digital_scale'), ...
                this.jDevice.getFloatValueFromString(2, 'digital_scale_inv'), ...
                this.jDevice.getIntValueFromString(2, 'digital_offset'), ...
                this.jDevice.getFloatValueFromString(2, 'monitor_scale'), ...
                this.jDevice.getIntValueFromString(2, 'monitor_offset') ...
            );
        
            this.msg(cMsg);
            
            
        end
        
        
        
        function stReturn = record(this, dTime)
           
            % @parameter dTime:double ms
            
            % Default input
            if exist('dTime', 'var') ~= 1
                dTime = 100; % ms
            end
            
            % Input validation
            if ~isa(dTime, 'double')
                me = MException( ...
                    'nPoint:record', ...
                    'second arg needs to be of class double' ...
                );
                throw(me);                
            end
            
           
            %{
            @return:struct with the following several properties:
           
            dRVxCommand
            dRVxSensor
            dRVyCommand
            dRVySensor
            dRTime
            %}
           
            % this.attach();

            dNum = round(dTime*1e-3/24e-6);  % samples @ 24us clock
            dScale = 10/(2^20/2);

            i32Record = this.jDevice.record(dNum);

            % Need to cast i32 returned from Java as a double before the
            % multiplication because in matlab when you multipley i32 by a
            % double it stays an i32 and since the return will be between
            % -10 and 10 it would only be integers
            
            % 2013.08.27 adding the digital scale factor, which is the ratio
            % between the open loop range of the stage and the closed loop
            % range.  When you record data from the 'input' register, it
            % needs to be scaled by the inverse of the digital scale factor
            % to convert back to real world units.  The sensor output
            % register already has the inverse digital scale factor applied.

            stReturn.dRVxCommand      = double(i32Record(1, :))*dScale*this.jDevice.getFloatValueFromString(1, 'digital_scale_inv');
            stReturn.dRVxSensor       = double(i32Record(2, :))*dScale;
            stReturn.dRVyCommand      = double(i32Record(3, :))*dScale*this.jDevice.getFloatValueFromString(2, 'digital_scale_inv');
            stReturn.dRVySensor       = double(i32Record(4, :))*dScale;
           
            dSample = 1:dNum;
            stReturn.dRTime = dSample*24e-6;
            
        end
        
        function dReturn = getGain(this, dChannel, cType)
            
            % @parameter dChannel (1, 2)
            % @parameter cType ('p', 'i', 'd')
           
            dReturn = this.jDevice.getGain(dChannel, cType);
        end
        
        function setGain(this, dChannel, cType, dVal)
            
            % @parameter dChannel (1, 2)
            % @parameter cType ('p', 'i', 'd')
            
            this.jDevice.setGain(dChannel, cType, dVal);
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

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardware(this)
            this.hioCh1P.turnOff();
            this.hioCh1I.turnOff();
            this.hioCh1D.turnOff();
            this.hioCh2P.turnOff();
            this.hioCh2I.turnOff();
            this.hioCh2D.turnOff(); 
        end
        
        % Overload
        
        function turnOnHardware(this)
            this.hioCh1P.turnOn();
            this.hioCh1I.turnOn();
            this.hioCh1D.turnOn();
            this.hioCh2P.turnOn();
            this.hioCh2I.turnOn();
            this.hioCh2D.turnOn(); 
            
        end
        
        
    end % protected
    
    
    methods (Access = private)
        
        
        % Overload
        
        function init(this)
            
            % init@JavaDevice(this);
            % Initialize JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'nPointProxy.jar');
            this.cPackage           = 'cxro.common.device';
            % this.cConstructFcn      = 'nPointProxy()';
            this.cConstructFcn      = sprintf('nPointProxy(''%s'',''iman.lbl.gov'')', this.cJavaName);
            this.cConnectFcn        = 'init()';
            this.cDisconnectFcn     = 'unInit()';
            
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            this.uitEnable = UIToggle('Enable', 'Disable');
            this.uitStart = UIToggle('Start', 'Stop');
                        
            addlistener(this.uitEnable, 'eChange', @this.handleEnable);
            addlistener(this.uitStart, 'eChange', @this.handleStart);
            
            this.hioCh1P = HardwareIO(sprintf('nPoint-ch1-gain-p-%s', this.cJavaName), this.cl, 'Ch1 P');
            this.hioCh1I = HardwareIO(sprintf('nPoint-ch1-gain-i-%s', this.cJavaName), this.cl, 'Ch1 I');
            this.hioCh1D = HardwareIO(sprintf('nPoint-ch1-gain-d-%s', this.cJavaName), this.cl, 'Ch1 D');
            
            this.hioCh2P = HardwareIO(sprintf('nPoint-ch2-gain-p-%s', this.cJavaName), this.cl, 'Ch2 P');
            this.hioCh2I = HardwareIO(sprintf('nPoint-ch2-gain-i-%s', this.cJavaName), this.cl, 'Ch2 I');
            this.hioCh2D = HardwareIO(sprintf('nPoint-ch2-gain-d-%s', this.cJavaName), this.cl, 'Ch2 D');
            
            this.hioCh1P.api = APIHardwareIOnPoint(this, 'ch1-gain-p');
            this.hioCh1I.api = APIHardwareIOnPoint(this, 'ch1-gain-i');
            this.hioCh1D.api = APIHardwareIOnPoint(this, 'ch1-gain-d');
            
            this.hioCh2P.api = APIHardwareIOnPoint(this, 'ch2-gain-p');
            this.hioCh2I.api = APIHardwareIOnPoint(this, 'ch2-gain-i');
            this.hioCh2D.api = APIHardwareIOnPoint(this, 'ch2-gain-d');

        end
        
        
        function handleStart(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click
            
            if this.uitStart.lVal
                if this.start()
                    % Success
                    
                else
                    % Fail 
                    % Show message and reset the toggle
                    msgbox('Could not start nPoint.', 'Communication error', 'error');
                    this.uitStart.lVal = false;       
                end
            else
                
                if this.stop();
                    % Success
                else
                    % Fail
                    % Show message and reset the toggle
                    msgbox('Could not stop nPoint.', 'Communication error', 'error');
                    this.uitStart.lVal = true;  
                end
            end
            
        end
        
        function handleEnable(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click
            
            if this.uitEnable.lVal
                if this.enable()
                    % Success
                    this.uitStart.show();
                else
                    % Fail. Show message and reset the toggle
                    msgbox('Could not enable nPoint.', 'Communication error', 'error');
                    this.uitEnable.lVal = false;
                    this.uitStart.hide();
                end
            else
                
                if this.disable()
                    % Success
                    this.uitStart.hide();
                else
                    % Fail
                    msgbox('Could not disable nPoint.', 'Communication error', 'error');
                    this.uitEnable.lVal = true;
                    this.uitStart.show();
                end
            end
        end 
        
        
        function handleConnect(this, src, evt)
            
            % Update "enable" and "active" toggles to match device
            % status
            this.uitEnable.lVal = this.isEnabled();
            this.uitStart.lVal = this.isScanning();

            % Show "enable" button
            this.uitEnable.show();

            if this.uitEnable.lVal
                % Show "start" button
                this.uitStart.show();
            end
        end
        
        
        function handleDisconnect(this, src, evt)
            
            this.uitEnable.hide();
            this.uitStart.hide();
            
        end
            
        
    end
    
    
end