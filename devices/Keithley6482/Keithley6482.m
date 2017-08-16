classdef Keithley6482 < HandlePlus
    
    % All filtering settings are global on both channels:
    % ADC Ingegration Time, Average Filter, Median Filter
    
    properties (Constant)

        dHeight = 270;   % height of the UIElement
        dWidth = 300;   % width of the UIElement
        dWidthBtn = 24;
        dHeightBtn = 24;
        dSepVert = 42;
        dSepVert2 = 25;
        dSepSection = 10;
        dWidthPanel = 255;
         
        cTooltipApiOff = 'Connect to the real Api / hardware';
        cTooltipApiOn = 'Disconnect the real Api / hardware (go into virtual mode)';

        dHeightPanelOffset = 125
        dHeightPanelRange = 75
        dHeightPanelSettings = 200
        dHeightPanelPad = 10
    end
            
    properties
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'Keithley6482';
        cLabel = 'Keithley6482';
        lActive = false
        
    end
    
    properties (Access = protected)
        
        dWidthPadName = 5;
        dWidthPadData = 0;
        
        dWidthHioName = 90;
        dWidthHioNameData = 50;
        dWidthHioVal = 70;
        dWidthHioStores = 90;
        dWidthHioDest = 90;
        dWidthName = 100;
        dHeightText = 16;
        
        cLabelName = 'Name';
        cLabelValue = 'Val';
        cLabelDest = 'Goal'
        cLabelChannel1 = 'Channel 1';
        cLabelChannel2 = 'Channel 2';
        cLabelPanelOffset1 = 'Offset Channel 1';
        cLabelPanelOffset2 = 'Offset Channel 2';
        cLabelPanelRange1 = 'Range Channel 1';
        cLabelPanelRange2 = 'Range Channel 2';
        cLabelPanelSettings1 = 'Settings';
        cLabelPanelSettings2 = 'Settings';
        
        dBackgroundColor = [.94 .94 .94]
        
        
        clock
        
        uitxName
        
        % {char 1xm} - path to this file
        cPath = fileparts(mfilename('fullpath'));
        % {char 1xm} - path to the folder with all config files
        cPathConfig = fileparts(mfilename('fullpath'));
        
        uitApi      % toggle for real / virtual Api
        apiv
        api
        
        lAskOnApiClick = true;
        lShowApi = true;
        lShowName = true;
        lShowDataChannel1 = true;
        lShowDataChannel2 = true;
        lShowLabels = false;
        
        % {logical 1x1} build HIO UI for ADC period, avg filter and med filter
        lShowSettings = true;
        
        % {logical 1x1} Build HIO UI for range and auto range state
        lShowRange = true;
        
        % {logical 1x1} build hio ui for offset
        lShowOffset = true
        
        hPanel
        hPanelRange1
        hPanelRange2
        hPanelSettings1
        hPanelSettings2
        
        hPanelOffset1
        hPanelOffset2
        
        hoData
        hoData2
        
        % Range 1
        hioRange1
        hiotxAutoRangeState1
        
        hioOffset1Value
        hiotxOffset1State
        hioOffset2Value
        hiotxOffset2State
        
        uibSetOffset1ToCurrentReading
        uibSetOffset2ToCurrentReading
        
        % Settings 1
        hioADCPeriod
        hiotxAvgFiltState
        % hiotxAvgFiltType
        hiotxAvgFiltMode
        hioAvgFiltSize
        hiotxMedFiltState
        hioMedFiltRank
        
        % Range 2
        hioRange2
        hiotxAutoRangeState2
        
        % Settings 2
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
        
        lhApi
        lhAutoRangeState1
        lhAutoRangeState2
        lhAvgFiltState
        lhMedFiltState
        lhAvgFiltState2
        lhMedFiltState2
        
        lhSetOffset1ToCurrentReading
        lhSetOffset2ToCurrentReading
    end
    
    
    events
        
    end
    
            
    methods
        
        function this = Keithley6482(varargin)

            % Default paths to config files.  Allow these to be 
            
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
            
            %{
            this.hoData.setApi(ApiKeithley6482Data(this.api));
            this.hoData2.setApi(ApiKeithley6482Data2(this.api));
            %}
            
            this.hoData.setApi(ApiHardwareOPlusFromKeithley6482(this.api, 'calc-result', 1));
            this.hoData2.setApi(ApiHardwareOPlusFromKeithley6482(this.api, 'calc-result', 2));
            
            this.setApiOffset();
            this.setApiRange();
            this.setApiSettings();
            
        end
        
        function setApiOffset(this)
            this.setApiOffset1();
            this.setApiOffset2();
        end
        
        function setApiOffset1(this)
            if ~this.lShowOffset
                return
            end
            
            u8Channel = uint8(1);
            this.hioOffset1Value.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'offset-value', u8Channel));
            this.hiotxOffset1State.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'offset-state', u8Channel));
            
        end
        
        
        function setApiOffset2(this)
            if ~this.lShowOffset
                return
            end
            
            u8Channel = uint8(2);
            this.hioOffset2Value.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'offset-value', u8Channel));
            this.hiotxOffset2State.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'offset-state', u8Channel));
            
        end
        
        function setApiRange(this)
            this.setApiRange1();
            this.setApiRange2();
        end
        
        function setApiRange1(this)
            
            if ~this.lShowRange
                return
            end
            
            %{
            this.hioRange1.setApi(ApiKeithley6482Range(this.api));
            this.hiotxAutoRangeState1.setApi(ApiKeithley6482AutoRangeState(this.api));
            %}
            
            u8Channel = uint8(1);
            this.hioRange1.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'range', u8Channel));
            this.hiotxAutoRangeState1.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'auto-range-state', u8Channel));
            
            
        end
        
        function setApiRange2(this)
            
            if ~this.lShowRange
                return
            end
            %this.hioRange2.setApi(ApiKeithley6482Range2(this.api));
            %this.hiotxAutoRangeState2.setApi(ApiKeithley6482AutoRangeState2(this.api));
            
            u8Channel = uint8(2);
            this.hioRange2.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'range', u8Channel));
            this.hiotxAutoRangeState2.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'auto-range-state', u8Channel));
            
           
        end
        
        function setApiSettings(this)
            this.setApiSettings1();
            this.setApiSettings2();
        end
        
        
        function setApiSettings1(this)
            
            if ~this.lShowSettings
                return
            end
            
