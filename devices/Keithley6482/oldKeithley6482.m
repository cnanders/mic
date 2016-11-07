classdef oldKeithley6482 < HandlePlus
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    
        
    %{
    this.stAveragingFilter.labels = { ...
        'Off', ...
        'Repeat', ...
        'Moving' ...
    };
    this.stAveragingFilter.values = { ...
        'REPEAT', ... % doesn't matter
        'REPEAT', ...
        'MOVING' ...
    };
    this.stAveragingFilter.states = {
        'OFF', ...
        'ON', ...
        'ON' ...
    };
            
    this.stAutoRange.labels = { ...
        'Off', ...
        'On' ...
    };

    this.stAutoRange.states = {...
        'OFF', ...
        'ON' ...
    }
            
    this.stMedianFilter.labels = {...
        'Off', ...
        '3', ...
        '5', ...
        '7', ...
        '9', ...
        '11 (Max)' ...
    };
    this.stMedianFilter.ranks = { ...
        0, ...
        1, ...
        2, ...
        3, ...
        4, ...
        5 ...
    };
    this.stMedianFilter.states = { ...
        'OFF', ...
        'ON', ...
        'ON', ...
        'ON', ...
        'ON', ...
        'ON' ...
    };
    
    this.stRange.labels = { ...
        '2 nA', ...
        '20 nA', ...
        '200 nA', ...
        '2 uA', ...
        '20 uA', ...
        '200 uA', ...
        '2 mA', ...
        '20 mA' ...
    };
    this.stRange.values = {
        2e-9, ...
        20e-9, ...
        200e-9, ...
        2e-6, ...
        20e-6, ...
        200e-6, ...
        2e-3, ...
        20e-3 ...
    };
        
        
    this.stSpeed.labels = { ...
        'Fast', ...
        'Med', ...
        'Normal', ...
        'Hi Accuracy' ...
    };
    this.stSpeed.values = {...
        0.01, ...
        0.1, ...
        1, ...
        10 ...
    };
            
    
    %}
    
    properties (Constant)

        dHeight = 110;   % height of the UIElement
        dWidth = 500;   % width of the UIElement
        dWidthUnits = 80;
        dWidthBtn = 24;
        dWidthEdit = 70;
        
        dPad2 = 0;
        dWidthStatus = 5;
        
        dWidthMedianFilter = 70;
        dWidthAveragingFilter = 90;
        dWidthAveragingFilterSize = 50;
        
        dWidthName = 80;
        dWidthSpeed = 130;
        dWidthSpeedText = 100;
        
        dWidthChannel = 30;
        dWidthRange = 80;
        dWidthAutoRange = 65;
        dWidthVal = 80;
        
        dHeightUI = 24; 
        dHeightText = 12;
        
        cTooltipAPIOff = 'Connect to the real API / hardware';
        cTooltipAPIOn = 'Disconnect the real API / hardware (go into virtual mode)';

        
    end
            
    properties
        
        
    end
    
    properties (SetAccess = private)
        
        
        api
        cName
        cLabel
        lActive = false
        
        % Global
        uitxName
        uipSpeed
        uitxSpeed

        % Ch 1
        uipRange1
        uipAutoRange1
        uipAveragingFilter1
        uipMedianFilter1
        uitxVal1
        uieAveragingFilterSize1
        
        % Ch 2
        uipRange2
        uipAutoRange2
        uipAveragingFilter2
        uipMedianFilter2
        uitxVal2
        uieAveragingFilterSize2
        
        
        % Labels
        uitxLabelName
        uitxLabelAPI
        uitxLabelChannel
        uitxLabelVal
        uitxLabel1
        uitxLabel2
        
        % Graphics
        u8Active
        u8Inactive
        
        lShowLabels = true;
        lShowAPI
        
    end
    
    properties (Access = protected)
        clock
        
        
        uitAPI      % toggle for real / virtual API
        apiv
        
        cDir
        cDirSave
        hPanel
        
        ceRanges;
        ceAutoRanges;
        ceSpeeds;
        ceAveragingFilters
        ceMedianFilters
        
        
        dVal1 % 1x1 storage of ch 1 amps
        dVal2 % 1x1 storage of ch 2 amps
        
    end
    
    
    events
        
    end
    
            
    methods
        
        function this = oldKeithley6482(stParams)
        %Keithley6482 constructor
        %@param {struct 1x1} stParams - configuration params 
        %@param {char 1xm} stParams.cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        %@param {clock 1x1} stParams.clock - the clock
        %@param {char 1x1} [stParams.cLabel = stParams.cName] - the label in the GUI
        %@param {logical 1x1} [stParams.lShowAPI = true] - show the
        %   clickable toggle / status that shows if is using real API or
        %   virtual API

        
            stDefault = struct();
            stDefault.lShowAPI = true;
            stParams = mergestruct(stDefault, stParams);
            
            % Special case set cLabel === cName if not set
            if ~isfield(stParams, 'cLabel')
                stParams.cLabel = stParams.cName;
            end
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1 : end-length(cFile));
            
            this.cDirSave = fullfile( ...
                this.cDir, ...
                '..', ...
                'save', ...
                'keithley' ...
            );

            % Assign params to properties
            ceNames = fieldnames(stParams);
            for k = 1:length(ceNames)
                this.(ceNames{k}) = stParams.(ceNames{k});
            end
            
            % this.assignPropsFromStruct(stParams);
            
            
            this.init();
            
        end
        
        function setApi(this, api)
            this.api = api;
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
                'BorderWidth',0, ... 
                'Position', Utils.lt2lb([dLeft dTop this.getWidth() this.dHeight], hParent));
            drawnow
            
            
            dTop = 0;
            dTopLabel = 0
            dTop = 12;
            dWidthLabel = 80;
            
            
            % Global
            
            dLeft = 0;
            % API toggle
            if this.lShowAPI
                disp('fdjsakldfs');
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelAPI.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightText);
                end
                this.uitAPI.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dWidthBtn);
                dLeft = dLeft + this.dWidthBtn + 5; 
            end
            
            % Name
            if this.lShowLabels
                this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeightText);
            end
            this.uitxName.build(this.hPanel, dLeft, dTop + 6, this.dWidthName, this.dHeightText);
            dLeft = dLeft + this.dWidthName;
            
            % Speed Pulldown
            this.uipSpeed.build(this.hPanel, dLeft, dTopLabel, this.dWidthSpeed, this.dHeightUI);  
            dLeft = dLeft + this.dWidthSpeed;
            
            % Speed Text
            this.uitxSpeed.build(this.hPanel, dLeft, 18, this.dWidthSpeedText, this.dHeightText);
           
            
            % Ch 1
            
            dOffsetLabel = 20;
            dTop = 40;
            
            
            
            dLeft = 0;
            this.uitxLabelChannel.build(this.hPanel, dLeft, dTop, this.dWidthChannel, this.dHeightText);
            this.uitxLabel1.build(this.hPanel, dLeft, dTop + dOffsetLabel, this.dWidthChannel, this.dHeightText);
            dLeft = dLeft + this.dWidthChannel;
            
            this.uitxLabelVal.build(this.hPanel, dLeft, dTop, this.dWidthVal, this.dHeightText);
            this.uitxVal1.build(this.hPanel, dLeft, dTop + dOffsetLabel, this.dWidthVal, this.dHeightText);
            dLeft = dLeft + this.dWidthVal;
            
            
            this.uipRange1.build(this.hPanel, dLeft, dTop, this.dWidthRange, this.dHeightUI);
            dLeft = dLeft + this.dWidthRange;
            
            
            this.uipAutoRange1.build(this.hPanel, dLeft, dTop, this.dWidthAutoRange, this.dHeightUI);
            dLeft = dLeft + this.dWidthAutoRange;
            
            this.uipAveragingFilter1.build(this.hPanel, dLeft, dTop, this.dWidthAveragingFilter, this.dHeightUI);
            dLeft = dLeft + this.dWidthAveragingFilter;
            
            
            this.uieAveragingFilterSize1.build(this.hPanel, dLeft, dTop, this.dWidthAveragingFilterSize, this.dHeightUI);
            dLeft = dLeft + this.dWidthAveragingFilterSize;
            
            
            this.uipMedianFilter1.build(this.hPanel, dLeft, dTop, this.dWidthMedianFilter, this.dHeightUI);
            dLeft = dLeft + this.dWidthMedianFilter;
            
            
            % Ch 2
            dTop = 80;
            dOffsetLabel = 5;
            
            dLeft = 0;
            
            this.uitxLabel2.build(this.hPanel, dLeft, dTop + dOffsetLabel, this.dWidthChannel, this.dHeightText);
            dLeft = dLeft + this.dWidthChannel;
            
            this.uitxVal2.build(this.hPanel, dLeft, dTop + dOffsetLabel, this.dWidthVal, this.dHeightText);
            dLeft = dLeft + this.dWidthVal;
            
            this.uipRange2.build(this.hPanel, dLeft, dTop, this.dWidthRange, this.dHeightUI);            
            dLeft = dLeft + this.dWidthRange;
           
            this.uipAutoRange2.build(this.hPanel, dLeft, dTop, this.dWidthAutoRange, this.dHeightUI);
            dLeft = dLeft + this.dWidthAutoRange;
            
            this.uipAveragingFilter2.build(this.hPanel, dLeft, dTop, this.dWidthAveragingFilter, this.dHeightUI);
            dLeft = dLeft + this.dWidthAveragingFilter;
            
            this.uieAveragingFilterSize2.build(this.hPanel, dLeft, dTop, this.dWidthAveragingFilterSize, this.dHeightUI);
            dLeft = dLeft + this.dWidthAveragingFilterSize;
            
            this.uipMedianFilter2.build(this.hPanel, dLeft, dTop, this.dWidthMedianFilter, this.dHeightUI);
            
            
            
            
            
            
            
            
            
            
            
            % Set UIPopups to their current values to fire
            % off the listener sequence 
            
            this.uipAveragingFilter1.u8Selected = this.uipAveragingFilter1.u8Selected;
            this.uipAveragingFilter2.u8Selected = this.uipAveragingFilter2.u8Selected;
            this.uipSpeed.u8Selected = this.uipSpeed.u8Selected;
            
        end
        
        function delete(this)
            
            
            this.msg('delete', 5);
            this.save();
            
           % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                
                this.msg('delete() removing clock task'); 
                this.clock.remove(this.id());
            end 
            
            % APIV instances have clock tasks; important to delete them
            % first
            
            delete(this.apiv);
            
            if ~isempty(this.api) && ...
                isvalid(this.api) && ...
                isa(this.api, 'APIVKeithley6482')
                delete(this.api)
            end  
            
            % Global
            delete(this.uitxName);
            delete(this.uipSpeed);
            delete(this.uitxSpeed);

            % Ch 1
            delete(this.uipRange1);
            delete(this.uipAutoRange1);
            delete(this.uipAveragingFilter1);
            delete(this.uipMedianFilter1);
            delete(this.uitxVal1);
            delete(this.uieAveragingFilterSize1);

            % Ch 2
            delete(this.uipRange2);
            delete(this.uipAutoRange2);
            delete(this.uipAveragingFilter2);
            delete(this.uipMedianFilter2);
            delete(this.uitxVal2);
            delete(this.uieAveragingFilterSize2);

            % Labels
            delete(this.uitxLabelName);
            delete(this.uitxLabelAPI);
            delete(this.uitxLabelChannel);
            delete(this.uitxLabelVal);
            delete(this.uitxLabel1);
            delete(this.uitxLabel2);
            
            delete(this.uitAPI);     
           
                        
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
        
        % Get the amp value of a channel
        % @param {uint8 1x1} u8Ch - the channel (1 or 2)

        function dOut = val(this, u8Ch)
            
            if u8Ch == uint8(1)
                dOut = this.dVal1;
            else
                dOut = this.dVal2;
            end
                            
        end
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitAPI.lVal = true;
            this.uitAPI.setTooltip(this.cTooltipAPIOn);
                     
            
            % Kill the APIV
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.apiv = []; % This is calling the setter
            end
            
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
            
        end

        
    end
    
    
    
    
    
    
    methods (Access = protected)
        
        function init(this)
           
            this.apiv = this.newAPIV();
            
            
            
            
            this.u8Active = imread(fullfile(...
                this.cDir, ...
                '..', ...
                '..', ...
                'assets', ...
                'hiot-true-24.png'...
            ));
        
            this.u8Inactive = imread(fullfile(...
                this.cDir, ...
                '..', ...
                '..', ...
                'assets', ...
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
        
            
            % Since I need to pass cell arrays of char into the pulldowns,
            % it makes sense to do:
            %
            % .labels = {'a', 'b', 'c'}
            % .values = {1, 2, 3}
            %
            % This is a structure where fields of the stucture are cell
            % arrays
            %
            % instead of:
            % [
            %   {
            %       'label': 'a',
            %       'value': 1
            %   },
            %   {
            %       'label: 'b',
            %       'value': 2
            %   },
            %   {
            %       'label': 'c',
            %       'value': 3
            %   }
            % ]
            %
            % (JSON) even though I heavily perfer thinking about a list of states
            % as shown above.  In matlab, the above would have to be an
            % array (or cell array) of structures. It would also be
            % possible to create a pulldown that takes a list of structures
            % and the field of the structure to use for the display.  In
            % fact, this is what I decided to do. 
                        
            % ----- Ranges
            
            this.ceRanges = cell(1, 8);
            this.ceRanges{1}.cLabel = '2 nA';
            this.ceRanges{1}.dVal = 2e-9;
            
            this.ceRanges{2}.cLabel = '20 nA';
            this.ceRanges{2}.dVal = 20e-9;
            
            this.ceRanges{3}.cLabel = '200 nA';
            this.ceRanges{3}.dVal = 200e-9;
            
            this.ceRanges{4}.cLabel = '2 uA';
            this.ceRanges{4}.dVal = 2e-6;
            
            this.ceRanges{5}.cLabel = '20 uA';
            this.ceRanges{5}.dVal = 20e-6;
            
            this.ceRanges{6}.cLabel = '200 uA';
            this.ceRanges{6}.dVal = 200e-6;
            
            this.ceRanges{7}.cLabel = '2 mA';
            this.ceRanges{7}.dVal = 2e-3;
            
            this.ceRanges{8}.cLabel = '20 mA';
            this.ceRanges{8}.dVal = 20e-3;

            % ----- Auto Ranges
        
            this.ceAutoRanges = cell(1, 2);
            this.ceAutoRanges{1}.cLabel = 'Off';
            this.ceAutoRanges{1}.cState = 'OFF';
            
            this.ceAutoRanges{2}.cLabel = 'On';
            this.ceAutoRanges{2}.cState = 'ON';
                 
            % ----- Speeds
            
            this.ceSpeeds = cell(1, 4);
            this.ceSpeeds{1}.cLabel = 'Fast (0.01 PLC)';
            this.ceSpeeds{1}.dVal = 0.01;
            
            this.ceSpeeds{2}.cLabel = 'Medium (0.1 PLC)';
            this.ceSpeeds{2}.dVal = 0.1;
            
            this.ceSpeeds{3}.cLabel = 'Normal (1 PLC)';
            this.ceSpeeds{3}.dVal = 1;
            
            this.ceSpeeds{4}.cLabel = 'Hi Accuracy (10 PLC)';
            this.ceSpeeds{4}.dVal = 10;
                    
            % ----- Averaging Filters
            
            this.ceAveragingFilters = cell(1, 3);
            this.ceAveragingFilters{1}.cLabel = 'Off';
            this.ceAveragingFilters{1}.cMode = 'REPEAT'; % Doesn't matter
            this.ceAveragingFilters{1}.cState = 'OFF';
            
            this.ceAveragingFilters{2}.cLabel = 'Repeat';
            this.ceAveragingFilters{2}.cMode = 'REPEAT'; % Doesn't matter
            this.ceAveragingFilters{2}.cState = 'ON';
            
            this.ceAveragingFilters{3}.cLabel = 'Moving';
            this.ceAveragingFilters{3}.cMode = 'MOVING'; % Doesn't matter
            this.ceAveragingFilters{3}.cState = 'ON';
         
            % ----- Median Filters
            
            this.ceMedianFilters = cell(1, 6);
            this.ceMedianFilters{1}.cLabel = 'Off';
            this.ceMedianFilters{1}.u8Rank = uint8(0);
            this.ceMedianFilters{1}.cState = 'OFF';
            
            this.ceMedianFilters{2}.cLabel = '3';
            this.ceMedianFilters{2}.u8Rank = uint8(1);
            this.ceMedianFilters{2}.cState = 'ON';
            
            this.ceMedianFilters{3}.cLabel = '5';
            this.ceMedianFilters{3}.u8Rank = uint8(2);
            this.ceMedianFilters{3}.cState = 'ON';
            
            this.ceMedianFilters{4}.cLabel = '7';
            this.ceMedianFilters{4}.u8Rank = uint8(3);
            this.ceMedianFilters{4}.cState = 'ON';
            
            this.ceMedianFilters{5}.cLabel = '9';
            this.ceMedianFilters{5}.u8Rank = uint8(4);
            this.ceMedianFilters{5}.cState = 'ON';
            
            this.ceMedianFilters{6}.cLabel = '11';
            this.ceMedianFilters{6}.u8Rank = uint8(5);
            this.ceMedianFilters{6}.cState = 'ON';
            
            % Build config structures for the UIPopupStruct objects.
            % Important to initialize them like this and not the using
            % struct(field1,val1, ...) constructor due to a weird way that it handles
            % values that are cell arrays.
            
            
            
            
            
            stParamsSpeed = struct();
            stParamsSpeed.ceOptions = this.ceSpeeds;
            stParamsSpeed.cLabel = 'ADC Integration Speed';
           
            
            
            
               
            % ----- Global
            
            this.uipSpeed = UIPopupStruct(...
                'ceOptions', this.ceSpeeds, ...
                'cLabel', 'ADC Integration Label', ...
                'lShowLabel', true ...
            );
            this.uitxSpeed = UIText('---', 'left');

            

            % ----- Ch 1                        
            this.uipRange1 = UIPopupStruct(...
                'ceOptions', this.ceRanges, ...
                'cLabel', 'Range', ...
                'lShowLabel', true ...
            );
           
            this.uipAutoRange1 = UIPopupStruct(...
                'ceOptions', this.ceAutoRanges, ...
                'cLabel', 'AutoRange', ...
                'lShowLabel', true ...
            );

            
            this.uipAveragingFilter1 = UIPopupStruct(...
                'ceOptions', this.ceAveragingFilters, ...
                'cLabel', 'Averaging Filter', ...
                'lShowLabel', true ...
            );
        
            this.uieAveragingFilterSize1 = UIEdit(...
                'Avg. #', ... % label
                'u8', ... % type
                true ... % show label
            );
        
            
            this.uipMedianFilter1 = UIPopupStruct(...
                'ceOptions', this.ceMedianFilters, ...
                'cLabel', 'Median Filter', ...
                'lShowLabel', true ...
            );
                
            this.uieAveragingFilterSize1.setTooltip('The size of the averaging window [1 - 100]');
            this.uieAveragingFilterSize1.setVal(uint8(1));
            this.uieAveragingFilterSize1.setMin(uint8(1));
            this.uieAveragingFilterSize1.setMax(uint8(100));
            this.uieAveragingFilterSize1.disable();
            
           
        
        
            % ----- Ch 2
            
            % Hide the labels
            stParamsRange.lShowLabel = false;
            stParamsAutoRange.lShowLabel = false;
            stParamsSpeed.lShowLabel = false;
            stParamsAveragingFilter.lShowLabel = false;
            stParamsMedianFilter.lShowLabel = false;

           
            
            this.uipRange2 = UIPopupStruct(...
                'ceOptions', this.ceRanges ...
            );
           
            this.uipAutoRange2 = UIPopupStruct(...
                'ceOptions', this.ceAutoRanges ...
            );

            this.uipAveragingFilter2 = UIPopupStruct(...
                'ceOptions', this.ceAveragingFilters ...
            );
                
        
            this.uieAveragingFilterSize2 = UIEdit(...
                'Avg. #', ... % label
                'u8', ... % type
                false ... % show label
            );            
        
            this.uipMedianFilter2 = UIPopupStruct(...
                'ceOptions', this.ceMedianFilters ...
            );
        
            
                        
        
            this.uieAveragingFilterSize2.setVal(uint8(1));
            this.uieAveragingFilterSize2.setMin(uint8(1));
            this.uieAveragingFilterSize2.setMax(uint8(100));
            this.uieAveragingFilterSize2.disable();
            
            this.uitxLabelAPI = UIText('API', 'center');
            this.uitxName = UIText(this.cLabel, 'left');
            this.uitxLabelChannel = UIText('Ch', 'left');
            this.uitxLabelName = UIText('Name');
            this.uitxLabelVal = UIText('Value', 'left');
            this.uitxLabel1 = UIText('1');
            this.uitxLabel2 = UIText('2');
            
            this.uitxVal1 = UIText('---', 'left');
            this.uitxVal2 = UIText('---', 'left');
            
                        
            % Tooltips
            
            this.uieAveragingFilterSize1.setTooltip('The size of the Ch 1 averaging window [1 - 100]');
            this.uieAveragingFilterSize2.setTooltip('The size of the Ch 2 averaging window [1 - 100]');

        
            % this.u8Bg = imread(fullfile(this.cDir, '..', 'assets', 'hio-bg-24x5-red.png'));
        
            addlistener(this.uipSpeed, 'eChange', @this.onSpeedChange);
            
            addlistener(this.uipRange1, 'eChange', @this.onRange1Change);
            addlistener(this.uipAutoRange1, 'eChange', @this.onAutoRange1Change);
            addlistener(this.uipAveragingFilter1, 'eChange', @this.onAveragingFilter1Change);
            addlistener(this.uieAveragingFilterSize1, 'eChange', @this.onAveragingFilterSize1Change);
            addlistener(this.uipMedianFilter1, 'eChange', @this.onMedianFilter1Change);
            
            addlistener(this.uipRange2, 'eChange', @this.onRange2Change);
            addlistener(this.uipAutoRange2, 'eChange', @this.onAutoRange2Change);
            addlistener(this.uipAveragingFilter2, 'eChange', @this.onAveragingFilter2Change);
            addlistener(this.uieAveragingFilterSize2, 'eChange', @this.onAveragingFilterSize2Change);
            addlistener(this.uipMedianFilter2, 'eChange', @this.onMedianFilter2Change);
            addlistener(this.uitAPI,   'eChange', @this.onAPIChange);
            
            this.clock.add(@this.onClock, this.id(), 0.1);
            
            
        end
        
        function onAPIChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        function onClock(this, src, evt)
            
            this.dVal1 = this.getAPI().get(uint8(1));
            this.dVal2 = this.getAPI().get(uint8(2));
            this.uitxVal1.cVal = sprintf('%1.3f', this.dVal1);
            this.uitxVal2.cVal = sprintf('%1.3f', this.dVal2);
            
        end
        
        function onSpeedChange(this, src, evt)
            this.msg(sprintf('onSpeedChange(): %s', src.val().cLabel));
            this.getAPI().setSpeed(src.val().dVal);
            this.uitxSpeed.cVal = sprintf('%1.3f ms', src.val().dVal * 1/60 * 1000);
        end
        
        % ----- Ch 1 event handlers
        
        function onRange1Change(this, src, evt)
            this.msg(sprintf('onRange1Change(): %s', src.val().cLabel));
            this.getAPI().setRange(uint8(1), src.val().dVal);
        end
        
        function onAutoRange1Change(this, src, evt)
            this.msg(sprintf('onAutoRange1Change(): %s', this.uipAutoRange1.val().cLabel));
            this.getAPI().setAutoRangeState(uint8(1), src.val().cState);
            
            switch src.val.cLabel
                case 'On'
                    this.uipRange1.disable();
                otherwise
                    this.uipRange1.enable();
            end
        end
                
        function onAveragingFilter1Change(this, src, evt)
            this.msg(sprintf('onAveragingFilter1Change(): %s', src.val().cLabel));
            
            switch src.val().cLabel
                case 'Off'
                    % Disable avg size
                    % this.uieAveragingFilterSize1.setVal(uint8(1));
                    this.uieAveragingFilterSize1.disable();
                otherwise
                    % Enable avg size
                    this.uieAveragingFilterSize1.enable();
            end
            
            this.getAPI().setAverageCount(uint8(1), this.uieAveragingFilterSize1.val());
            this.getAPI().setAverageMode(uint8(1), src.val().cMode);
            this.getAPI().setAverageState(uint8(1), src.val().cState);
        end
        
        function onAveragingFilterSize1Change(this, src, evt)
            this.msg(sprintf('onAveragingFilterSize1Change(): %s', src.val()));
            this.getAPI().setAverageCount(uint8(1), src.val());

        end
        
        function onMedianFilter1Change(this, src, evt)
            this.msg(sprintf('onMedianFilter1Change(): %s', src.val().cLabel));
            this.getAPI().setMedianRank(uint8(2), src.val().u8Rank);
            this.getAPI().setMedianState(uint8(2), src.val().cState);
        end
        
        % ----- Channel 2 event handlers
        
                
        function onRange2Change(this, src, evt)
            this.msg(sprintf('onRange2Change(): %s', src.val().cLabel));
            this.getAPI().setRange(uint8(2), src.val().dVal);
        end
        
        function onAutoRange2Change(this, src, evt)
            this.msg(sprintf('onAutoRange2Change(): %s', src.val().cLabel));
            this.getAPI().setAutoRangeState(uint8(2), src.val().cState);
            switch src.val.cLabel
                case 'On'
                    this.uipRange2.disable();
                otherwise
                    this.uipRange2.enable();
            end
        end
        
        function onSpeed2Change(this, src, evt)
            this.msg(sprintf('onSpeed2Change(): %s', this.uipSpeed2.val().cLabel));
            this.getAPI().setSpeed(src.val().dVal);
        end
        
        function onAveragingFilter2Change(this, src, evt)
            this.msg(sprintf('onAveragingFilter2Change(): %s', src.val().cLabel));
            
            switch src.val().cLabel
                case 'Off'
                    % Disable avg size
                    % this.uieAveragingFilterSize2.setVal(uint8(1));
                    this.uieAveragingFilterSize2.disable();
                otherwise
                    % Enable avg size
                    this.uieAveragingFilterSize2.enable();
            end
            
            this.getAPI().setAverageCount(uint8(2), this.uieAveragingFilterSize2.val());
            this.getAPI().setAverageMode(uint8(2), src.val().cMode);
            this.getAPI().setAverageState(uint8(2), src.val().cState);
            
        end
        
        function onAveragingFilterSize2Change(this, src, evt)
            this.msg(sprintf('onAveragingFilterSize1Change(): %s', src.val()));
            this.getAPI().setAverageCount(uint8(2), src.val());
        
        end
        
        
        function onMedianFilter2Change(this, src, evt)
            this.msg(sprintf('onMedianFilter2Change(): %s', this.uipMedianFilter2.val().cLabel));
            
            this.getAPI().setMedianRank(uint8(2), src.val().u8Rank);
            this.getAPI().setMedianState(uint8(2), src.val().cState);
            
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
            api = APIVKeithley6482(this.cName, this.clock);
        end
        
        
        function d = getWidth(this)
        
            d = this.dWidthChannel + ...
                this.dWidthVal + ...
                this.dWidthRange + ...
                this.dWidthAutoRange + ...
                this.dWidthAveragingFilter + ...
                this.dWidthAveragingFilterSize + ...
                this.dWidthMedianFilter;
            
           
            
            
        end
        

    end
    
end

