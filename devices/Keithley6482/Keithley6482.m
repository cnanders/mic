classdef Keithley6482 < HandlePlus
    
    % All filtering settings are global on both channels:
    % ADC Ingegration Time, Average Filter, Median Filter
    
    properties (Constant)

        dHeight = 270;   % height of the UIElement
        dWidth = 370;   % width of the UIElement
        dWidthBtn = 24;
        dHeightBtn = 24;
        dSepVert = 42;
        dSepVert2 = 25;
        dSepSection = 10;
        dWidthHIOName = 80;
        dWidthHIOVal = 60;
        
        dWidthHioNameCh = 80;
        dWidthHioValCh = 60;
        
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
        
        cName = 'Keithley6482';
        cLabel = 'Keithley6482';
        lActive = false
        
    end
    
    properties (Access = protected)
        clock
        
        uitxName
        
        % {char 1xm} - path to this file
        cPath = fileparts(mfilename('fullpath'));
        % {char 1xm} - path to the folder with all config files
        cPathConfig = fileparts(mfilename('fullpath'));
        
        uitApi      % toggle for real / virtual Api
        apiv
        api
        
        lShowApi = true;
        lShowLabels = false;
       
        hPanel
        
        hoData
        hoData2
        hioADCPeriod
        
        hioRange
        hiotxAutoRangeState
        hiotxAvgFiltState
        % hiotxAvgFiltType
        hiotxAvgFiltMode
        hioAvgFiltSize
        hiotxMedFiltState
        hioMedFiltRank
        
        
        hioRange2
        hiotxAutoRangeState2
        %{
        hiotxAvgFiltState2
        hiotxAvgFiltMode2
        hioAvgFiltSize2
        hiotxMedFiltState2
        hioMedFiltRank2
        %}
        
        
        u8Active
        u8Inactive
        
        uitxLabelChannel1
        uitxLabelChannel2
        uitxLabelChannel
        uitxLabelCurrent
        uitxLabelRange
        uitxLabelAutoRange
    end
    
    
    events
        
    end
    
            
    methods
        
        function this = Keithley6482(varargin)

            % Default paths to config files.  Allow these to be 
            
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
            
            this.hoData.setApi(ApiKeithley6482Data(this.api));
            this.hioRange.setApi(ApiKeithley6482Range(this.api));
            this.hiotxAutoRangeState.setApi(ApiKeithley6482AutoRangeState(this.api));
            this.hioADCPeriod.setApi(ApiKeithley6482AdcPeriod(this.api));
            this.hiotxAvgFiltState.setApi(ApiKeithley6482AvgFiltState(this.api));
            this.hiotxAvgFiltMode.setApi(ApiKeithley6482AvgFiltMode(this.api));
            this.hioAvgFiltSize.setApi(ApiKeithley6482AvgFiltSize(this.api));
            this.hiotxMedFiltState.setApi(ApiKeithley6482MedFiltState(this.api));
            this.hioMedFiltRank.setApi(ApiKeithley6482MedFiltRank(this.api));
            
            this.hoData2.setApi(ApiKeithley6482Data2(this.api));
            
            this.hioRange2.setApi(ApiKeithley6482Range2(this.api));
            this.hiotxAutoRangeState2.setApi(ApiKeithley6482AutoRangeState2(this.api));
            %{
            this.hiotxAvgFiltState2.setApi(ApiKeithley6482AvgFiltState2(this.api));
            this.hiotxAvgFiltMode2.setApi(ApiKeithley6482AvgFiltMode2(this.api));
            this.hioAvgFiltSize2.setApi(ApiKeithley6482AvgFiltSize2(this.api));
            this.hiotxMedFiltState2.setApi(ApiKeithley6482MedFiltState2(this.api));
            this.hioMedFiltRank2.setApi(ApiKeithley6482MedFiltRank2(this.api));
            %}
            
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
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent));
            drawnow
            
            
            dTop = 0;
            dTopLabel = 0;
            dTop = 0;
            dWidthHIOName = 80;
            
            
            % Global
            
            dLeft1 = 0;
            dLeft2 = 120;
            dLeft3 = 280;
            
            dLeft = 0;
           
            % Api toggle
            if this.lShowApi
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightText);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dWidthBtn);
                
            end
            
            this.uitxName.build(this.hPanel, ...
                this.dWidthBtn + 5, ... % left
                (this.dHeightBtn - this.dHeightText)/2, ... % top
                this.dWidthName, ... % width 
                this.dHeightText ... % height
            );
                    
            
            dTop = dTop + 30;
            
            % Two channels
            
            %{
            this.uitxLabelChannel.build(this.hPanel, dLeft1, dTop, 60, this.dHeightText);
            this.uitxLabelCurrent.build(this.hPanel, dLeft1 + 40, dTop, 60, this.dHeightText);
            this.uitxLabelRange.build(this.hPanel, dLeft2, dTop, 60, this.dHeightText);
            this.uitxLabelAutoRange.build(this.hPanel, dLeft3, dTop, 100, this.dHeightText);
            dTop = dTop + 20;
            
            this.hoData.build(this.hPanel, dLeft1, dTop);
            this.hioRange.build(this.hPanel, dLeft2, dTop);
            this.hiotxAutoRangeState.build(this.hPanel, dLeft3, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hoData2.build(this.hPanel, dLeft1, dTop);
            this.hioRange2.build(this.hPanel, dLeft2, dTop);
            this.hiotxAutoRangeState2.build(this.hPanel, dLeft3, dTop);
            dTop = dTop + this.dSepVert2;          
            
            dTop = dTop + this.dSepSection;
            %}
            
            dLeftCh1 = 0;
            dLeftCh2 = 250;
            
            this.uitxLabelChannel1.build(this.hPanel, dLeftCh1, dTop, 60, this.dHeightText);
            this.uitxLabelChannel2.build(this.hPanel, dLeftCh2, dTop, 60, this.dHeightText);
%             this.uitxLabelCurrent.build(this.hPanel, dLeft1 + 40, dTop, 60, this.dHeightText);
%             this.uitxLabelRange.build(this.hPanel, dLeft2, dTop, 60, this.dHeightText);
%             this.uitxLabelAutoRange.build(this.hPanel, dLeft3, dTop, 100, this.dHeightText);
            dTop = dTop + 20;
            
            this.hoData.build(this.hPanel, dLeftCh1, dTop);
            this.hoData2.build(this.hPanel, dLeftCh2, dTop);
            dTop = dTop + this.dSepVert2;

            this.hioRange.build(this.hPanel, dLeftCh1, dTop);
            this.hioRange2.build(this.hPanel, dLeftCh2, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAutoRangeState.build(this.hPanel, dLeftCh1, dTop);
            this.hiotxAutoRangeState2.build(this.hPanel, dLeftCh2, dTop);
            dTop = dTop + this.dSepVert2;          
            dTop = dTop + this.dSepSection;
            
            % Settings
            
            dTop = dTop + 10;
            
            dLeftSettings = 0;
            
            this.hioADCPeriod.build(this.hPanel, dLeftSettings, dTop);
            dTop = dTop + this.dSepVert;
            % dTop = dTop + this.dSepSection;
                        
            this.hiotxAvgFiltState.build(this.hPanel, dLeftSettings, dTop);
            % this.hiotxAvgFiltState2.build(this.hPanel, dLeft2, dTop);
            dTop = dTop + this.dSepVert2;
                        
            this.hiotxAvgFiltMode.build(this.hPanel, dLeftSettings, dTop);
            % this.hiotxAvgFiltMode2.build(this.hPanel, dLeft2, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioAvgFiltSize.build(this.hPanel, dLeftSettings, dTop);
            % this.hioAvgFiltSize2.build(this.hPanel, dLeft2, dTop);
            dTop = dTop + this.dSepVert2;
            % dTop = dTop + this.dSepSection;
            
            this.hiotxMedFiltState.build(this.hPanel, dLeftSettings, dTop);
            % this.hiotxMedFiltState2.build(this.hPanel, dLeft2, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioMedFiltRank.build(this.hPanel, dLeftSettings, dTop);
            % this.hioMedFiltRank2.build(this.hPanel, dLeft2, dTop);
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
                this.apiv = []; % This is calling the setter
            end
            
            this.hoData.turnOn();
            this.hioRange.turnOn();
            this.hiotxAutoRangeState.turnOn();
            this.hioADCPeriod.turnOn();
            this.hiotxAvgFiltState.turnOn();
            this.hiotxAvgFiltMode.turnOn();
            this.hioAvgFiltSize.turnOn();
            this.hiotxMedFiltState.turnOn();
            this.hioMedFiltRank.turnOn();
            
            this.hoData2.turnOn();
            
            this.hioRange2.turnOn();
            this.hiotxAutoRangeState2.turnOn();
            %{
            this.hiotxAvgFiltState2.turnOn();
            this.hiotxAvgFiltMode2.turnOn();
            this.hioAvgFiltSize2.turnOn();
            this.hiotxMedFiltState2.turnOn();
            this.hioMedFiltRank2.turnOn();
            %}
            
        end
        
        
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareIO.turnOn()
        %
        % See also TURNON
        
            % CA 2014.04.14: Make sure Apiv is available
            
            if isempty(this.apiv)
                this.apiv = this.newApiv();
            end
            
            this.lActive = false;
            this.uitApi.lVal = false;
            this.uitApi.setTooltip(this.cTooltipApiOff);
            
            this.hoData.turnOff();
            this.hioRange.turnOff();
            this.hiotxAutoRangeState.turnOff();
            this.hioADCPeriod.turnOff();
            this.hiotxAvgFiltState.turnOff();
            this.hiotxAvgFiltMode.turnOff();
            this.hioAvgFiltSize.turnOff();
            this.hiotxMedFiltState.turnOff();
            this.hioMedFiltRank.turnOff();
            
            this.hoData2.turnOff();
            
            this.hioRange2.turnOff();
            this.hiotxAutoRangeState2.turnOff();
            %{
            this.hiotxAvgFiltState2.turnOff();
            this.hiotxAvgFiltMode2.turnOff();
            this.hioAvgFiltSize2.turnOff();
            this.hiotxMedFiltState2.turnOff();
            this.hioMedFiltRank2.turnOff();
            %}
            
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
            
            this.uitxLabelChannel1 = UIText('Channel 1');
            this.uitxLabelChannel2 = UIText('Channel 2');
            this.uitxLabelChannel = UIText('Chan');
            this.uitxLabelCurrent = UIText('Current (A)');
            this.uitxLabelRange = UIText('Range (A)');
            this.uitxLabelAutoRange = UIText('Auto Range');
            
            this.apiv = this.newApiv();
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
            
            addlistener(this.uitApi, 'eChange', @this.onApiChange);

            this.uitxName = UIText('keithley 6482', 'left');
            
            
            cPathConfigData = fullfile(this.cPathConfig, 'config-data.json');
            cPathConfigRange = fullfile(this.cPathConfig, 'config-range.json');
            cPathAutoRangeState = fullfile(this.cPathConfig, 'config-auto-range-state.json');
            cPathADCPeriod = fullfile(this.cPathConfig, 'config-adc-period.json');
            cPathAvgFiltState = fullfile(this.cPathConfig, 'config-avg-filt-state.json');
            cPathAvgFiltMode = fullfile(this.cPathConfig, 'config-avg-filt-mode.json');
            cPathAvgFiltSize = fullfile(this.cPathConfig, 'config-avg-filt-size.json');
            cPathMedFiltState = fullfile(this.cPathConfig, 'config-med-filt-state.json');
            cPathMedFiltRank = fullfile(this.cPathConfig, 'config-med-filt-rank.json');
            
            configData = ConfigHardwareIOPlus(cPathConfigData);
            configRange = ConfigHardwareIOPlus(cPathConfigRange);
            configAutoRangeState = ConfigHardwareIOText(cPathAutoRangeState);
            
            configData2 = ConfigHardwareIOPlus(cPathConfigData);
            configRange2 = ConfigHardwareIOPlus(cPathConfigRange);
            configAutoRangeState2 = ConfigHardwareIOText(cPathAutoRangeState);
            
            configADCPeriod = ConfigHardwareIOPlus(cPathADCPeriod);
            configAvgFiltState = ConfigHardwareIOText(cPathAvgFiltState);
            configAvgFiltMode = ConfigHardwareIOText(cPathAvgFiltMode);
            configAvgFiltSize = ConfigHardwareIOPlus(cPathAvgFiltSize);
            configMedFiltState = ConfigHardwareIOText(cPathMedFiltState);
            configMedFiltRank = ConfigHardwareIOPlus(cPathMedFiltRank);
            
            
            %{
            configAvgFiltState2 = ConfigHardwareIOText(cPathAvgFiltState);
            configAvgFiltMode2 = ConfigHardwareIOText(cPathAvgFiltMode);
            configAvgFiltSize2 = Config(cPathAvgFiltSize);
            configMedFiltState2 = ConfigHardwareIOText(cPathMedFiltState);
            configMedFiltRank2 = Config(cPathMedFiltRank);
            %}
            
            this.hoData = HardwareOPlus(...
                'cName', sprintf('%s-data', this.cName), ...
                'cLabel', 'current (A)', ...
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
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
        
            this.hoData2 = HardwareOPlus(...
                'cName', sprintf('%s-data2', this.cName), ...
                'cLabel', 'current (A)', ...
                'config', configData2, ...
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
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
        
        
         this.hiotxAutoRangeState = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state', this.cName), ...
                'cLabel', 'auto range', ...
                'config', configAutoRangeState, ...
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            this.hioRange = HardwareIOPlus(...
                'cName', sprintf('%s-range', this.cName), ...
                'cLabel', 'range (A)', ...
                'config', configRange, ...
                'cConversion', 'e', ...
                'lShowName', true, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
        
        
        
                
            this.hiotxAutoRangeState2 = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state2', this.cName), ...
                'cLabel', 'auto range', ...
                'config', configAutoRangeState2, ...
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            this.hioRange2 = HardwareIOPlus(...
                'cName', sprintf('%s-range2', this.cName), ...
                'cLabel', 'range (A)', ...
                'config', configRange2, ...
                'cConversion', 'e', ...
                'lShowName', true, ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthHioNameCh, ...
                'dWidthVal', this.dWidthHioValCh, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'clock', this.clock ...
            );
        
            this.hioADCPeriod = HardwareIOPlus(...
                'cName', sprintf('%s-adc-period', this.cName), ...
                'cLabel', 'adc period (ms)', ...
                'config', configADCPeriod, ...
                'cLabelDest', 'Command', ...
                'cLabelName', 'Settings', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowApi', false, ...
                'lShowLabels', true, ...
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
                'cLabel', 'avg. filter state', ...
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
        
            
            
        
            this.hiotxAvgFiltMode = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode', this.cName), ...
                'cLabel', 'avg. filter mode', ...
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
        
           
            this.hioAvgFiltSize = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size', this.cName), ...
                'cLabel', 'avg. filter size', ...
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
        
            this.hiotxMedFiltState = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state', this.cName), ...
                'cLabel', 'med. filter state', ...
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
            this.hioMedFiltRank =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank', this.cName), ...
                'cLabel', 'med. filter rank', ...
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
             
            addlistener(this.hiotxAutoRangeState, 'eChange', @this.onAutoRangeStateChange);
            addlistener(this.hiotxAvgFiltState, 'eChange', @this.onAvgFiltStateChange);
            addlistener(this.hiotxMedFiltState, 'eChange', @this.onMedFiltStateChange);
            
        
            
              
            
        
           %{
            this.hiotxAvgFiltState2 = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-state2', this.cName), ...
                'cLabel', 'Avg. Filt State', ...
                'config', configAvgFiltState2, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            
            
        
            this.hiotxAvgFiltMode2 = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode2', this.cName), ...
                'cLabel', 'Avg. Filt Mode', ...
                'config', configAvgFiltMode2, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
           
            this.hioAvgFiltSize2 = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size2', this.cName), ...
                'cLabel', 'Avg. Filt Size', ...
                'config', configAvgFiltSize2, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'dWidthDest', this.dWidthHIODest, ...
                'lShowName', false, ...
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
        
            this.hiotxMedFiltState2 = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state2', this.cName), ...
                'cLabel', 'Med. Filt State', ...
                'config', configMedFiltState2, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            this.hioMedFiltRank2 =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank2', this.cName), ...
                'cLabel', 'Med. Filt Rank', ...
                'config', configMedFiltRank2, ...
                'dWidthName', this.dWidthHIOName, ...
                'dWidthVal', this.dWidthHIOVal, ...
                'dWidthStores', this.dWidthHIOStores, ...
                'lShowName', false, ...
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
        
            %}
            addlistener(this.hiotxAutoRangeState2, 'eChange', @this.onAutoRangeStateChange2);
            %addlistener(this.hiotxAvgFiltState2, 'eChange', @this.onAvgFiltStateChange2);
            %addlistener(this.hiotxMedFiltState2, 'eChange', @this.onMedFiltStateChange2);
            
            
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
            api = ApivKeithley6482;
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
            this.hiotxAvgFiltMode.enable();
            this.hioAvgFiltSize.enable();
        end
        
        function disableAvgFilt(this)
            this.hiotxAvgFiltMode.disable();
            this.hioAvgFiltSize.disable();
        end
        
        function enableRange(this)
            this.hioRange.enable();
        end

        function disableRange(this)
            this.hioRange.disable();
        end
        
        
        
        function onAutoRangeStateChange2(this, src, evt)
            switch src.val()
                case 'on'
                    this.disableRange2();
                case 'off'
                    this.enableRange2();
            end
        end
        
        function onAvgFiltStateChange2(this, src, evt)
            switch src.val()
                case 'on'
                    this.enableAvgFilt2();
                case 'off'
                    this.disableAvgFilt2();
            end
        end
        
        function onMedFiltStateChange2(this, src, evt)
            switch src.val()
                case 'on'
                    this.enableMedFilt2();
                case 'off'
                    this.disableMedFilt2();
            end
        end
        
        function enableMedFilt2(this)
            this.hioMedFiltRank2.enable();
        end
        
        function disableMedFilt2(this)
            this.hioMedFiltRank2.disable();
        end
        
        function enableAvgFilt2(this)
            this.hiotxAvgFiltMode2.enable();
            this.hioAvgFiltSize2.enable();
        end
        
        function disableAvgFilt2(this)
            this.hiotxAvgFiltMode2.disable();
            this.hioAvgFiltSize2.disable();
        end
        
        function enableRange2(this)
            this.hioRange2.enable();
        end

        function disableRange2(this)
            this.hioRange2.disable();
        end
        
        
        
    end
    
end

