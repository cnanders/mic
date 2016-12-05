classdef ApiKeithley6517aAsync < InterfaceKeithley6517a

    % Can only use ASCII format with RS232.  Need GPIB to use other formats
    % Main problem with the Keithley6517A instrument is that the time it
    % takes to fill the outpub buffer is 30 ms - 40 ms and if serial
    % communication is synchronous, it block matlab this entire timel.
    %
    % The asynchronous API executes all read queries in an asynchronous,
    % event-based loop, populating a 1-value internal buffer with the last
    % received value that it can then instantaneously serve to the consumer
    % whenever it is requested. 
    %
    % The frequency of device polling can be controlled with the dDelay
    % property
        
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
        
        % {timer 1x1}
        timer
        
        % {cell 1xm of char 1xm} list of query commands to issue to
        % instrument.  See also cecResponses
        cecQueries = {...
            ':curr:aver?', ... % avg filt state
            ':curr:aver:type?', ... % avg filt type (none, scal, adv)
            ':curr:aver:tcon?', ... % avg filt mode (moving, window)
            ':curr:aver:coun?', ... % avg filt count
            ':data:lat?', ... % data latest 
            ':data:fres?', ... % data fresh
            ':curr:aper?', ... % integration time
            ':curr:nplc?', ... % integration time PLC
            ':curr:med?', ... % med state
            ':curr:med:rank?', ... % med rank
            ':curr:rang?' ... % range
            ':curr:rang:auto?' ... % auto range state
        };
        
        % {cell 1xm of char 1xm} list of responses from asynchronous
        % communication with instrument
        cecResponses = cell(1, 12);
    
        % {uint8 1x1} index of cecQueries being executed now
        u8Query = 1;
        
        % {double 1x1} poling delay in seconds.  Each time onBytesAvailable
        % is invoked (whenever the result is available), a new timer is
        % started with this start delay, before invoking onTimer(), which 
        % begins the next read cycle
        dDelay = .001;
        
    end
    methods 
        
        function this = ApiKeithley6517aAsync(varargin)   
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.timer = timer(...
                'StartDelay', this.dDelay, ...
                'ExecutionMode', 'singleShot', ...
                'TimerFcn', @this.onTimer ...
            );
           
                
        end
        
        function init(this)
                        
            if this.lSerial
                % Serial
                this.s = serial(this.cPort);
                this.s.Terminator = this.cTerminator; 
                this.s.BaudRate = this.u16BaudRate;
                this.s.ReadAsyncMode = 'manual';
                this.s.BytesAvailableFcn = @this.onBytesAvailable;
                this.connect();
                start(this.timer);
            else
                % GPIB
                this.s = gpib('ni', 0, this.u8GpibAddress);
                this.s.BytesAvailableFcnMode = 'eosCharCode';
                this.s.BytesAvailableFcn = @this.onBytesAvailable;
                this.connect();
                start(this.timer);
                % this.s.EOSCharCode = this.cTerminator;
                
            end
                
            
            
        end
        
        
        
        % @param {gpib 1x1} obj
        % @param {struct 1x1} event
        % @param {char 1xm} event.Type
        % @param {struct 1x1} event.Data
        % @param {double 1x6] event.Data.AbsTime - datetime vector
        
        function onBytesAvailable(this, obj, event)
            
            % disp('onBytesAvailable');
            
            % Read
            % tic
            this.cecResponses{this.u8Query} = fscanf(this.s);
            % c = fread(this.s, this.s.BytesAvailable);
            % time = toc;
            % fprintf('Read time = %1.1f ms\n', time * 1000);
            
            % Update command index
            this.updateQuery();
            
            % Timer-based next query
            stop(this.timer);
            start(this.timer);
            
            % Direct (no timer) next query
            % this.nextQuery();
                        
        end
        
        function updateQuery(this)
            this.u8Query = this.u8Query + 1;
            if this.u8Query > length(this.cecQueries)
                this.u8Query = 1;
            end
        end
        
        function onTimer(this, obj, evt)
            % disp('onTimer()')
            this.nextQuery();
        end
        function nextQuery(this)
            
            % disp('nextQuery()');
            
            % Execute next query command
            % tic
            fprintf(this.s, this.cecQueries{this.u8Query});
            % time = toc;
            
%             fprintf('Query time = %1.1f ms for %s\n', ...
%                 time * 1000, ...
%                 this.cecQueries{this.u8Query} ...
%             );
            
            
            % Issue async read command.  Once terminator has been read
            % from the instrument and placed in the input buffer, the
            % onBytesAvailable callback will be executed
            readasync(this.s)
            
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
            tic
            fprintf(this.s, cCommand);
            toc
            tic
            c = fscanf(this.s);
            toc
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
            u8Index = this.getIndex(cCommand);
            d = str2double(this.cecResponses{u8Index});
        end
               
        function d = getIntegrationPeriodPLC(this)
            cCommand = ':curr:nplc?';
            u8Index = this.getIndex(cCommand);
            d = str2double(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
            c = this.stateText(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
            c = this.cecResponses{u8Index};
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
            u8Index = this.getIndex(cCommand);
            c = this.cecResponses{u8Index};
        end
        
        % Set the averaging filter count of a channel
        % @param {uint8) u8Val - the count (1 to 100)
        function setAverageCount(this, u8Val) 
            % [:SENSe[1]]:curr[:DC]:aver:coun <n>
            cCommand = sprintf(':curr:aver:coun %u', u8Val);
            fprintf(this.s, cCommand);
        end
        
        function u8 = getAverageCount(this)
            cCommand = ':curr:aver:coun?';
            u8Index = this.getIndex(cCommand);
            u8 = str2double(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
            c = this.stateText(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
            % do not cast as uint8 because it screws with HIO
            u8 = str2double(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
            d = str2double(this.cecResponses{u8Index});
        end
        
        % Set the auto range state of a channel
        % @param {char 1xm} cVal - the state: "ON" of "OFF" 
        function setAutoRangeState(this, cVal)
            cCommand = sprintf(':curr:rang:auto %s', cVal);
            fprintf(this.s, cCommand);
        end
        
        function c = getAutoRangeState(this)
            cCommand = ':curr:rang:auto?';
            u8Index = this.getIndex(cCommand);
            c = this.stateText(this.cecResponses{u8Index});
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
            u8Index = this.getIndex(cCommand);
           d = str2double(this.cecResponses{u8Index});
        end
        
        function d = getDataFresh(this)
            cCommand = ':data:fres?';
            u8Index = this.getIndex(cCommand);
           d = str2double(this.cecResponses{u8Index}); 
        end
        
        function delete(this)
            this.disconnect();
            delete(this.s);
            stop(this.timer);
            delete(this.timer);
        end
        
        
        % @param {char 1xm} - SCPI query command
        function u8 = getIndex(this, c)
            tic
            u8 = find(cellfun('length', regexp(this.cecQueries, c)) == 1);
            time = toc;
            fprintf('Get index time = %1.1f ms\n', time * 1000);
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
        
