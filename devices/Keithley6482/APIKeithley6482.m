classdef APIKeithley6482 < InterfaceKeithley6482

    properties % (Access = private)
     
        % {serial 1x1}
        s
        
        terminator = 'CR';  % to set: menu --> communication --> terminator
        % terminator = 'CR/LF';
        
        dPLCMax = 10;
        dPLCMin = 0.01;
    end
    methods 
        
        function this = APIKeithley6482()            
        end
        
        function init(this)
            this.s = serial('COM1');
            this.s.Terminator = this.terminator'; % Default for Instrument
        end
        
        function connect(this)
            fopen(this.s); 
        end
        
        function disconnect(this)
            fclose(this.s);
        end
        
        function c = identity(this)
            cCommand = '*IDN?'
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
%         function setFunctionToAmps(this)
%             fprintf(this.s, ':FUNCtion "CURRent"');
%         end
        
        % Set the speed (integration time) of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        function setIntegrationPeriodPLC(this, dPLC)
            % [:SENSe[1]]:CURRent[:DC]:NPLCycles <n>
            
            if (dPLC > this.dPLCMax)
                cMsg = sprintf(...
                    'ERROR: supplied PLC = %1.2f > max allowed = %1.2f', ...
                    dPLC, ...
                    this.dPLCMax ...
                );
                this.log(cMsg);
                return;
            end
            
            if (dPLC < this.dPLCMin)
                cMsg = sprintf(...
                    'ERROR: supplied PLC = %1.2f <  min allowed = %1.2f', ...
                    dPLC, ...
                    this.dPLCMin ...
                );
                this.log(cMsg);
                return;
            end
            
            cCommand = sprintf(':current:nplcycles %1.3f', dPLC)
            fprintf(this.s, cCommand);
            
        end
        
        function setIntegrationPeriod(this, dSeconds)
            % [:SENSe[1]]:CURRent[:DC]:APERture <n>
            % <n> =166.6666666667e-6 to 200e-3 Integration period in seconds
            dPLC = dSeconds * 60;
            this.setIntegrationPeriodPLC(dPLC);
        end
        
        
        function d = getIntegrationPeriod(this)
            dPLC = this.getIntegrationPeriodPLC();
            d = dPLC * 1/60;
        end
        
        function d = getIntegrationPeriodPLC(this)
            cCommand = ':current:nplcycles?'
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        
        
        % Enable or disable the digital averaging filter 
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageState(this, u8Ch, cVal) 
            % [:SENSe[1]]:CURRent[:DC]:AVERage[:STATe] <b>
            % ON
            % OFF
            cCommand = sprintf(':sense%u:average %s', u8Ch, cVal)
            fprintf(this.s, cCommand);
        end
        
        % @return {char 1xm} "ON" or "OFF"
        function c = getAverageState(this, u8Ch)
            cCommand = sprintf(':sense%u:average?', u8Ch)
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        
        
        function setAverageAdvancedState(this, u8Ch, cVal)
            cCommand = sprintf(':sense%u:average:advanced %s', u8Ch, cVal)
            fprintf(this.s, cCommand);
        end
        
        function c = getAverageAdvancedState(this, u8Ch)
            cCommand = sprintf(':sense%u:average:advanced?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        
         % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this, u8Ch, cVal)
            % [:SENSe[1]]:CURRent[:DC]:AVERage:TCONtrol <name>
            % REPeat
            % MOVing
            cCommand = sprintf(':sense%u:average:tcontrol %s', u8Ch, cVal)
            fprintf(this.s, cCommand);
        end
        
        function c = getAverageMode(this, u8Ch)
            cCommand = sprintf(':sense%u:average:tcontrol?', u8Ch)
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Ch, u8Val) 
            % [:SENSe[1]]:CURRent[:DC]:AVERage:COUNt <n>
            cCommand = sprintf(':sense%u:average:count %u', u8Ch, u8Val)
            fprintf(this.s, cCommand);

        end
        
        function u8 = getAverageCount(this, u8Ch)
            cCommand = sprintf(':sense%u:average:count?', u8Ch)
            fprintf(this.s, cCommand);
            u8 = uint8(str2double(fscanf(this.s)));
        end
        
        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, u8Ch, cVal)
            % [:SENSe[1]]:CURRent[:DC]:MEDian[:STATe] <b>
            cCommand = sprintf(':sense%u:median %s', u8Ch, cVal)
            fprintf(this.s, cCommand);
        end
        
        
        function c = getMedianState(this, u8Ch)
            cCommand = sprintf(':sense%u:median?', u8Ch)
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        % Set the median filter rank of a channel
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this, u8Ch, u8Val)
            % [:SENSe[1]]:CURRent[:DC]:MEDian:RANK <NRf>
            cCommand = sprintf(':sense%u:median:rank %u', u8Ch, u8Val)
            fprintf(this.s, cCommand);
        end
        
        function u8 = getMedianRank(this, u8Ch)
            cCommand = sprintf(':sense%u:median:rank?', u8Ch)
            fprintf(this.s, cCommand);
            u8 = uint8(str2double(fscanf(this.s)));
        end
        

        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        % The Model 6517A will then go to the most sensitive range that
        % will accommodate that expected reading.
        function setRange(this, u8Ch, dAmps)
           % [:SENSe[1]]:CURRent[:DC]:RANGe[:UPPer] <n> 
           cCommand = sprintf(':sense%u:current:range %1.3e', u8Ch, dAmps)
           fprintf(this.s, cCommand);

        end
            
        function d = getRange(this, u8Ch)
            cCommand = sprintf( ':sense%u:current:range?', u8Ch);
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, u8Ch, cVal)
            cCommand = sprintf(':sense%u:current:range:auto %s', u8Ch, cVal)
            fprintf(this.s, cCommand);
        end
        
        function c = getAutoRangeState(this, u8Ch)
            cCommand = sprintf(':sense%u:current:range:auto?', u8Ch)
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
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
        
    end
    
end
        
