classdef ApiKeithley6482 < InterfaceKeithley6482

    % Troubleshooting
    %
    % If this class issues timeout warnings, it is a communication error.
    % Check the the following are working properly:
    % - NPort (serial to ethernet)
    % - Routers
    % - Keithley
    %
    % For read speed, the BaudRate is generally not the limiting factor.
    % There is overhead on the instrument between the measure command and
    % the fscanf
    
    properties % (Access = private)
     
        % {serial 1x1}
        s
        
        % {char 1xm} port of MATLAB {serial}
        cPort = 'COM2'
        
        % {char 1xm} terimator of MATLAB {serial}. Must match hardware
        % To set on hardware: menu --> communication --> rs-232 --> terminator
        % Short is better for communication; each character is ~ 10 bits.
        cTerminator = 'CR'  % 'CR/LF'
        
        % {uint16 1x1} - baud rate of MATLAB {serial}.  Must match hardware
        % to set on hardware: menu --> communication --> rs-232 -> baud
        u16BaudRate = uint16(57600);
        
        % {double 1x1} - timeout of MATLAB {serial} - amount of time it will
        % wait for a response before aborting.  
        dTimeout = 2
        
        dPLCMax = 10;
        dPLCMin = 0.01;
        
        % {double 1x1} storate for number of calls to getData()
        dCount = 0;
    end
    methods 
        
        function this = ApiKeithley6482(varargin) 
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
        end
        
        function init(this)
            this.s = serial(this.cPort);
            this.s.Terminator = this.cTerminator; 
            this.s.BaudRate = this.u16BaudRate;
            this.s.Timeout = this.dTimeout;
            % TO DO configure the 
        end
        
        function connect(this)
            try
                fopen(this.s); 
            catch
                disp('Error connecting to Keithley, check ethernet and power to the Keithley NPORT unit');
                disp('Press any key to continue');
                pause;
            end
        end
        
        function disconnect(this)
            this.msg('disconnect()');
            fclose(this.s);
        end
        
        function c = identity(this)
            cCommand = '*IDN?';
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
            
            cCommand = sprintf(':current:nplcycles %1.3f', dPLC);
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
            cCommand = ':current:nplcycles?';
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        % --------
        % UPDATE
        %
        % I didn't realize that the ADC, Average Filter, and Median Filter
        % Settings are global to both channels.  The Api below still works,
        % but know that if you set channel 2, it is the same as setting 1,
        % which is really setting both channels
        
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
            cCommand = sprintf(':sense%u:average?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
        
        
        function setAverageAdvancedState(this, u8Ch, cVal)
            cCommand = sprintf(':sense%u:average:advanced %s', u8Ch, cVal);
            fprintf(this.s, cCommand);
        end
        
        function c = getAverageAdvancedState(this, u8Ch)
            cCommand = sprintf(':sense%u:average:advanced?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
        
         % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this, u8Ch, cVal)
            % [:SENSe[1]]:CURRent[:DC]:AVERage:TCONtrol <name>
            % REPeat
            % MOVing
            cCommand = sprintf(':sense%u:average:tcontrol %s', u8Ch, cVal);
            fprintf(this.s, cCommand);
        end
        
        function c = getAverageMode(this, u8Ch)
            cCommand = sprintf(':sense%u:average:tcontrol?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Ch, u8Val) 
            % [:SENSe[1]]:CURRent[:DC]:AVERage:COUNt <n>
            cCommand = sprintf(':sense%u:average:count %u', u8Ch, u8Val);
            fprintf(this.s, cCommand);

        end
        
        function u8 = getAverageCount(this, u8Ch)
            cCommand = sprintf(':sense%u:average:count?', u8Ch);
            fprintf(this.s, cCommand);
            u8 = str2double(fscanf(this.s));
        end
        
        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, u8Ch, cVal)
            % [:SENSe[1]]:CURRent[:DC]:MEDian[:STATe] <b>
            cCommand = sprintf(':sense%u:median %s', u8Ch, cVal);
            fprintf(this.s, cCommand);
        end
        
        
        function c = getMedianState(this, u8Ch)
            cCommand = sprintf(':sense%u:median?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
        % Set the median filter rank of a channel
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this, u8Ch, u8Val)
            % [:SENSe[1]]:CURRent[:DC]:MEDian:RANK <NRf>
            cCommand = sprintf(':sense%u:median:rank %u', u8Ch, u8Val);
            fprintf(this.s, cCommand);
        end
        
        function u8 = getMedianRank(this, u8Ch)
            cCommand = sprintf(':sense%u:median:rank?', u8Ch);
            fprintf(this.s, cCommand);
            u8 = str2double(fscanf(this.s));
        end
        

        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        % The Model 6517A will then go to the most sensitive range that
        % will accommodate that expected reading.
        function setRange(this, u8Ch, dAmps)
           % [:SENSe[1]]:CURRent[:DC]:RANGe[:UPPer] <n> 
           cCommand = sprintf(':sense%u:current:range %1.3e', u8Ch, dAmps);
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
            cCommand = sprintf(':sense%u:current:range:auto?', u8Ch);
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
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
            this.msg('delete()');
            this.disconnect();
            delete(this.s);
        end
                
        % @return {double 1x2} - ch1 and ch2 current
        function d = getSingleMeasurement(this)
           cCommand = ':measure?';
           fprintf(this.s, cCommand);
           c = fscanf(this.s); % {char 1xm} '+6.925672E-07,+3.245491E-10'
           ce = strsplit(c, ','); % {cell 1x2} {'+6.925672E-07', '+3.245491E-10'}
           d = str2double(ce); % {double 1x2} [6.925672e-07 3.245491e-10]
        end
        
        
        function d = read(this, u8Ch)
            % this.dCount = this.dCount + 1;
            % tic
           cCommand = sprintf(':FORM:ELEM CURR%u', u8Ch);
           fprintf(this.s, cCommand);
           cCommand = ':read?';
           fprintf(this.s, cCommand);
           c = fscanf(this.s); % {char 1xm} '+6.925672E-07
           % time = toc;
           % fprintf('Read %1.0f time = %1.1f ms\n', this.dCount, time * 1000);
           d = str2double(c);
        end
        
        
        
    end
    
    
    methods (Access = private)
        
        % The SPCI state? commands return a {char 1xm} representation of 1
        % or 0 followed by the terminator.  The 6517A terminator is CR/LF,
        % which is equivalent to \r\n in matlab. This method converts the
        % {char 1xm} response, for example '1\r\n' or '0\r\n' (except the char
        % doesn't actually equal this, you have to wrap sprintf around it
        % for \r\n to convert.) to 'on' or 'off', respectively
        % @param {char 1xm} - response from SPCI
        % @return {char 1xm} - 'on' or 'off'
           
        function c = stateText(this, cIn)
            
            switch this.cTerminator
                case 'CR'
                    if strcmp(cIn, sprintf('1\r'))
                        c = 'on';
                    else
                        c = 'off';
                    end
                case 'CR/LF'
                    if strcmp(cIn, sprintf('1\r\n'))
                        c = 'on';
                    else
                        c = 'off';
                    end
            end
                    
        end
        
    end
    
end
        
