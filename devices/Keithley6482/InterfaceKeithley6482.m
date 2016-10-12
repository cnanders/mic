classdef InterfaceKeithley6482 < HandlePlus

    methods (Abstract)
        
        
        % Set the averaging filter count of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) u8Val - the count (1 to 100)
        setAverageCount(this, u8Ch, u8) 
        
        
        % Set the averaging filter mode of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        setAverageMode(this, u8Ch, cVal) 
        
        
        % Set the averaging filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setAverageState(this, u8Ch, cVal) % set to 
        
        
        % Set the median filter rank of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        setMedianRank(this, u8Ch,  u8)
        
        
        % Set the median filter state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        setMedianState(this, u8Ch, cVal)
        
            
        % Set the range of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setRange(this, u8Ch, dVal)
            
        
        % Set the auto range state of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        setAutoRangeState(this, u8Ch, cVal) 
            
        
        % Set the auto range lower limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeLowerLimit(this, u8Ch, dVal)
        
        
        % Set the auto range upper limit of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @param {double 1x1} dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        setAutoRangeUpperLimit(this, u8Ch, dVal)
        
       
        % Set the speed (integration time) of the ADC.  This setting
        % applies globally to both channels (not possible to set channels
        % individually)
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        setSpeed(this, dPLC)
       
       % Getters for all of these?
       
       % Get the most recent current value
       % @param {uint8 1x1} u8Ch - the channel (1 or 2)
       % @return {double 1x1} the current
       get(this, u8Ch)
        
    end
    
end
        