%             this.hioADCPeriod.setApi(ApiKeithley6482AdcPeriod(this.api));
%             this.hiotxAvgFiltState.setApi(ApiKeithley6482AvgFiltState(this.api));
%             this.hiotxAvgFiltMode.setApi(ApiKeithley6482AvgFiltMode(this.api));
%             this.hioAvgFiltSize.setApi(ApiKeithley6482AvgFiltSize(this.api));
%             this.hiotxMedFiltState.setApi(ApiKeithley6482MedFiltState(this.api));
%             this.hioMedFiltRank.setApi(ApiKeithley6482MedFiltRank(this.api));
            
            % ApiHardwareIOPlusFromKeithley
            % ApiHardwareIOTextFromKeithley
            % ApiHardwareOPlusFromKeithley
            
            u8Channel = uint8(1);
            this.hioADCPeriod.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'adc-period', u8Channel));
            this.hiotxAvgFiltState.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'avg-filt-state', u8Channel));
            this.hiotxAvgFiltMode.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'avg-filt-mode', u8Channel));
            this.hioAvgFiltSize.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'avg-filt-size', u8Channel));
            this.hiotxMedFiltState.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'med-filt-state', u8Channel));
            this.hioMedFiltRank.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'med-filt-rank', u8Channel));

             
        end
        
        function setApiSettings2(this)
            %{
            if ~this.lShowSettings
                return
            end
            
            this.hiotxAvgFiltState2.setApi(ApiKeithley6482AvgFiltState2(this.api));
            this.hiotxAvgFiltMode2.setApi(ApiKeithley6482AvgFiltMode2(this.api));
            this.hioAvgFiltSize2.setApi(ApiKeithley6482AvgFiltSize2(this.api));
            this.hiotxMedFiltState2.setApi(ApiKeithley6482MedFiltState2(this.api));
            this.hioMedFiltRank2.setApi(ApiKeithley6482MedFiltRank2(this.api));
            %}
            
            %{
            % 2017.01.10 syntax
            u8Channel = uint8(2);
            this.hioADCPeriod2.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'adc-period', u8Channel));
            this.hiotxAvgFiltState2.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'avg-filt-state', u8Channel));
            this.hiotxAvgFiltMode2.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'avg-filt-mode', u8Channel));
            this.hioAvgFiltSize2.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'avg-filt-size', u8Channel));
            this.hiotxMedFiltState2.setApi(ApiHardwareIOTextFromKeithley6482(this.api, 'med-filt-state', u8Channel));
            this.hioMedFiltRank2.setApi(ApiHardwareIOPlusFromKeithley6482(this.api, 'med-filt-rank', u8Channel));

            %}
        end
        
        
        
        
        function setApiv(this, api)
            
            this.apiv = api;
           
            % this.hoData.setApiv(ApiKeithley6482Data(this.apiv));
            % this.hoData2.setApiv(ApiKeithley6482Data2(this.apiv));
            
            this.hoData.setApiv(ApiHardwareOPlusFromKeithley6482(this.apiv, 'calc-result', 1));
            this.hoData2.setApiv(ApiHardwareOPlusFromKeithley6482(this.apiv, 'calc-result', 2));
            
            this.setApivOffset();
            this.setApivRange();
            this.setApivSettings();
            
        end
        
        function setApivOffset(this)
            this.setApivOffset1();
            this.setApivOffset2();
        end
        
        function setApivRange(this)
            this.setApivRange1();
            this.setApivRange2();
        end
        
        function setApivRange1(this)
            
            if ~this.lShowRange
                return
            end
            
            % this.hioRange1.setApiv(ApiKeithley6482Range(this.apiv));
            % this.hiotxAutoRangeState1.setApiv(ApiKeithley6482AutoRangeState(this.apiv));
            
            u8Channel = uint8(1);
            this.hioRange1.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'range', u8Channel));
            this.hiotxAutoRangeState1.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'auto-range-state', u8Channel));
            
        end
        
        function setApivRange2(this)
            
            if ~this.lShowRange
                return
            end
            %this.hioRange2.setApiv(ApiKeithley6482Range2(this.apiv));
            %this.hiotxAutoRangeState2.setApiv(ApiKeithley6482AutoRangeState2(this.apiv));
           
            u8Channel = uint8(2);
            this.hioRange2.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'range', u8Channel));
            this.hiotxAutoRangeState2.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'auto-range-state', u8Channel));
            
        end
        
        function setApivSettings(this)
            this.setApivSettings1();
            this.setApivSettings2();
        end
        
        function setApivOffset1(this)
            if ~this.lShowOffset
                return
            end
            
            u8Channel = uint8(1);
            this.hioOffset1Value.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'offset-value', u8Channel));
            this.hiotxOffset1State.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'offset-state', u8Channel));
            
        end
        
        
        function setApivOffset2(this)
            if ~this.lShowOffset
                return
            end
            
            u8Channel = uint8(2);
            this.hioOffset2Value.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'offset-value', u8Channel));
            this.hiotxOffset2State.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'offset-state', u8Channel));
            
        end
        
        function setApivSettings1(this)
            
            if ~this.lShowSettings
                return
            end
            
            %{
            this.hioADCPeriod.setApiv(ApiKeithley6482AdcPeriod(this.apiv));
            this.hiotxAvgFiltState.setApiv(ApiKeithley6482AvgFiltState(this.apiv));
            this.hiotxAvgFiltMode.setApiv(ApiKeithley6482AvgFiltMode(this.apiv));
            this.hioAvgFiltSize.setApiv(ApiKeithley6482AvgFiltSize(this.apiv));
            this.hiotxMedFiltState.setApiv(ApiKeithley6482MedFiltState(this.apiv));
            this.hioMedFiltRank.setApiv(ApiKeithley6482MedFiltRank(this.apiv));
            %}
            
            u8Channel = uint8(1);
            this.hioADCPeriod.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'adc-period', u8Channel));
            this.hiotxAvgFiltState.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'avg-filt-state', u8Channel));
            this.hiotxAvgFiltMode.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'avg-filt-mode', u8Channel));
            this.hioAvgFiltSize.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'avg-filt-size', u8Channel));
            this.hiotxMedFiltState.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'med-filt-state', u8Channel));
            this.hioMedFiltRank.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'med-filt-rank', u8Channel));

             
        end
        
        function setApivSettings2(this)
            %{
            if ~this.lShowSettings
                return
            end
            
            this.hiotxAvgFiltState2.setApiv(ApiKeithley6482AvgFiltState2(this.apiv));
            this.hiotxAvgFiltMode2.setApiv(ApiKeithley6482AvgFiltMode2(this.apiv));
            this.hioAvgFiltSize2.setApiv(ApiKeithley6482AvgFiltSize2(this.apiv));
            this.hiotxMedFiltState2.setApiv(ApiKeithley6482MedFiltState2(this.apiv));
            this.hioMedFiltRank2.setApiv(ApiKeithley6482MedFiltRank2(this.apiv));
            %}
            
            %{
            u8Channel = uint8(2);
            this.hioADCPeriod2.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'adc-period', u8Channel));
            this.hiotxAvgFiltState2.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'avg-filt-state', u8Channel));
            this.hiotxAvgFiltMode2.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'avg-filt-mode', u8Channel));
            this.hioAvgFiltSize2.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'avg-filt-size', u8Channel));
            this.hiotxMedFiltState2.setApiv(ApiHardwareIOTextFromKeithley6482(this.apiv, 'med-filt-state', u8Channel));
            this.hioMedFiltRank2.setApiv(ApiHardwareIOPlusFromKeithley6482(this.apiv, 'med-filt-rank', u8Channel));
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
                'Position', MicUtils.lt2lb([dLeft dTop this.dWidth this.getHeight()], hParent));
            drawnow
            
                        
            dTop = 10;
            dTopLabel = 10;
            dWidthHioName = 80;
            dLeft = 10;
                                   
            % Api toggle
            if this.lShowApi
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightText);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dWidthBtn);
                
                dLeft = dLeft + this.dWidthBtn;
            end
            
            if this.lShowName
                
                dLeft = dLeft + this.dWidthPadName;
                
                this.uitxName.build(this.hPanel, ...
                    dLeft, ... % left
                    dTop + (this.dHeightBtn - this.dHeightText)/2, ... % top
                    this.dWidthName, ... % width 
                    this.dHeightText ... % height
                );
            
                dLeft = dLeft + this.dWidthName;
            end
                  
            % this.uitxLabelChannel1.build(this.hPanel, dLeft, dTop, 60, this.dHeightText);
            % this.uitxLabelChannel2.build(this.hPanel, dLeft, dTop, 60, this.dHeightText);
