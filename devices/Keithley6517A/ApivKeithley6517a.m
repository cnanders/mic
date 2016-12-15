classdef ApivKeithley6517a < InterfaceKeithley6517a

    properties % (Access = private)
     
        
    end
    
    
    properties (Access = private)
        dPLC
        cAverageState = 'OFF'
        cAverageType = 'SCALAR'
        cAverageMode = 'MOVING'
        u8AverageCount = uint8(10)
        cMedianState = 'OFF'
        u8MedianRank = uint8(3)
        dRange = 20e-6
        cAutoRangeState = 'OFF'
        
        % {double 1x1} - mean reported current 
        dMean = 100e-6;
        % {double 1x1} - standard deviation of reported current
        dSig = 1e-6;
    end
    
    methods 
        
        function this = ApivKeithley6517a()            
        end
        
        function init(this)
        end
        
        function connect(this)
        end
        
        function disconnect(this)
        end
        
        function c = identity(this)
            c = 'ApivKeithley6517A';
        end
        
        function setFunctionToAmps(this)
            
        end
        
        % Set the speed (integration time) of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        function setIntegrationPeriodPLC(this, dPLC)
            this.dPLC = dPLC;
        end
        
        function setIntegrationPeriod(this, dSeconds)
            this.dPLC = dSeconds * 60;
        end
        
        function d = getIntegrationPeriod(this)
            d = this.dPLC / 60;
        end
        
        function d = getIntegrationPeriodPLC(this)
            d = this.dPLC;
        end
        
        
        
        % Enable or disable the digital averaging filter 
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageState(this,  cVal) 
            this.cAverageState = cVal;
        end
        
        function c = getAverageState(this)
            c = this.cAverageState;
        end
        
        % Set the averaging filter state of a channel
        % @param {char 1xm} cVal - the state: "NONE", "SCAL", "ADV".  I
        % only envision ever using "SCALar" mode.
        function setAverageType(this,  cVal)
            this.cAverageType = cVal;
        end
        
        function c = getAverageType(this)
            c = this.cAverageType;
        end
        
         % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this,  cVal)
            this.cAverageMode = cVal;
        end
        
        function c = getAverageMode(this)
            c = this.cAverageMode;
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Val) 
            this.u8AverageCount = u8Val;
        end
        
        function u8 = getAverageCount(this)
            u8 = this.u8AverageCount;
        end

        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, cVal)
            this.cMedianState = cVal;
        end
        
        
        function c = getMedianState(this)
            c = this.cMedianState;
        end
             
        
        function setMedianRank(this,  u8Val)
            this.u8MedianRank = u8Val;
        end
        
        function u8 = getMedianRank(this)
            u8 = this.u8MedianRank;
        end

        function setRange(this, dAmps)
           this.dRange = dAmps;
        end
            
        function d = getRange(this)
            d = this.dRange;
        end
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, cVal)
            this.cAutoRangeState = cVal;
        end
        
        function c = getAutoRangeState(this)
            c = this.cAutoRangeState;
        end
                    
        
        % Set the auto range lower limit of a channel
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeLowerLimit(this, dVal)
        end
        
        
        % Set the auto range upper limit of a channel
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeUpperLimit(this, dVal)  
        end
               
        function delete(this)
            this.disconnect();
        end
        
        function d = getDataLatest(this)
           d = this.dMean + this.dSig*randn(1); 
        end
        
        function d = getDataFresh(this)
            d = this.getDataLatest();
        end
        
    end
    
end
        
