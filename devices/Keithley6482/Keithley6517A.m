classdef Keithley6517A < HandlePlus
    
    
    
    properties (Constant)

        dHeight = 300;   % height of the UIElement
        dWidth = 260;   % width of the UIElement
        dWidthBtn = 24;
        dHeightBtn = 24;
        dSepVert = 40;
        dSepVert2 = 24;
        dSepSection = 10;
        dWidthHIOName = 120;
        dWidthHIOVal = 60;
        dWidthHIOStores = 70;
        dWidthHIODest = 70;
        dBackgroundColor = [.94 .94 .94]
        
        dWidthName = 100;
        dHeightText = 16;
        
        cTooltipAPIOff = 'Connect to the real API / hardware';
        cTooltipAPIOn = 'Disconnect the real API / hardware (go into virtual mode)';

        
    end
            
    properties
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'Keithley6517A';
        cLabel = 'Keithley6517A';
        lActive = false
        
    end
    
    properties (Access = protected)
        clock
        
        uitxName
        
        cPath = fileparts(mfilename('fullpath'));
        uitAPI      % toggle for real / virtual API
        apiv
        api
        
        lShowAPI = true;
        lShowLabels = false;
       
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
        
        
        
        
        
        
        
        
        u8Active
        u8Inactive
        
    end
    
    
    events
        
    end
    
            
    methods
        
        function this = Keithley6517A(varargin)

            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if isprop(this, varargin{k})
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
            
            this.hoData.setApi(APIHOData(this.api));
            this.hioRange.setApi(APIHIORange(this.api));
            this.hiotxAutoRangeState.setApi(APIHIOTXAutoRangeState(this.api));
            this.hioADCPeriod.setApi(APIHIOADCPeriod(this.api));
            this.hiotxAvgFiltState.setApi(APIHIOTXAvgFiltState(this.api));
            this.hiotxAvgFiltType.setApi(APIHIOTXAvgFiltType(this.api));
            this.hiotxAvgFiltMode.setApi(APIHIOTXAvgFiltMode(this.api));
            this.hioAvgFiltSize.setApi(APIHIOAvgFiltSize(this.api));
            this.hiotxMedFiltState.setApi(APIHIOTXMedFiltState(this.api));
            this.hioMedFiltRank.setApi(APIHIOMedFiltRank(this.api));
            
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
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent));
            drawnow
            
            
            dTop = 0;
            dTopLabel = 0;
            dTop = 0;
            dWidthHIOName = 80;
            
            
            % Global
            
            dLeft = 0;
            % API toggle
            if this.lShowAPI
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelAPI.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightText);
                end
                this.uitAPI.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dWidthBtn);
                
            end
            
            this.uitxName.build(this.hPanel, ...
                this.dWidthBtn + 5, ... % left
                (this.dHeightBtn - this.dHeightText)/2, ... % top
                this.dWidthName, ... % width 
                this.dHeightText ... % height
            );            
            this.hoData.build(this.hPanel, 140, dTop);
            
            dTop = dTop + 30;
            
            this.hiotxAutoRangeState.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert;
            
            this.hioRange.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            dTop = dTop + this.dSepSection;
            
            this.hioADCPeriod.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            dTop = dTop + this.dSepSection;
            
            this.hiotxAvgFiltState.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAvgFiltType.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAvgFiltMode.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioAvgFiltSize.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            dTop = dTop + this.dSepSection;
            this.hiotxMedFiltState.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioMedFiltRank.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            
            
        end
        
        function delete(this)
            
            this.msg('delete', 5);
            if ishandle(this.api)
                this.api.disconnect();
            end
            this.save();
            delete(this.apiv);
                        
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
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitAPI.lVal = true;
            this.uitAPI.setTooltip(this.cTooltipAPIOn);
                     
            % Turn on all HIO instances
            
            
            
            % Kill the APIV
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.apiv = []; % This is calling the setter
            end
            
            this.hoData.turnOn();
            this.hioRange.turnOn();
            this.hiotxAutoRangeState.turnOn();
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
        
            % CA 2014.04.14: Make sure APIV is available
            
            if isempty(this.apiv)
                this.apiv = this.newAPIV();
            end
            
            this.lActive = false;
            this.uitAPI.lVal = false;
            this.uitAPI.setTooltip(this.cTooltipAPIOff);
            
            this.hoData.turnOff();
            this.hioRange.turnOff();
            this.hiotxAutoRangeState.turnOff();
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

        
    end
    
    
    
    
    
    
    methods (Access = protected)
        
        function init(this)
            
            
            
            this.apiv = this.newAPIV();
            this.u8Active = imread(fullfile(...
               Utils.pathAssets(), ...
                'hiot-true-24.png'...
            ));
        
            this.u8Inactive = imread(fullfile(...
                Utils.pathAssets(), ...
                'hiot-false-24.png'...
            ));
            
            
            st1 = struct();
            st1.lAsk        = true;
            st1.cTitle      = 'Switch?';
            st1.cQuestion   = 'Do you want to change from the virtual API to the real API?';
            st1.cAnswer1    = 'Yes of course!';
            st1.cAnswer2    = 'No not yet.';
            st1.cDefault    = st1.cAnswer2;

            st2 = struct();
            st2.lAsk        = true;
            st2.cTitle      = 'Switch?';
            st2.cQuestion   = 'Do you want to change from the real API to the virtual API?';
            st2.cAnswer1    = 'Yes of course!';
            st2.cAnswer2    = 'No not yet.';
            st2.cDefault    = st2.cAnswer2;

            this.uitAPI = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                this.u8Inactive, ...
                this.u8Active, ...
                st1, ...
                st2 ...
            );
            this.uitAPI.setTooltip(this.cTooltipAPIOff);
            
            
            this.uitxName = UIText(this.cName, 'left');
            
            configData =  Config(fullfile(this.cPath, 'config-data.json'));
            configRange = Config(fullfile(this.cPath, 'config-range.json'));
            configAutoRangeState = ConfigHardwareIOText(fullfile(this.cPath, 'config-auto-range-state.json'));
            configADCPeriod = Config(fullfile(this.cPath, 'config-adc-period.json'));
            configAvgFiltState = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-state.json'));
           
            configAvgFiltType = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-type.json'));
            configAvgFiltMode = ConfigHardwareIOText(fullfile(this.cPath, 'config-avg-filt-mode.json'));
            
            % configAvgFiltSize = Config(fullfile(this.cPath, 'config-avg-filt-size.json'));
            configAvgFiltSize = Config(fullfile(this.cPath, 'config-avg-filt-size.json'));
            
            configMedFiltState = ConfigHardwareIOText(fullfile(this.cPath, 'config-med-filt-state.json'));
            configMedFiltRank = Config(fullfile(this.cPath, 'config-med-filt-rank.json'));
           
            this.hoData = HardwareOPlus(...
                'cName', sprintf('%s-data', this.cName), ...
                'cLabel', 'Amps:', ...
                'config', configData, ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'dWidthName', 50, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
                
            this.hiotxAutoRangeState = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state', this.cName), ...
                'cLabel', 'Auto Range State', ...
                'config', configAutoRangeState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowPlay', false, ...
                'lShowAPI', false, ...
                'lShowLabels', true, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            this.hioRange = HardwareIOPlus(...
                'cName', sprintf('%s-range', this.cName), ...
                'cLabel', 'Range (A)', ...
                'config', configRange, ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
              
            this.hioADCPeriod = HardwareIOPlus(...
                'cName', sprintf('%s-adc-period', this.cName), ...
                'cLabel', 'ADC Period (ms)', ...
                'config', configADCPeriod, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'lShowPlay', false, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'dWidthDest', this.dWidthHIODest, ...
                'fhValidateDest', @this.validateADCPeriod, ...
                'clock', this.clock ...
            );
        
           
            this.hiotxAvgFiltState = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-state', this.cName), ...
                'cLabel', 'Average Filt State', ...
                'config', configAvgFiltState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            
            this.hiotxAvgFiltType = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-type', this.cName), ...
                'cLabel', 'Average Filt Type', ...
                'config', configAvgFiltType, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            this.hiotxAvgFiltMode = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode', this.cName), ...
                'cLabel', 'Average Filt Mode', ...
                'config', configAvgFiltMode, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
           
            this.hioAvgFiltSize = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size', this.cName), ...
                'cLabel', 'Average Filt Size', ...
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
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'fhValidateDest', @this.validateAvgFiltSize, ...
                'clock', this.clock ...
            );
        
            this.hiotxMedFiltState = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state', this.cName), ...
                'cLabel', 'Median Filt State', ...
                'config', configMedFiltState, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowPlay', false, ...
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            this.hioMedFiltRank =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank', this.cName), ...
                'cLabel', 'Median Filt Rank', ...
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
                'lShowAPI', false, ...
                'lShowLabels', false, ...
                'clock', this.clock ...
            );
             
            addlistener(this.uitAPI, 'eChange', @this.onAPIChange);
            addlistener(this.hiotxAutoRangeState, 'eChange', @this.onAutoRangeStateChange);
            addlistener(this.hiotxAvgFiltState, 'eChange', @this.onAvgFiltStateChange);
            addlistener(this.hiotxMedFiltState, 'eChange', @this.onMedFiltStateChange);
            
        end
        
        function onAPIChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        function api = getAPI(this)
        %GETAPI return the real or virtual api based on active
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end
        end
            
        function api = newAPIV(this)
        %@return {AIVKeithley6482}
            api = APIVKeithley6517A;
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
    end
    
end

