classdef InterfaceKeithley6482 < HandlePlus

    methods (Abstract)
        
        
        % Create the serial port object associated with the COM serial
        %  port the device is attached to and configure baud rate and
        %  terminator. Will set property "s" of the Api class
        init(this)
        
        % Connect the serial port to the instrument (fopen)
        connect(this)
        
        % Disconnect the serial port from the instrument (fclose)
        disconnect(this)
        
        % Write the *IDN? command to the instrument and then read back the
        % result of the command.
        % @return {char 1xm} - identity of the instrument
        c = identity(this)
        
        
        % Set the integration period of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        setIntegrationPeriodPLC(this, dPLC)
        
        % Set the integration period of the ADC via time (in seconds) per integration.
        setIntegrationPeriod(this, dSeconds)
        
        % @return {double 1x1} - period in seconds
        d = getIntegrationPeriod(this)
       
        % @return {double 1x1} - period in power line cycles (PLCs)
        d = getIntegrationPeriodPLC(this)
        
        
        % Set the averaging filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setAverageState(this, u8Ch, cVal) % set to 
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        c = getAverageState(this, u8Ch)
        
        
        % Set the advanced averaging filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setAverageAdvancedState(this, u8Ch, cVal) % set to 
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        c = getAverageAdvancedState(this, u8Ch)
        
        % Set the averaging filter mode of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        setAverageMode(this, u8Ch, cVal) 
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm}
        c = getAverageMode(this, u8Ch)
        
        % Set the averaging filter count of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) u8Val - the count (1 to 100)
        setAverageCount(this, u8Ch, u8) 
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {uint8) u8Val - the count (1 to 100)
        u8 = getAverageCount(this, u8Ch)
        
        
        % Set the median filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setMedianState(this, u8Ch, cVal)
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {char 1xm} cVal - the state: "ON" of "OFF"
        c = getMedianState(this, u8Ch)
        
        
        % Set the median filter rank of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        setMedianRank(this, u8Ch,  u8)
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {uint8)the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        u8 = getMedianRank(this, u8Ch)
        
        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        
            
        % Set the range of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dAmps - the range: 2e-9, 20e-9, 200e-9, etc.
        setRange(this, u8Ch, dAmps)
        
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        d = getRange(this, u8Ch)
            
        
        % Set the auto range state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        setAutoRangeState(this, u8Ch, cVal)
        
        % @return {char 1xm} cVal - the state: "ON" of "OFF" 
        c = getAutoRangeState(this, u8Ch)
            
        
        % Set the auto range lower limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeLowerLimit(this, u8Ch, dVal)
        
        
        % Set the auto range upper limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeUpperLimit(this, u8Ch, dVal)
        
        
        % d = getDataLatest(this, u8Ch)
        % d = getDataFresh(this, u8Ch)
        
        % @return {double 1x2} - ch1 and ch2 current
        % d = getSingleMeasurement(this)
        
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {double 1x1} dVal - current
        d = read(this, u8Ch)
               
    end
    
end
        
