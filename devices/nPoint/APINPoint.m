classdef APINPoint < InterfaceNPoint
    
    % np
    
	properties
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)        
                
    end
    
        
    events        
    end
        
    methods
        
       
        function this = APINPoint()            
        end
        
        function lReturn = setWavetable(this, i32Ch1, i32Ch2)
                        
            % Stop and disable if it is active
            
            if this.isScanning()
                this.stop();
                this.disable();
            end
            
            lReturn = this.jDevice.setWavetable(1, i32Ch1, length(i32Ch1)) && this.jDevice.setWavetable(2, i32Ch2, length(i32Ch2));
            
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
        
        
        function cMsg = status(this, u8Channel)
             
            % this.attach();
            
            this.msg('nPoint.status()');
            
            cMsg = sprintf( ...
                'Ch1 \n\t Enabled = %1.0f \n\t Active = %1.0f \n\t Servo %1.0f \n\t PID = (%1.2f, %1.2f, %1.2f) \n\t analog_scale = %1.2f \n\t analog_offset = %1.0f \n\t digital_scale = %1.2f \n\t digital_scale_inv = %1.2f \n\t digital_offset = %1.0f \n\t monitor_scale = %1.2f \n\t monitor_offset = %1.0f', ...
                this.jDevice.getWavetableEnable(u8Channel), ...
                this.jDevice.getWavetableActive(u8Channel), ...
                this.jDevice.getServoState(u8Channel), ...
                this.jDevice.getGain(u8Channel, 'P'), ...
                this.jDevice.getGain(u8Channel, 'I'), ...
                this.jDevice.getGain(u8Channel, 'D'), ...
                this.jDevice.getFloatValueFromString(u8Channel, 'analog_scale'), ...
                this.jDevice.getIntValueFromString(u8Channel, 'analog_offset'), ...
                this.jDevice.getFloatValueFromString(u8Channel, 'digital_scale'), ...
                this.jDevice.getFloatValueFromString(u8Channel, 'digital_scale_inv'), ...
                this.jDevice.getIntValueFromString(u8Channel, 'digital_offset'), ...
                this.jDevice.getFloatValueFromString(u8Channel, 'monitor_scale'), ...
                this.jDevice.getIntValueFromString(u8Channel, 'monitor_offset') ...
            ); 
        end
        
        
        
        function stReturn = record(this, dTime)
                       
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

            stReturn.i32Command1      = int32(double(i32Record(1, :)) * this.jDevice.getFloatValueFromString(1, 'digital_scale_inv'));
            stReturn.i32Sensor1       = i32Record(2, :);
            stReturn.i32Command2      = int32(double(i32Record(3, :)) * this.jDevice.getFloatValueFromString(2, 'digital_scale_inv'));
            stReturn.i32Sensor2       = i32Record(4, :);
           
            dSample = 1:dNum;
            stReturn.dTime = dSample * 24e-6;
            
        end
        
        function dReturn = getGain(this, u8Channel, cType)
            dReturn = this.jDevice.getGain(u8Channel, cType);
        end
        
        function setGain(this, u8Channel, cType, dVal)
            this.jDevice.setGain(u8Channel, cType, dVal);
        end
        
        
          

    end
    
end