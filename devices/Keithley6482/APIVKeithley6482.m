classdef APIVKeithley6482 < InterfaceKeithley6482

    
    properties
    end
    
    properties (SetAccess = private)


    end

    properties (Access = private)
        dPLC
        ceAverageState = {'OFF', 'OFF'}
        ceAverageAdvancedState = {'OFF', 'OFF'}
        ceAverageMode = {'MOVING', 'MOVING'}
        u8AverageCount = [10, 10] % uint8 causes problems with HIOP
        ceMedianState = {'OFF', 'OFF'}
        u8MedianRank = [3, 3] % uint8 causes problems with HIOP
        dRange = [20e-6, 20e-6]
        ceAutoRangeState
        
        % {double 1x1} - mean reported current 
        dMean = 10e-6;
        % {double 1x1} - standard deviation of reported current
        dSig = 1e-6;
    end

    methods

        function this = APIVKeithley6482()

        end
        
        % Create the serial port object associated with the COM serial
        %  port the device is attached to and configure baud rate and
        %  terminator. Will set property "s" of the API class
        function init(this)
        end
        
        % Connect the serial port to the instrument (fopen)
        function connect(this)
        end
        
        % Disconnect the serial port from the instrument (fclose)
        function disconnect(this)
        end
        
        % Write the *IDN? command to the instrument and then read back the
        % result of the command.
        % @return {char 1xm} - identity of the instrument
        function c = identity(this)
            c = 'AIPVKeithley6482';
        end
        
        
        % Set the integration period of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        function setIntegrationPeriodPLC(this, dPLC)
            this.dPLC = dPLC;
        end
        
        % Set the integration period of the ADC via time (in seconds) per integration.
        function setIntegrationPeriod(this, dSeconds)
            this.dPLC = dSeconds * 60;
        end
        
        % @return {double 1x1} - period in seconds
        function d = getIntegrationPeriod(this)
           d = this.dPLC * 1/60; 
        end
       
        % @return {double 1x1} - period in power line cycles (PLCs)
        function d = getIntegrationPeriodPLC(this)
            d = this.dPLC;
        end
        
        
        % Set the averaging filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageState(this, u8Ch, cVal) % set to 
           this.ceAverageState{u8Ch} = cVal; 
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        function c = getAverageState(this, u8Ch)
            c = this.ceAverageState{u8Ch};
        end
        
        
        
        % Set the advanced averaging filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageAdvancedState(this, u8Ch, cVal) % set to 
            this.ceAverageAdvancedState{u8Ch} = cVal;
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        function c = getAverageAdvancedState(this, u8Ch)
           c = this.ceAverageAdvancedState{u8Ch}; 
        end
        
        % Set the averaging filter mode of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this, u8Ch, cVal) 
            this.ceAverageMode{u8Ch} = cVal;
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        function c = getAverageMode(this, u8Ch)
            c = this.ceAverageMode{u8Ch};
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Ch, u8)
            this.u8AverageCount(u8Ch) = u8;
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {uint8) u8Val - the count (1 to 100)
        function u8 = getAverageCount(this, u8Ch)
            u8 = this.u8AverageCount(u8Ch);
        end
        
        
        % Set the median filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, u8Ch, cVal)
            this.ceMedianState{u8Ch} = cVal;
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm} cVal - the state: "ON" of "OFF"
        function c = getMedianState(this, u8Ch)
            c = this.ceMedianState{u8Ch};
        end
        
        
        % Set the median filter rank of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this, u8Ch,  u8)
            this.u8MedianRank(u8Ch) = u8;
        end
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {uint8)the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function u8 = getMedianRank(this, u8Ch)
            u8 = this.u8MedianRank(u8Ch);
        end
        
        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        
            
        % Set the range of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dAmps - the range: 2e-9, 20e-9, 200e-9, etc.
        function setRange(this, u8Ch, dAmps)
            this.dRange(u8Ch) = dAmps;
        end
        
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function d = getRange(this, u8Ch)
            d = this.dRange(u8Ch);
        end
            
        
        % Set the auto range state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, u8Ch, cVal)
            this.ceAutoRangeState{u8Ch} = cVal;
        end
        
        % @return {char 1xm} cVal - the state: "ON" of "OFF" 
        function c = getAutoRangeState(this, u8Ch)
            c = this.ceAutoRangeState{u8Ch};
        end
            
        
        % Set the auto range lower limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeLowerLimit(this, u8Ch, dVal)
        end
        
        
        % Set the auto range upper limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeUpperLimit(this, u8Ch, dVal)
        end
        
        function d = getSingleMeasurement(this)
           d = [this.dMean + this.dSig*randn(1), this.dMean + this.dSig*randn(1)]; 
        end
        
        

        

    end


   
 end %class
    

            
            
            
        