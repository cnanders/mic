classdef InterfaceKeithley6517a < HandlePlus

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
        identity(this)
        
        % Select the measurement function of the instrument to Amps
        setFunctionToAmps(this)
        
        
        % Set the integration period of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        setIntegrationPeriodPLC(this, dPLC)
        
        % Set the integration period of the ADC via time (in seconds) per integration.
        setIntegrationPeriod(this, dPeriod)
        
        d = getIntegrationPeriod(this)
        d = getIntegrationPeriodPLC(this)
        

        
                
        % Enable or disable the digital averaging filter 
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setAverageState(this,  cVal) % set to
        
        % @return {char 1xm}
        getAverageState(this)
        
        % Set the averaging filter type
        % @param {char 1xm} cVal - the state: "NONE", "SCAL", "ADV".  I
        % only envision ever using "SCALar" mode.
        setAverageType(this,  cVal)
        
        % @return {char 1xm}
        getAverageType(this)
        
        % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        setAverageMode(this,  cVal) 
        
        % @return {char 1xm}
        c = getAverageMode(this)
        
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        setAverageCount(this, u8Val) 
        u8 = getAverageCount(this)

        
        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setMedianState(this, cVal)
        
        % @return {char 1xm}
        c = getMedianState(this)
        
        % Set the median filter rank of a channel
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        setMedianRank(this,  u8Val)
        
        % @return {uint8 1x1}
        u8 = getMedianRank(this)
            
        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        % The Model 6517A will then go to the most sensitive range that
        % will accommodate that expected reading.
        setRange(this, dAmps)
        
        % @return {double 1x1}
        d = getRange(this)
            
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        setAutoRangeState(this, cVal) 
            
        c = getAutoRangeState(this)
        
        
        % Set the auto range lower limit of a channel
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeLowerLimit(this, dVal)
        
        
        % Set the auto range upper limit of a channel
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeUpperLimit(this, dVal)       
        
       
        d = getDataLatest(this)
        d = getDataFresh(this)
        
    end
    
end
        
