classdef Keithley6517a < HandlePlus
    
    
    
    properties (Constant)

        dHeight = 355;   % height of the UIElement
        dWidth = 300;   % width of the UIElement
        dWidthBtn = 24;
        dHeightBtn = 24;
        dSepVert = 40;
        dSepVert2 = 24;
        dSepSection = 0;
        dWidthHIOName = 90;
        dWidthHIOVal = 70;
        dWidthHIOStores = 90;
        dWidthHIODest = 90;
        dBackgroundColor = [.94 .94 .94]
        
        dWidthName = 100;
        dHeightText = 16;
        
        cTooltipApiOff = 'Connect to the real Api / hardware';
        cTooltipApiOn = 'Disconnect the real Api / hardware (go into virtual mode)';

        
    end
            
    properties
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'KEITHLEY6517A';
        cLabel = 'Keithley6517a';
        lActive = false
        
    end
    
    properties (Access = protected)
        clock
        
        uitxName
        
        cPath = fileparts(mfilename('fullpath'));
        uitApi      % toggle for real / virtual Api
        apiv
        api
        
        % {logical 1x1} show the API toggle at the top
        lShowApi = true;
        lShowLabels = false;
        
        % {logical 1x1} build HIO UI for ADC period, avg filter and med filter
        lShowSettings = false;
        
        % {logical 1x1} Build HIO UI for range and auto range state
        lShowRange = false;
       
        hPanel
        
        hoData
        hioRange
        hiotxAutoRangeState
        hioADCPeriod
        hiotxAvgFiltState
        hiotxAvgFiltType
        hiotxAvgFiltMode
        hioAvgFiltSize
        hiotxMedFiltState
        hioMedFiltRank
        
        hPanelSettings
        hPanelRange
        
        
        
        
        
        u8Active
        u8Inactive
        
        % listener handles
        lhApi
        lhAutoRangeState
        lhAvgFiltState
        lhMedFiltState
        
    end
    
    
    events
        
    end
    
            
    methods
        
        function this = Keithley6517a(varargin)

            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
        
        function setApi(this, api)
            
            this.api = api;
            this.api.init();
            this.api.connect();
            
            this.hoData.setApi(ApiKeithley6517aData(this.api));
            
            this.setApiRange();
            this.setApiSettings();
            
        end
        
        function setApiRange(this)
            if ~this.lShowRange
                return
            end
            
            this.hioRange.setApi(ApiKeithley6517aRange(this.api));
            this.hiotxAutoRangeState.setApi(ApiKeithley6517aAutoRangeState(this.api));
                            
        end
        
        function setApiSettings(this)
            if ~this.lShowSettings
                return
            end 
            
            this.hioADCPeriod.setApi(ApiKeithley6517aAdcPeriod(this.api));
            this.hiotxAvgFiltState.setApi(ApiKeithley6517aAvgFiltState(this.api));
            this.hiotxAvgFiltType.setApi(ApiKeithley6517aAvgFiltType(this.api));
            this.hiotxAvgFiltMode.setApi(ApiKeithley6517aAvgFiltMode(this.api));
            this.hioAvgFiltSize.setApi(ApiKeithley6517aAvgFiltSize(this.api));
            this.hiotxMedFiltState.setApi(ApiKeithley6517aMedFiltState(this.api));
            this.hioMedFiltRank.setApi(ApiKeithley6517aMedFiltRank(this.api));
            
        end
        
                
        function setApiv(this, api)
            
            this.apiv = api;
           
            this.hoData.setApiv(ApiKeithley6517aData(this.apiv));
            this.setApivRange();
            this.setApivSettings();
            
        end
        
        function setApivRange(this)
            if ~this.lShowRange
                return
            end
            
            this.hioRange.setApiv(ApiKeithley6517aRange(this.apiv));
            this.hiotxAutoRangeState.setApiv(ApiKeithley6517aAutoRangeState(this.apiv));
                            
        end
        
        function setApivSettings(this)
            if ~this.lShowSettings
                return
            end 
            
            this.hioADCPeriod.setApiv(ApiKeithley6517aAdcPeriod(this.apiv));
            this.hiotxAvgFiltState.setApiv(ApiKeithley6517aAvgFiltState(this.apiv));
            this.hiotxAvgFiltType.setApiv(ApiKeithley6517aAvgFiltType(this.apiv));
            this.hiotxAvgFiltMode.setApiv(ApiKeithley6517aAvgFiltMode(this.apiv));
            this.hioAvgFiltSize.setApiv(ApiKeithley6517aAvgFiltSize(this.apiv));
            this.hiotxMedFiltState.setApiv(ApiKeithley6517aMedFiltState(this.apiv));
            this.hioMedFiltRank.setApiv(ApiKeithley6517aMedFiltRank(this.apiv));
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareIO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREIO, INIT, DELETE       

     
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth', 0, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([dLeft dTop this.dWidth this.getHeight()], hParent));
            drawnow
            
            
            dTop = 10;
            dTopLabel = 10;
            dWidthHIOName = 80;
            
            
            % Global
            
            dLeft = 10;
            % Api toggle
            if this.lShowApi
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightText);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dWidthBtn);
                
            end
            
            
            this.uitxName.build(this.hPanel, ...
                dLeft + this.dWidthBtn + 5, ... % left
                dTop + (this.dHeightBtn - this.dHeightText)/2, ... % top
                this.dWidthName, ... % width 
                this.dHeightText ... % height
            ); 
        
            this.hoData.build(this.hPanel, ...
                dLeft + this.dWidthBtn + 5 + this.dWidthName + 40, ... % left
                dTop ... % top
            );
            
            this.buildRange();
            this.buildSettings();
                        
            
        end
        
        function buildRange(this)
            
            if ~this.lShowRange
                return
            end
            
            this.hPanelRange = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', 'RANGE', ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 40 this.dWidth - 20 75], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
                   
            this.hioRange.build(this.hPanelRange, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAutoRangeState.build(this.hPanelRange, dLeft, dTop);
            
            
        end
        
        function buildSettings(this)
        
            if ~this.lShowSettings
                return
            end

            
            this.hPanelSettings = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', 'SETTINGS', ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 120 this.dWidth - 20 195], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            this.hioADCPeriod.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAvgFiltState.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAvgFiltType.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAvgFiltMode.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioAvgFiltSize.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;

            this.hiotxMedFiltState.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioMedFiltRank.build(this.hPanelSettings, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
        end
        
        function delete(this)
            
            this.msg('delete', 5);
            
            this.save();
            
            
            delete(this.lhApi);
            delete(this.hoData);
            
            this.deleteSettings();
            this.deleteRange();
            
            % Clean up Api and Apiv
            if ishandle(this.api)
                this.api.disconnect();
            end
            delete(this.apiv);

                        
        end
        
        function deleteSettings(this)
            if ~this.lShowSettings
                return
            end
            
            % Remove event listeners
            
           
            delete(this.lhAutoRangeStat);
            delete(this.lhAvgFiltState);
            delete(this.lhMedFiltState);
        
            delete(this.hioADCPeriod);
            delete(this.hiotxAvgFiltStat);
            delete(this.hiotxAvgFiltType);
            delete(this.hiotxAvgFiltMod);
            delete(this.hioAvgFiltSize);
            delete(this.hiotxMedFiltState);
            delete(this.hioMedFiltRank);
        
            
        end
        
        function deleteRange(this)
            if ~this.lShowRange
                return
            end
            
            delete(this.hiotxAutoRangeState);
            delete(this.hioRange);

        end
        
        
        function save(this)
            
            
            this.msg('save()', 7);
            
            % Create a nested recursive structure of all public properties
            % s = this.saveClassInstance();
            
            % Only want to save u8UnitIndex
            
            s = struct();
            %s.u8UnitIndex = this.u8UnitIndex;
                                    
            % Save
            
            % save(this.file(), 's');
            
        end
        
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the Api to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitApi.lVal = true;
            this.uitApi.setTooltip(this.cTooltipApiOn);
                     
            % Turn on all HIO instances
            
            
            
            % Kill the Apiv
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.setApiv([]); % This is calling the setter
            end
            
            this.hoData.turnOn();
            
            this.turnOnRange();
            this.turnOnSettings();
            
            
        end
        
        function turnOnRange(this)
            
            if ~this.lShowRange
               return;
            end
           
            this.hioRange.turnOn();
            this.hiotxAutoRangeState.turnOn();
        end
        
        
        
        function turnOnSettings(this)
            if ~this.lShowSettings
                return;
            end
           
            this.hioADCPeriod.turnOn();
            this.hiotxAvgFiltState.turnOn();
            this.hiotxAvgFiltType.turnOn();
            this.hiotxAvgFiltMode.turnOn();
            this.hioAvgFiltSize.turnOn();
            this.hiotxMedFiltState.turnOn();
            this.hioMedFiltRank.turnOn();
            
        end
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareIO.turnOn()
        %
        % See also TURNON
        
            % CA 2014.04.14: Make sure Apiv is available
            
            if isempty(this.apiv)
                this.setApiv(this.newApiv());
            end
            
            this.lActive = false;
            this.uitApi.lVal = false;
            this.uitApi.setTooltip(this.cTooltipApiOff);
            
            this.hoData.turnOff();
            this.turnOffRange();
            this.turnOffSettings();
            
            
            
        end
        
        function turnOffRange(this)
            
            if ~this.lShowRange
               return;
            end
           
            this.hioRange.turnOff();
            this.hiotxAutoRangeState.turnOff();
        end
        
        function turnOffSettings(this)
            
            if ~this.lShowSettings
                return
            end
            
            this.hioADCPeriod.turnOff();
            this.hiotxAvgFiltState.turnOff();
            this.hiotxAvgFiltType.turnOff();
            this.hiotxAvgFiltMode.turnOff();
            this.hioAvgFiltSize.turnOff();
            this.hiotxMedFiltState.turnOff();
            this.hioMedFiltRank.turnOff(); 
            
        end
        
        % ADC period, L, must satisfy 166.6666666667e-6 < L < 200e-3 
        % @return {logical 1x1}
        function l = validateADCPeriod(this)
            
            dVal = this.hioADCPeriod.destCal('ms') / 1000; % s
            dHigh = 200e-3;
            dLow = 167e-6;
            if (dVal > dHigh || ...
               dVal < dLow)
                l = false;
                this.msg(sprintf('Val %1.3e is of bounds: %1.3e < val < %1.3e', dVal, dLow, dHigh));
            else
                l = true;
            end
            
        end
        
        % Digital average filter size must be betweem 1 and 100
        function l = validateAvgFiltSize(this)
            
            dVal = this.hioAvgFiltSize.destCal('counts'); % s
            dHigh = 100;
            dLow = 1;
            if (dVal > dHigh || ...
               dVal < dLow)
                l = false;
                this.msg(sprintf('Val %d is of bounds: %d < val < %d', dVal, dLow, dHigh));
            else
                l = true;
            end
            
        end
        
        function api = getApi(this)
        %GETApi return the real or virtual api based on active
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end
        end

        
    end
    
    
    
    
    
    
    methods (Access = protected)
        
        function init(this)
            
            
            
            this.u8Active = imread(fullfile(...
               MicUtils.pathAssets(), ...
                'hiot-true-24.png'...
            ));
        
            this.u8Inactive = imread(fullfile(...
                MicUtils.pathAssets(), ...
                'hiot-false-24.png'...
            ));
            
            
            st1 = struct();
            st1.lAsk        = true;
            st1.cTitle      = 'Switch?';
            st1.cQuestion   = 'Do you want to change from the virtual Api to the real Api?';
            st1.cAnswer1    = 'Yes of course!';
            st1.cAnswer2    = 'No not yet.';
            st1.cDefault    = st1.cAnswer2;

            st2 = struct();
            st2.lAsk        = true;
            st2.cTitle      = 'Switch?';
            st2.cQuestion   = 'Do you want to change from the real Api to the virtual Api?';
            st2.cAnswer1    = 'Yes of course!';
            st2.cAnswer2    = 'No not yet.';
            st2.cDefault    = st2.cAnswer2;

            this.uitApi = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                this.u8Inactive, ...
                this.u8Active, ...
                st1, ...
                st2 ...
            );
            this.uitApi.setTooltip(this.cTooltipApiOff);
            this.uitxName = UIText(this.cName, 'left');
            
            configData =  ConfigHardwareIOPlus(fullfile(this.cPath, 'config-data.json'));
            this.hoData = HardwareOPlus(...
                'cName', sprintf('%s-data', this.cName), ...
                'cLabel', 'AMPS:', ...
                'config', configData, ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'dWidthName', 40, ...
                'dWidthVal', this.dWidthHIOVal , ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
        
            this.initRange();
            this.initSettings();
            
            % Update Apiv of all children to ApivKeithley6517a
            this.setApiv(this.newApiv());
            this.lhApi = addlistener(this.uitApi, 'eChange', @this.onApiChange);
            
        end
        
        function initRange(this)
            
            if ~this.lShowRange
                return
            end
            
            configAutoRangeState = ConfigHardwareIOText(fullfile(this.cPath, 'config-auto-range-state.json'));
            this.hiotxAutoRangeState = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state', this.cName), ...
                'cLabel', 'AUTO RANGE', ...
                'config', configAutoRangeState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            
            configRange = ConfigHardwareIOPlus(fullfile(this.cPath, 'config-range.json'));
            this.hioRange = HardwareIOPlus(...
                'cName', sprintf('%s-range', this.cName), ...
                'cLabel', 'VALUE (A)', ...
                'config', configRange, ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
              
            
        end
        
        function initSettings(this)
            
            if ~this.lShowSettings
                return
            end
                        
            configADCPeriod = ConfigHardwareIOPlus(fullfile(this.cPath, 'config-adc-period.json'));
            this.hioADCPeriod = HardwareIOPlus(...
                'cName', sprintf('%s-adc-period', this.cName), ...
                'cLabel', 'ADC PERIOD (ms)', ...
                'config', configADCPeriod, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowPlay', false, ...
                'cLabelDest', 'Command', ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'dWidthDest', this.dWidthHIODest, ...
                'fhValidateDest', @this.validateADCPeriod, ...
                'clock', this.clock ...
            );

            configAvgFiltState = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-state.json'));
            this.hiotxAvgFiltState = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-state', this.cName), ...
                'cLabel', 'AVG. FILTER', ...
                'config', configAvgFiltState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );

            configAvgFiltType = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-type.json'));
            this.hiotxAvgFiltType = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-type', this.cName), ...
                'cLabel', '    TYPE', ...
                'config', configAvgFiltType, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );

            configAvgFiltMode = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-mode.json'));
            this.hiotxAvgFiltMode = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode', this.cName), ...
                'cLabel', '    MODE', ...
                'config', configAvgFiltMode, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );


            configAvgFiltSize = ConfigHardwareIOPlus(fullfile(this.cPath, 'config-avg-filt-size.json'));
            this.hioAvgFiltSize = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size', this.cName), ...
                'cLabel', '    SIZE', ...
                'config', configAvgFiltSize, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'dWidthDest', this.dWidthHIODest, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'fhValidateDest', @this.validateAvgFiltSize, ...
                'clock', this.clock ...
            );

            configMedFiltState = ConfigHardwareIOText(fullfile(this.cPath, 'config-med-filt-state.json'));
            this.hiotxMedFiltState = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state', this.cName), ...
                'cLabel', 'MED FILT', ...
                'config', configMedFiltState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );


            configMedFiltRank = ConfigHardwareIOPlus(fullfile(this.cPath, 'config-med-filt-rank.json'));
            this.hioMedFiltRank =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank', this.cName), ...
                'cLabel', '    RANK', ...
                'config', configMedFiltRank, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'clock', this.clock ...
            );
        
            this.lhAutoRangeState = addlistener(this.hiotxAutoRangeState, 'eChange', @this.onAutoRangeStateChange);
            this.lhAvgFiltState = addlistener(this.hiotxAvgFiltState, 'eChange', @this.onAvgFiltStateChange);
            this.lhMedFiltState = addlistener(this.hiotxMedFiltState, 'eChange', @this.onMedFiltStateChange);
            
            
            
        end
        
        function onApiChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        
            
        function api = newApiv(this)
        %@return {AIVKeithley6482}
            api = ApivKeithley6517a;
        end
        
        function onAutoRangeStateChange(this, src, evt)
            switch src.val()
                case 'on'
                    this.disableRange();
                case 'off'
                    this.enableRange();
            end
        end
        
        function onAvgFiltStateChange(this, src, evt)
            switch src.val()
                case 'on'
                    this.enableAvgFilt();
                case 'off'
                    this.disableAvgFilt();
            end
        end
        
        function onMedFiltStateChange(this, src, evt)
            switch src.val()
                case 'on'
                    this.enableMedFilt();
                case 'off'
                    this.disableMedFilt();
            end
        end
        
        function enableMedFilt(this)
            this.hioMedFiltRank.enable();
        end
        
        function disableMedFilt(this)
            this.hioMedFiltRank.disable();
        end
        
        function enableAvgFilt(this)
            this.hiotxAvgFiltType.enable();
            this.hiotxAvgFiltMode.enable();
            this.hioAvgFiltSize.enable();
        end
        
        function disableAvgFilt(this)
            this.hiotxAvgFiltType.disable();
            this.hiotxAvgFiltMode.disable();
            this.hioAvgFiltSize.disable();
        end
        
        function enableRange(this)
            this.hioRange.enable();
        end

        function disableRange(this)
            this.hioRange.disable();
        end
        
        % @return {double 1x1} d - the height of the panel
        function d = getHeight(this)
           
            d = 45;
            
            if this.lShowRange
                d = d + 85;
            end
            
            if this.lShowSettings
                d = d + 200;
            end
        end
    end
    
end

