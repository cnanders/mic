classdef APIKeithley6517A < InterfaceKeithley6517A

    properties % (Access = private)
     
        % {serial 1x1}
        s
        dPLCMax = 10;
        dPLCMin = 0.01;
        cPort = 'COM1';
        cTerminator = 'CR/LF'; % Default for Instrument does not support any other
        u16BaudRate = uint16(9600);
    end
    methods 
        
        function this = APIKeithley6517A(varargin)   
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if isprop(this, varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function init(this)
            this.s = serial(this.cPort);
            this.s.Terminator = this.cTerminator; 
            this.s.BaudRate = this.u16BaudRate;
        end
        
        function connect(this)
            fopen(this.s); 
        end
        
        function disconnect(this)
            fclose(this.s);
        end
        
        function c = identity(this)
            cCommand = '*IDN?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        function setFunctionToAmps(this)
            cCommand = ':function "current"';
            fprintf(this.s, cCommand);
        end
        
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
        
        function setIntegrationPeriod(this, dPeriod)
            % [:SENSe[1]]:CURRent[:DC]:APERture <n>
            % <n> =166.6666666667e-6 to 200e-3 Integration period in seconds
            cCommand = sprintf(':current:aperture %1.5e', dPeriod);
             fprintf(this.s, cCommand);
        end
        
        function d = getIntegrationPeriod(this)
            cCommand = ':current:aperture?'; 
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        function d = getIntegrationPeriodPLC(this)
            cCommand = ':current:nplcycles?';
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        
        
        % Enable or disable the digital averaging filter 
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageState(this,  cVal) 
            % [:SENSe[1]]:CURRent[:DC]:AVERage[:STATe] <b>
            % ON
            % OFF
            cCommand = sprintf(':current:average %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageState(this)
            cCommand = ':current:average?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
        % Set the averaging filter state of a channel
        % @param {char 1xm} cVal - the state: "NONE", "SCAL", "ADV".  I
        % only envision ever using "SCALar" mode.
        function setAverageType(this,  cVal)
            % [:SENSe[1]]:CURRent[:DC]:AVERage:TYPE <name>
            % NONE
            % SCALar
            % ADVanced
            cCommand = sprintf(':current:average:type %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageType(this)
            cCommand = ':current:average:type?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
         % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this,  cVal)
            % [:SENSe[1]]:CURRent[:DC]:AVERage:TCONtrol <name>
            % REPeat
            % MOVing
            cCommand = sprintf(':current:average:tcontrol %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageMode(this)
            cCommand = ':current:average:tcontrol?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Val) 
            % [:SENSe[1]]:CURRent[:DC]:AVERage:COUNt <n>
            cCommand = sprintf(':current:average:count %u', u8Val);
            fprintf(this.s, cCommand);
        end
        
        function u8 = getAverageCount(this)
            fprintf(this.s, ':current:average:count?');
            % do not cast as uint8 becasue it screws with HIO
            u8 = str2double(fscanf(this.s));
        end
        
        

        
        
        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, cVal)
            % [:SENSe[1]]:CURRent[:DC]:MEDian[:STATe] <b>
            cCommand = sprintf(':current:median %s', cVal);
            fprintf(this.s, cCommand);
        end
        
        
        function c = getMedianState(this)
            cCommand = ':current:median?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
                
        % Set the median filter rank of a channel
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this,  u8Val)
            cCommand = sprintf(':current:median:rank %u', u8Val);
            fprintf(this.s, cCommand);
            % [:SENSe[1]]:CURRent[:DC]:MEDian:RANK <NRf>
        end
        
        function u8 = getMedianRank(this)
            cCommand = ':current:median:rank?';
            fprintf(this.s, cCommand);
            % do not cast as uint8 because it screws with HIO
            u8 = str2double(fscanf(this.s));
        end
                
            
        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        % The Model 6517A will then go to the most sensitive range that
        % will accommodate that expected reading.
        function setRange(this, dAmps)
           % [:SENSe[1]]:CURRent[:DC]:RANGe[:UPPer] <n> 
           cCommand = sprintf(':current:range %1.3e', dAmps);
           fprintf(this.s, cCommand);
        end
            
        function d = getRange(this)
            cCommand = ':current:range?';
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, cVal)
            cCommand = sprintf(':current:range:auto %s', cVal);
            fprintf(this.s, cCommand);
        end
        
        function c = getAutoRangeState(this)
            cCommand = ':current:range:auto?';
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
       
        % IMPORTANT
        % Must configure instrument correctly:
        % Menu -> Communication -> RS232 -> Elements
        % Everything should be off except RDG
        % **** RDG=y (reading) ****
        % RDG#=n (reading# since instrument turned on)
        % UNIT=n (unit)
        % CH#=n (channel)
        % HUM=n (humidity)
        % ETEMP=n (temp)
        % TIME=n (timestamp)
        % STATUS=n
        % VSRC=n (voltage source)
        function d = getDataLatest(this) 
           cCommand = ':data:latest?';
           fprintf(this.s, cCommand);
           d = fscanf(this.s);
           d = str2double(d);
        end
        
        function d = getDataFresh(this)
           cCommand = ':data:fresh?';
           fprintf(this.s, cCommand);
           d = str2double(fscanf(this.s)); 
        end
        
        function delete(this)
            this.disconnect();
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
            
            switch this.terminator
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
        
