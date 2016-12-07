classdef ApiKeithley6517a < InterfaceKeithley6517a

    % Can only use ASCII format with RS232.  Need GPIB to use other formats
    properties % (Access = private)
     
        % {serial 1x1}
        s
        dPLCMax = 10;
        dPLCMin = 0.01;
        u8GpibAddress = 28;
        cPort = 'COM1';
        cTerminator = 'CR/LF'; % Default for Instrument does not support any other
        u16BaudRate = uint16(19200); % 9600
        lSerial = true;
    end
    methods 
        
        function this = ApiKeithley6517a(varargin)   
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function init(this)
            
            if this.lSerial
                % Serial
                this.s = serial(this.cPort);
                this.s.Terminator = this.cTerminator; 
                this.s.BaudRate = this.u16BaudRate;
            else
                % GPIB
                this.s = gpib('ni', 0, this.u8GpibAddress);
                this.connect();
                % this.s.EOSCharCode = this.cTerminator;
                
            end            
            
        end
        
        function connect(this)
            if ~strcmp(this.s.Status, 'open')
                fopen(this.s); 
            end
        end
        
        function disconnect(this)
            if strcmp(this.s.Status, 'open')
                fclose(this.s);
            end
            
        end
        
        function c = identity(this)
            cCommand = '*IDN?';
            %tic
            fprintf(this.s, cCommand);
            %toc
            %tic
            c = fscanf(this.s);
            %toc
        end
        
        function setFunctionToAmps(this)
            cCommand = ':func "curr"';
            fprintf(this.s, cCommand);
        end
        
        % Set the speed (integration time) of the ADC.  
        % @param {double 1x1} dPLC - the integration time as the number of power 
        %   line cycles.  Min = 0.01 Max = 10.  1 PLC = 1/60s = 16.67 ms @
        %   60Hz or 1/50s = 20 ms @ 50 Hz.
        function setIntegrationPeriodPLC(this, dPLC)
            % [:SENSe[1]]:curr[:DC]:nplc <n>
            
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
                
            cCommand = sprintf(':curr:nplc %1.3f', dPLC);
            fprintf(this.s, cCommand);
            
        end
        
        function setIntegrationPeriod(this, dPeriod)
            % [:SENSe[1]]:curr[:DC]:aper <n>
            % <n> =166.6666666667e-6 to 200e-3 Integration period in seconds
            cCommand = sprintf(':curr:aper %1.5e', dPeriod);
             fprintf(this.s, cCommand);
        end
        
        function d = getIntegrationPeriod(this)
            cCommand = ':curr:aper?'; 
            %tic
            fprintf(this.s, cCommand);
            %toc
            %tic
            c = fscanf(this.s);
            %toc
            d = str2double(c);
        end
        
        % For testing command vs. read with dead time in the middle
        % to isolate delays while the instrument fills its buffer with
        % the answer
        
%         function getIntegrationPeriodA(this)
%             cCommand = ':curr:aper?'; 
%             tic
%             fprintf(this.s, cCommand);
%             toc 
%         end
%         
%         function d = getIntegrationPeriodB(this)
%             tic
%             c = fscanf(this.s);
%             toc
%             d = str2double(c);
%         end
        
        
        
        function d = getIntegrationPeriodPLC(this)
            cCommand = ':curr:nplc?';
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        
        
        % Enable or disable the digital averaging filter 
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setAverageState(this,  cVal) 
            % [:SENSe[1]]:curr[:DC]:aver[:STATe] <b>
            % ON
            % OFF
            cCommand = sprintf(':curr:aver %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageState(this)
            cCommand = ':curr:aver?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
        % Set the averaging filter state of a channel
        % @param {char 1xm} cVal - the state: "NONE", "SCAL", "ADV".  I
        % only envision ever using "SCALar" mode.
        function setAverageType(this,  cVal)
            % [:SENSe[1]]:curr[:DC]:aver:TYPE <name>
            % NONE
            % SCALar
            % ADVanced
            cCommand = sprintf(':curr:aver:type %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageType(this)
            cCommand = ':curr:aver:type?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
         % Set the averaging filter mode of a channel
        % @param {char 1xm} cVal - the mode: "REPEAT" or "MOVING"
        function setAverageMode(this,  cVal)
            % [:SENSe[1]]:curr[:DC]:aver:tcon <name>
            % REPeat
            % MOVing
            cCommand = sprintf(':curr:aver:tcon %s', cVal);
             fprintf(this.s, cCommand);
        end
        
        function c = getAverageMode(this)
            cCommand = ':curr:aver:tcon?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Val) 
            % [:SENSe[1]]:curr[:DC]:aver:coun <n>
            cCommand = sprintf(':curr:aver:coun %u', u8Val);
            fprintf(this.s, cCommand);
        end
        
        function u8 = getAverageCount(this)
            fprintf(this.s, ':curr:aver:coun?');
            % do not cast as uint8 becasue it screws with HIO
            u8 = str2double(fscanf(this.s));
        end
        
        

        
        
        % Set the median filter state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF"
        function setMedianState(this, cVal)
            % [:SENSe[1]]:curr[:DC]:med[:STATe] <b>
            cCommand = sprintf(':curr:med %s', cVal);
            fprintf(this.s, cCommand);
        end
        
        
        function c = getMedianState(this)
            cCommand = ':curr:med?';
            fprintf(this.s, cCommand);
            c = fscanf(this.s);
            c = this.stateText(c);
        end
        
                
        % Set the median filter rank of a channel
        % @param {uint8) cVal - the rank: 0 (disabled), 1, 2, 3, 4, 5. [3, 5,
        % 7, 9, 11 samples, respectively]
        function setMedianRank(this,  u8Val)
            cCommand = sprintf(':curr:med:rank %u', u8Val);
            fprintf(this.s, cCommand);
            % [:SENSe[1]]:curr[:DC]:med:RANK <NRf>
        end
        
        function u8 = getMedianRank(this)
            cCommand = ':curr:med:rank?';
            fprintf(this.s, cCommand);
            % do not cast as uint8 because it screws with HIO
            u8 = str2double(fscanf(this.s));
        end
                
            
        % Set the range
        % @param {double 1x1} dAmps - the expected current.
        % The Model 6517A will then go to the most sensitive range that
        % will accommodate that expected reading.
        function setRange(this, dAmps)
           % [:SENSe[1]]:curr[:DC]:rang[:UPPer] <n> 
           cCommand = sprintf(':curr:rang %1.3e', dAmps);
           fprintf(this.s, cCommand);
        end
            
        function d = getRange(this)
            cCommand = ':curr:rang?';
            fprintf(this.s, cCommand);
            d = str2double(fscanf(this.s));
        end
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, cVal)
            cCommand = sprintf(':curr:rang:auto %s', cVal);
            fprintf(this.s, cCommand);
        end
        
        function c = getAutoRangeState(this)
            cCommand = ':curr:rang:auto?';
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
           cCommand = ':data:lat?';
           fprintf(this.s, cCommand);
           c = fscanf(this.s);
           d = str2double(c);
           
        end
        
        function d = getDataFresh(this)
           cCommand = ':data:fres?';
           fprintf(this.s, cCommand);
           c = fscanf(this.s);
           d = str2double(c); 
        end
        
        function delete(this)
            this.disconnect();
            delete(this.s);
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
        