%             this.uitxLabelCurrent.build(this.hPanel, dLeft1 + 40, dTop, 60, this.dHeightText);
%             this.uitxLabelRange.build(this.hPanel, dLeft2, dTop, 60, this.dHeightText);
%             this.uitxLabelAutoRange.build(this.hPanel, dLeft3, dTop, 100, this.dHeightText);
          
            dTop = 8;
            
            if this.lShowDataChannel1
                dLeft = dLeft + this.dWidthPadData;
                this.hoData.build(this.hPanel, dLeft, dTop);
                dTop = dTop + this.dSepVert2 - 5;
            end
            
            if this.lShowDataChannel2
                this.hoData2.build(this.hPanel, dLeft, dTop);
            end
                                    
            % Settings
            this.buildOffset1();
            this.buildOffset2();
            this.buildRange1();
            this.buildRange2();
            this.buildSettings();
                        
            
        end
        
        
        function buildOffset1(this)
            
            
            if ~this.lShowOffset
                return
            end
            
            dTop = 55;
            
            this.hPanelOffset1 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', this.cLabelPanelOffset1, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 dTop this.dWidth - 20 this.dHeightPanelOffset], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            this.hioOffset1Value.build(this.hPanelOffset1, dLeft, dTop);
            dTop = dTop + this.dSepVert;
                                    
            this.hiotxOffset1State.build(this.hPanelOffset1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.uibSetOffset1ToCurrentReading.build(this.hPanelOffset1, dLeft, dTop, 250, 24);
            dTop = dTop + this.dSepVert2;
            
        end
        
        function buildOffset2(this)
            
            if ~this.lShowOffset
                return
            end
            
            dTop = 55;
            dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;

            
            this.hPanelOffset2 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', this.cLabelPanelOffset2, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 dTop this.dWidth - 20 this.dHeightPanelOffset], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            
            this.hioOffset2Value.build(this.hPanelOffset2, dLeft, dTop);
            dTop = dTop + this.dSepVert;
                                    
            this.hiotxOffset2State.build(this.hPanelOffset2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.uibSetOffset2ToCurrentReading.build(this.hPanelOffset2, dLeft, dTop, 250, 24);
            dTop = dTop + this.dSepVert2;
        end
        
        function buildRange1(this)
            
            if ~this.lShowRange
                return
            end
            
            dTop = 55;
            if this.lShowOffset
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
            end
            
            this.hPanelRange1 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', this.cLabelPanelRange1, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 dTop this.dWidth - 20 this.dHeightPanelRange], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            this.hioRange1.build(this.hPanelRange1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAutoRangeState1.build(this.hPanelRange1, dLeft, dTop);
        end
        
        function buildRange2(this)
            
            if ~this.lShowRange
                return
            end
            
            dTop = 55;
            
            if this.lShowOffset
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
            end
            
            dTop = dTop + this.dHeightPanelRange + this.dHeightPanelPad;
            
            this.hPanelRange2 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', this.cLabelPanelRange2, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 dTop this.dWidth - 20 this.dHeightPanelRange], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            this.hioRange2.build(this.hPanelRange2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxAutoRangeState2.build(this.hPanelRange2, dLeft, dTop);
            
            
        end
        
        function buildSettings(this)
           
            if ~this.lShowSettings
                return
            end
            
            dTop = 55;
            
            if this.lShowOffset
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
                dTop = dTop + this.dHeightPanelOffset + this.dHeightPanelPad;
            end
            
            if this.lShowRange
                dTop = dTop + this.dHeightPanelRange + this.dHeightPanelPad;
                dTop = dTop + this.dHeightPanelRange + this.dHeightPanelPad;
            end
            
            this.hPanelSettings1 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title', this.cLabelPanelSettings1, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 dTop this.dWidth - 20 this.dHeightPanelSettings], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            this.hioADCPeriod.build(this.hPanelSettings1, dLeft, dTop);
            dTop = dTop + this.dSepVert;
                        
            this.hiotxAvgFiltState.build(this.hPanelSettings1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
                        
            this.hiotxAvgFiltMode.build(this.hPanelSettings1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioAvgFiltSize.build(this.hPanelSettings1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxMedFiltState.build(this.hPanelSettings1, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioMedFiltRank.build(this.hPanelSettings1, dLeft, dTop);
            
            
        end
        
        
        function buildSettings2(this)
           
            %{
            this.hPanelSettings2 = uipanel( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Title',  this.cLabelPanelSettings1, ...
                'Clipping', 'on', ...
                'BorderWidth', 1, ... 
                'BackgroundColor', this.dBackgroundColor, ...
                'Position', MicUtils.lt2lb([10 150 this.dWidth - 20  195], this.hPanel) ...
            );
            drawnow
            
            dTop = 20;
            dLeft = 10;
            
            
            this.hioADCPeriod.build(this.hPanelSettings2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
                        
            this.hiotxAvgFiltState2.build(this.hPanelSettings2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
                        
            this.hiotxAvgFiltMode2.build(this.hPanelSettings2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioAvgFiltSize2.build(this.hPanelSettings2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hiotxMedFiltState2.build(this.hPanelSettings2, dLeft, dTop);
            dTop = dTop + this.dSepVert2;
            
            this.hioMedFiltRank2.build(this.hPanelSettings2, dLeft, dTop);
            %}
            
        end
        
        
        function deleteOffset1(this)
            
            if ~this.lShowOffset
                return;
            end

            delete(this.lhSetOffset1ToCurrentReading);
            delete(this.hioOffset1Value);
            delete(this.hiotxOffset1State);
        
        end
        
        
        function deleteOffset2(this)
            
            if ~this.lShowOffset
                return;
            end

            delete(this.lhSetOffset2ToCurrentReading);
            delete(this.hioOffset2Value);
            delete(this.hiotxOffset2State);
        
        end
        
        function deleteRange1(this)
            
            if ~this.lShowRange
                return;
            end

            delete(this.lhAutoRangeState1);

            delete(this.hioRange1);
            delete(this.hiotxAutoRangeState1);
        
       
        end
        
        function deleteRange2(this)
            
            if ~this.lShowRange
                return;
            end
            
            delete(this.lhAutoRangeState2);

            delete(this.hioRange2);
            delete(this.hiotxAutoRangeState2);

        
        end
        
        function deleteSettings1(this)
            
            if ~this.lShowSettings
                return;
            end
            
            % Listeners
            delete(this.lhAvgFiltState);
            delete(this.lhMedFiltState);
        
            delete(this.hioADCPeriod);
            delete(this.hiotxAvgFiltState);
            delete(this.hiotxAvgFiltMode);
            delete(this.hioAvgFiltSize);
            delete(this.hiotxMedFiltState);
            delete(this.hioMedFiltRank);
        end
        
        function deleteSettings2(this)
            if ~this.lShowSettings
                return;
            end
            
            %{
            
            % Listeners
            delete(this.lhAvgFiltState2);
            delete(this.lhMedFiltState2);
        
            delete(this.hiotxAvgFiltState2);
            delete(this.hiotxAvgFiltMode2);
            delete(this.hioAvgFiltSize2);
            delete(this.hiotxMedFiltState2);
            delete(this.hioMedFiltRank2);
            %}
         
        end
        
        
        function delete(this)
            
            this.msg('delete', 5);
            
            delete(this.lhApi);
            
            delete(this.hoData);
            delete(this.hoData2);
            
            this.deleteOffset1();
            this.deleteOffset2();
            
            this.deleteRange1();
            this.deleteRange2();
            this.deleteSettings1();
            this.deleteSettings2();
            
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
                this.setApiv([]); % This is calling the setter
            end
            
            this.hoData.turnOn();
            this.hoData2.turnOn();
            
            this.turnOnOffset();
            this.turnOnRange();
            this.turnOnSettings();
            
            
        end
        
        
        function turnOnOffset(this)
            this.turnOnOffset1()
            this.turnOnOffset2()
        end
        
        function turnOnRange(this)
            this.turnOnRange1();
            this.turnOnRange2();
        end
        
        function turnOnOffset1(this)
            if ~this.lShowRange
                return
            end
            
            this.hioOffset1Value.turnOn();
            this.hiotxOffset1State.turnOn();
        end
        
        function turnOnOffset2(this)
            if ~this.lShowRange
                return
            end
            
            this.hioOffset2Value.turnOn();
            this.hiotxOffset2State.turnOn();
        end
        
        
        
        function turnOnRange1(this)
            if ~this.lShowRange
                return
            end
            this.hioRange1.turnOn();
            this.hiotxAutoRangeState1.turnOn();
        end
        
        function turnOnRange2(this)
            if ~this.lShowRange
                return
            end
            this.hioRange2.turnOn();
            this.hiotxAutoRangeState2.turnOn();
            
        end
        
        function turnOnSettings(this)
            this.turnOnSettings1();
            this.turnOnSettings2();
            
        end
        
        function turnOnSettings1(this)
            
            if ~this.lShowSettings
                return
            end
            this.hioADCPeriod.turnOn();
            this.hiotxAvgFiltState.turnOn();
            this.hiotxAvgFiltMode.turnOn();
            this.hioAvgFiltSize.turnOn();
            this.hiotxMedFiltState.turnOn();
            this.hioMedFiltRank.turnOn();
        end
        
        function turnOnSettings2(this)
            %{
            if ~this.lShowSettings
                return
            end
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
                this.setApiv(this.newApiv());
            end
            
            this.lActive = false;
            this.uitApi.lVal = false;
            this.uitApi.setTooltip(this.cTooltipApiOff);
            
            this.hoData.turnOff();
            this.hoData2.turnOff();
            
            this.turnOffOffset();
            this.turnOffRange();
            this.turnOffSettings();
            
           
        end
        
        function turnOffOffset(this)
            this.turnOffOffset1();
            this.turnOffOffset2();
            
        end
        
        function turnOffOffset1(this)
            if ~this.lShowOffset
                return
            end
            
            this.hioOffset1Value.turnOff();
            this.hiotxOffset1State.turnOff();
            
        end
        
        function turnOffOffset2(this)
            if ~this.lShowOffset
                return
            end
            
            this.hioOffset2Value.turnOff();
            this.hiotxOffset2State.turnOff();
            
        end
        
        function turnOffRange(this)
            this.turnOffRange1();
            this.turnOffRange2();
        end
        
        function turnOffRange1(this)
            if ~this.lShowRange
                return
            end
            this.hioRange1.turnOff();
            this.hiotxAutoRangeState1.turnOff();
        end
        
        function turnOffRange2(this)
            if ~this.lShowRange
                return
            end
            this.hioRange2.turnOff();
            this.hiotxAutoRangeState2.turnOff();
            
        end
        
        function turnOffSettings(this)
            this.turnOffSettings1();
            this.turnOffSettings2();
            
        end
        
        function turnOffSettings1(this)
            
            if ~this.lShowSettings
                return
            end
            
            this.hioADCPeriod.turnOff();
            this.hiotxAvgFiltState.turnOff();
            this.hiotxAvgFiltMode.turnOff();
            this.hioAvgFiltSize.turnOff();
            this.hiotxMedFiltState.turnOff();
            this.hioMedFiltRank.turnOff();
        end
        
        function turnOffSettings2(this)
            %{
            
            if ~this.lShowSettings
                return
            end
            
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
        
        function l = validateOffsetValue(this)
            l = true; 
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
            
            this.u8Active = imread(fullfile(...
               MicUtils.pathAssets(), ...
                'hiot-horiz-24-true.png'...
            ));
        
            this.u8Inactive = imread(fullfile(...
                MicUtils.pathAssets(), ...
                'hiot-horiz-24-false-yellow.png'...
            ));
            
            
            st1 = struct();
            st1.lAsk        = this.lAskOnApiClick;
            st1.cTitle      = 'Switch?';
            st1.cQuestion   = 'Do you want to change from the virtual Api to the real Api?';
            st1.cAnswer1    = 'Yes of course!';
            st1.cAnswer2    = 'No not yet.';
            st1.cDefault    = st1.cAnswer2;

            st2 = struct();
            st2.lAsk        = this.lAskOnApiClick;
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
            this.lhApi = addlistener(this.uitApi, 'eChange', @this.onApiChange);

            this.uitxName = UIText(this.cLabelName, 'left');            
            cPathConfigData = fullfile(this.cPathConfig, 'config-data.json');
            
            
            configData = ConfigHardwareIOPlus(cPathConfigData);
            this.hoData = HardwareOPlus(...
                'cName', sprintf('%s-data', this.cName), ...
                'cLabel', this.cLabelChannel1, ...
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
                'dWidthName', this.dWidthHioNameData, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'clock', this.clock ...
            );
        
            configData2 = ConfigHardwareIOPlus(cPathConfigData);            
            this.hoData2 = HardwareOPlus(...
                'cName', sprintf('%s-data2', this.cName), ...
                'cLabel', this.cLabelChannel2, ...
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
                'dWidthName', this.dWidthHioNameData, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'clock', this.clock ...
            );
        
        
            this.initOffset1();
            this.initOffset2();
            this.initRange1();
            this.initRange2();
            this.initSettings(); % see initSettings2()
            
            this.setApiv(this.newApiv());

              
        end
        
        function initOffset1(this)
            
           if ~this.lShowOffset
               return
           end
           
           
            cPathConfigOffset1Value = fullfile(this.cPathConfig, 'config-offset-value.json');
            cPathConfigOffset1State = fullfile(this.cPathConfig, 'config-offset-state.json');
            
            configOffset1Value = ConfigHardwareIOPlus(cPathConfigOffset1Value);
            this.hioOffset1Value = HardwareIOPlus(...
                'cName', sprintf('%s-offset1-value', this.cName), ...
                'cLabel', 'Value (A)', ...
                'config', configOffset1Value, ...
                'cLabelDest', 'Command', ...
                'cLabelName', 'Name', ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowApi', false, ...
                'lShowLabels', true, ...
                'lShowPlay', false, ...
                'dWidthPadName', 0, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'dWidthDest', this.dWidthHioDest, ...
                'fhValidateDest', @this.validateOffsetValue, ...
                'clock', this.clock ...
            );
        
        
            configOffset1State = ConfigHardwareIOText(cPathConfigOffset1State);
            this.hiotxOffset1State = HardwareIOText(...
                'cName', sprintf('%s-offset1-state', this.cName), ...
                'cLabel', 'State', ...
                'config', configOffset1State, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            this.uibSetOffset1ToCurrentReading = UIButton( ...
                'Set offset to current signal level' ...
            );
            this.uibSetOffset1ToCurrentReading.setTooltip(...
                'Set the offset of channel 1 to the current (now) signal level of channel 1 and include the offset in reported values (turn on)' ...
            );
        
            this.lhSetOffset1ToCurrentReading = addlistener(...
                 this.uibSetOffset1ToCurrentReading, ...
                 'eChange', ...
                 @this.onSetOffset1ToCurrentReadingClick ...
            );
           
                      
        end
        
        
        function initOffset2(this)
            
           if ~this.lShowOffset
               return
           end
           
            cPathConfigOffset2Value = fullfile(this.cPathConfig, 'config-offset-value.json');
            cPathConfigOffset2State = fullfile(this.cPathConfig, 'config-offset-state.json');
            
            configOffset2Value = ConfigHardwareIOPlus(cPathConfigOffset2Value);
            this.hioOffset2Value = HardwareIOPlus(...
                'cName', sprintf('%s-offset2-value', this.cName), ...
                'cLabel', 'Value (A)', ...
                'config', configOffset2Value, ...
                'cLabelDest', 'Command', ...
                'cLabelName', 'Name', ...
                'cConversion', 'e', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowApi', false, ...
                'lShowLabels', true, ...
                'lShowPlay', false, ...
                'dWidthPadName', 0, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'dWidthDest', this.dWidthHioDest, ...
                'fhValidateDest', @this.validateOffsetValue, ...
                'clock', this.clock ...
            );
        
        
            configOffset2State = ConfigHardwareIOText(cPathConfigOffset2State);
            this.hiotxOffset2State = HardwareIOText(...
                'cName', sprintf('%s-offset2-state', this.cName), ...
                'cLabel', 'State', ...
                'config', configOffset2State, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
        
            this.uibSetOffset2ToCurrentReading = UIButton( ...
                'Set offset to current signal level' ...
            );
            this.uibSetOffset2ToCurrentReading.setTooltip(...
                'Set the offset of channel 2 to the current (now) signal level of channel 2 and include the offset in reported values (turn on).' ...
            );
        
            this.lhSetOffset2ToCurrentReading = addlistener(...
                 this.uibSetOffset2ToCurrentReading, ...
                 'eChange', ...
                 @this.onSetOffset2ToCurrentReadingClick ...
            );
           
        end
        
        function initRange1(this)
            
            if ~this.lShowRange
                return
            end
            
            cPathConfigRange = fullfile(this.cPathConfig, 'config-range.json');
            cPathAutoRangeState = fullfile(this.cPathConfig, 'config-auto-range-state.json');
            
            configAutoRangeState1 = ConfigHardwareIOText(cPathAutoRangeState);
            this.hiotxAutoRangeState1 = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state1', this.cName), ...
                'cLabel', 'auto range', ...
                'config', configAutoRangeState1, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            configRange1 = ConfigHardwareIOPlus(cPathConfigRange);
            this.hioRange1 = HardwareIOPlus(...
                'cName', sprintf('%s-range1', this.cName), ...
                'cLabel', 'Value (A)', ...
                'config', configRange1, ...
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
                'dWidthPadName', 0, ...
                'dWidthPadStores', 5, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'clock', this.clock ...
            );
            this.lhAutoRangeState1 = addlistener(this.hiotxAutoRangeState1, 'eChange', @this.onAutoRangeStateChange1);
                    
        end
        
        function initRange2(this)
            
            if ~this.lShowRange
                return
            end
            
            cPathConfigRange = fullfile(this.cPathConfig, 'config-range.json');
            cPathAutoRangeState = fullfile(this.cPathConfig, 'config-auto-range-state.json');
            
            configAutoRangeState2 = ConfigHardwareIOText(cPathAutoRangeState);
            this.hiotxAutoRangeState2 = HardwareIOText(...
                'cName', sprintf('%s-auto-range-state2', this.cName), ...
                'cLabel', 'auto range', ...
                'config', configAutoRangeState2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'cLabelStores', 'Command', ...
                'cLabelName', 'Setting', ...
                'lShowName', true, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            configRange2 = ConfigHardwareIOPlus(cPathConfigRange);
            this.hioRange2 = HardwareIOPlus(...
                'cName', sprintf('%s-range2', this.cName), ...
                'cLabel', 'Value (A)', ...
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
                'dWidthPadName', 0, ...
                'dWidthPadStores', 5, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'clock', this.clock ...
            );
            this.lhAutoRangeState2 = addlistener(this.hiotxAutoRangeState2, 'eChange', @this.onAutoRangeStateChange2);
        
        
        end
        
        function initSettings(this)
            if ~this.lShowSettings
                return
            end
            
            cPathADCPeriod = fullfile(this.cPathConfig, 'config-adc-period.json');
            cPathAvgFiltState = fullfile(this.cPathConfig, 'config-avg-filt-state.json');
            cPathAvgFiltMode = fullfile(this.cPathConfig, 'config-avg-filt-mode.json');
            cPathAvgFiltSize = fullfile(this.cPathConfig, 'config-avg-filt-size.json');
            cPathMedFiltState = fullfile(this.cPathConfig, 'config-med-filt-state.json');
            cPathMedFiltRank = fullfile(this.cPathConfig, 'config-med-filt-rank.json');
            
            
            configADCPeriod = ConfigHardwareIOPlus(cPathADCPeriod);
            this.hioADCPeriod = HardwareIOPlus(...
                'cName', sprintf('%s-adc-period', this.cName), ...
                'cLabel', 'adc period (ms)', ...
                'config', configADCPeriod, ...
                'cLabelDest', 'Command', ...
                'cLabelName', 'Name', ...
                'lShowJog', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowApi', false, ...
                'lShowLabels', true, ...
                'lShowPlay', false, ...
                'dWidthPadName', 0, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'dWidthDest', this.dWidthHioDest, ...
                'fhValidateDest', @this.validateADCPeriod, ...
                'clock', this.clock ...
            );
                
           
            configAvgFiltState = ConfigHardwareIOText(cPathAvgFiltState);
            this.hiotxAvgFiltState = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-state', this.cName), ...
                'cLabel', 'avg. filter state', ...
                'config', configAvgFiltState, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            
            configAvgFiltMode = ConfigHardwareIOText(cPathAvgFiltMode);
            this.hiotxAvgFiltMode = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode', this.cName), ...
                'cLabel', 'avg. filter mode', ...
                'config', configAvgFiltMode, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
           
            configAvgFiltSize = ConfigHardwareIOPlus(cPathAvgFiltSize);
            this.hioAvgFiltSize = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size', this.cName), ...
                'cLabel', 'avg. filter size', ...
                'config', configAvgFiltSize, ...
                'dWidthPadName', 0, ...
                'dWidthPadStores', 5, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'dWidthDest', this.dWidthHioDest, ...
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
        
            configMedFiltState = ConfigHardwareIOText(cPathMedFiltState);
            this.hiotxMedFiltState = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state', this.cName), ...
                'cLabel', 'med. filter state', ...
                'config', configMedFiltState, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            configMedFiltRank = ConfigHardwareIOPlus(cPathMedFiltRank);
            this.hioMedFiltRank =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank', this.cName), ...
                'cLabel', 'med. filter rank', ...
                'config', configMedFiltRank, ...
                'dWidthPadName', 0, ...
                'dWidthPadStores', 5, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
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
        
            this.lhAvgFiltState = addlistener(this.hiotxAvgFiltState, 'eChange', @this.onAvgFiltStateChange);
            this.lhMedFiltState = addlistener(this.hiotxMedFiltState, 'eChange', @this.onMedFiltStateChange);
            
        
            
            
            
        end
        
        % Initially I thought each channel had its own digital settings but
        % they don't.  They use common ADC, avg. filt, and med. filt
        % Leaving this here in case they develop a new model that does have
        % independent settings
        
        function initSettings2(this)
            
            %{
            
            configAvgFiltState2 = ConfigHardwareIOText(cPathAvgFiltState);
            this.hiotxAvgFiltState2 = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-state2', this.cName), ...
                'cLabel', 'Avg. Filt State', ...
                'config', configAvgFiltState2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            
            configAvgFiltMode2 = ConfigHardwareIOText(cPathAvgFiltMode);
            this.hiotxAvgFiltMode2 = HardwareIOText(...
                'cName', sprintf('%s-avg-filt-mode2', this.cName), ...
                'cLabel', 'Avg. Filt Mode', ...
                'config', configAvgFiltMode2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
        
            configAvgFiltSize2 = Config(cPathAvgFiltSize);
            this.hioAvgFiltSize2 = HardwareIOPlus(...
                'cName', sprintf('%s-avg-filt-size2', this.cName), ...
                'cLabel', 'Avg. Filt Size', ...
                'config', configAvgFiltSize2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'dWidthDest', this.dWidthHioDest, ...
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
        
            configMedFiltState2 = ConfigHardwareIOText(cPathMedFiltState);
            this.hiotxMedFiltState2 = HardwareIOText(...
                'cName', sprintf('%s-med-filt-state2', this.cName), ...
                'cLabel', 'Med. Filt State', ...
                'config', configMedFiltState2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
                'lShowName', false, ...
                'lShowPlay', false, ...
                'lShowApi', false, ...
                'lShowLabels', false, ...
                'lShowDest', false, ...
                'clock', this.clock ...
            );
            
            configMedFiltRank2 = Config(cPathMedFiltRank);
            this.hioMedFiltRank2 =  HardwareIOPlus(...
                'cName', sprintf('%s-med-filter-rank2', this.cName), ...
                'cLabel', 'Med. Filt Rank', ...
                'config', configMedFiltRank2, ...
                'dWidthName', this.dWidthHioName, ...
                'dWidthVal', this.dWidthHioVal, ...
                'dWidthStores', this.dWidthHioStores, ...
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
            
            this.lhAvgFiltState2 = addlistener(this.hiotxAvgFiltState2, 'eChange', @this.onAvgFiltStateChange2);
            this.lhMedFiltState2 = addlistener(this.hiotxMedFiltState2, 'eChange', @this.onMedFiltStateChange2);
            
        
            %}
            
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
        
        function onSetOffset1ToCurrentReadingClick(this, src, evt)
           
            if this.lActive
                this.api.setChannel1OffsetValueToCurrentReading();
                % this.api.setChannel1OffsetState('ON');

            else
                this.apiv.setChannel1OffsetValueToCurrentReading();
                % this.apiv.setChannel1OffsetState('ON');

            end
            
            % Update the state throught the UI as if the user had
            % done it
            this.hiotxOffset1State.setDest('ON');
            this.hiotxOffset1State.moveToDest();
            
        end
        
        function onSetOffset2ToCurrentReadingClick(this, src, evt)
           
            if this.lActive
                this.api.setChannel2OffsetValueToCurrentReading();
                %this.api.setChannel2OffsetState("ON");
            else
                this.apiv.setChannel2OffsetValueToCurrentReading();
                %this.apiv.setChannel2OffsetState("ON");
            end
            
            % Update the state throught the UI as if the user had
            % done it
            this.hiotxOffset2State.setDest('ON');
            this.hiotxOffset2State.moveToDest();
            
        end
        
        
        function onAutoRangeStateChange1(this, src, evt)
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
            this.hioRange1.enable();
        end

        function disableRange(this)
            this.hioRange1.disable();
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
        
        % @return {double 1x1} d - the height of the panel
        function d = getHeight(this)
           
            d = 55;
            
            if this.lShowOffset
                d = d + this.dHeightPanelOffset + this.dHeightPanelPad;
                d = d + this.dHeightPanelOffset + this.dHeightPanelPad;
            end
            
            if this.lShowRange
                d = d + this.dHeightPanelRange + this.dHeightPanelPad;
                d = d + this.dHeightPanelRange + this.dHeightPanelPad;
            end
            
            if this.lShowSettings
                d = d + this.dHeightPanelSettings + this.dHeightPanelPad;
            end
        end
        
        
        
    end
    
end

