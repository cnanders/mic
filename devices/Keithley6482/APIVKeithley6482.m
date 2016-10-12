classdef APIVKeithley6482 < InterfaceKeithley6482

    
    properties
        cName
    end
    
    properties (SetAccess = private)


    end

    properties (Access = private)
        clock


    end

    methods

        function this = APIVKeithley6482(cName, clock)

            this.cName = cName;
            this.clock = clock;

        end

        % Set the averaging filter count of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {uint8) u8Val - the count (1 to 100)

        function setAverageCount(this, u8Ch, u8)
            this.msg(sprintf('setAverageCount(%u, %u)', u8Ch, u8));
        end

        % Set the averaging filter mode of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {char) cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this, u8Ch, cMode) 
            this.msg(sprintf('setAverageMode(%u, %s)', u8Ch, cMode));
        end

        % Set the averaging filter state of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {char) cVal - the state: "ON" of "OFF"
        function setAverageState(this, u8Ch, cState)
            this.msg(sprintf('setAverageState(%u, %s)', u8Ch, cState));
        end

        % Set the median filter rank of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this, u8Ch,  u8)
            this.msg(sprintf('setMedianRank(%u, %u)', u8Ch, u8));
        end

        % Set the median filter state of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {char) cVal - the state: "ON" of "OFF"
        function setMedianState(this, u8Ch, cState)
            this.msg(sprintf('setMedianState(%u, %s)', u8Ch, cState));
        end

        % Set the range of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {double) dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setRange(this, u8Ch, dVal)
            this.msg(sprintf('setMedianState(%u, %1.2e)', u8Ch, dVal));
        end


        % Set the auto range state of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {char) cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, u8Ch, cState) 
            this.msg(sprintf('setAutoRangeState(%u, %s)', u8Ch, cState));
        end

        % Set the auto range lower limit of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {double) dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeLowerLimit(this, u8Ch, dVal)
        end

        % Set the auto range upper limit of a channel
        % @param {uint8} u8Ch - the channel (1 or 2)
        % @param {double) dVal - the range: 2e-9, 20e-9, 200e-9, etc.
        function setAutoRangeUpperLimit(this, u8Ch, dVal)
        end

        % Set the speed (integration time) of the ADC.  This setting
        % applies globally to both channels (not possible to set channels
        % individually)
        % @param {double) dVal - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        function setSpeed(this, dVal)
            this.msg(sprintf('setSpeed(%1.2f)',  dVal));
        end


        function delete(this)

            % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end

        end
        
        % Get the most recent current value
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)
        % @return {double 1x1} the current
        function dOut = get(this, u8Ch)
            dOut = rand(1,1); 
        end

    end


    methods (Access = protected)

        function handleClock(this)


        end

    end
 end %class
    

            
            
            
        