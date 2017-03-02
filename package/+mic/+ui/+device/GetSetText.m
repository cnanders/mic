classdef GetSetText < mic.Base
    
    % Hungarian: hiotx

    properties (Constant)
       
    end

    properties      
        u8UnitIndex = 1;
    end

    properties (SetAccess = private)
        cName = 'CHANGE ME' % name identifier
        lActive = false    % boolean to tell whether the motor is active or not
        lReady = false  % true when stopped or at its target
        u8Layout = uint8(1); % {uint8 1x1} to store the layout style
        % lIsThere 

    end

    properties (Access = protected)
        
        dHeight = 24;   % height of the UIElement
        dHeightLabel = 16;
        dHeightBtn = 24;
        dHeightEdit = 24;
        dHeightPopup = 24;
        dHeightText = 16;
        
        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        
        dWidthStatus = 5;
        
        cLabelApi = 'Api'
        cLabelName = 'Name';
        cLabelValue = 'Value';
        cLabelDest = 'Goal'
        cLabelPlay = 'Go'
        cLabelStores = 'Stores';
        cTooltipApiOff = 'Connect to the real Api / hardware';
        cTooltipApiOn = 'Disconnect the real Api / hardware (go into virtual mode)';

        
        
        apiv        % virtual Api (for test and debugging).  Builds its own ApivHardwareIO
        api         % Api to the low level controls.  Must be set after initialized.
        
        clock       % clock 
        cLabel = 'CHANGE ME' % name to be displayed by the UI element
        cDir        % current directory
        cDirSave    
        

        uieDest     % textbox to input the desired position
        uitxVal     % label to display the current value
        uitApi      % toggle for real / virtual Api
        
        
        uibtPlay     % 2014.11.19 - Using a button instead of a toggle
        
        uitxName  % label to displau the name of the element
        
        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
            
        u8Play = imread(fullfile(mic.Utils.pathAssets(), 'axis-play-24-3.png'))
        u8Pause = imread(fullfile(mic.Utils.pathAssets(), 'axis-pause-24-3.png'))
        u8Active = imread(fullfile(mic.Utils.pathAssets(), 'hiot-true-24.png'))
        u8Inactive = imread(fullfile(mic.Utils.pathAssets(), 'hiot-false-24.png'))
        u8ToggleOn = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-true.png'))
        u8ToggleOff = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-false-yellow.png'))
            
        
        config
        dZeroRaw = 0;
        fhValidateDest
        dValRaw % value in raw units (updated by clock)
        
        
        uipStores % UIPopupStruct
        
        lShowName = true;
        lShowVal = true;
        lShowDest = true
        lShowPlay = true
        lShowLabels = true
        lShowStores = true
        lShowApi = true
        lDisableI = false
                
        uitxLabelName
        uitxLabelVal
        uitxLabelDest
        uitxLabelStores
        uitxLabelPlay
        uitxLabelApi
        
        % {char 1xm} storage of the last display value.  Used to emit
        % eChange events
        cValPrev = '...'
    end
    

    events
        
        eUnitChange
        eChange
    end

    
    methods       
        
        % See HardwareIOPlus documentation
        
        function this = GetSetText(varargin)  
                    
            % Default properties
            this.fhValidateDest = this.validateDest;
            this.config = mic.config.GetSetText();
            
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            
            this.cDirSave = fullfile( ...
                this.cDir, ...
                '..', ...
                'save', ...
                'hiotx' ...
            );
                
            
            if this.lDisableI == true
                this.lShowJog = false; 
                this.lShowStores = false; 
                this.lShowPlay = false; 
                this.lShowDest = false; 
            end
            
            this.init();
        end

        

        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareIO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREIO, INIT, DELETE       
            
        
            if ~isempty(this.clock)
                this.clock.add(@this.handleClock, this.id(), this.config.dDelay);
            end
            
            dHeight = this.dHeight;
            if this.lShowLabels
                dHeight = dHeight + this.dHeightLabel;
            end

            dWidth = this.getWidth();

            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent));
            drawnow

            axis('image');
            axis('off');

            dTop = -1;
            dTopLabel = -1;
            if this.lShowLabels
                dTop = this.dHeightLabel;
            end

            dLeft = 0;

            % Api toggle
            if (this.lShowApi)
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                dLeft = dLeft + this.dWidthBtn + 5; 
            end


            % Name
            if this.lShowName
                if this.lShowLabels
                    this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeightLabel);
                end
                this.uitxName.build(this.hPanel, dLeft,  dTop + (this.dHeight - this.dHeightText)/2, this.dWidthName, this.dHeightText);
                dLeft = dLeft + this.dWidthName;
            end

            % Val
            if this.lShowVal
                if this.lShowLabels
                    this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthVal, this.dHeightLabel);
                end
                this.uitxVal.build(this.hPanel, dLeft,  dTop + (this.dHeight - this.dHeightText)/2, this.dWidthVal, this.dHeightText);
                dLeft = dLeft + this.dWidthVal + 5;
            end

            % Dest
            if this.lShowDest
                if this.lShowLabels
                    this.uitxLabelDest.build(this.hPanel, dLeft, dTopLabel, this.dWidthDest, this.dHeightLabel);
                end
                this.uieDest.build(this.hPanel, dLeft, dTop, this.dWidthDest, this.dHeightEdit);
                dLeft = dLeft + this.dWidthDest;
            end


            % Play
            if this.lShowPlay
                if this.lShowLabels
                    this.uitxLabelPlay.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibtPlay.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

            end 

            % Stores
            if this.lShowStores && ...
               ~isempty(this.config.ceStores)
                           
                if this.lShowLabels
                    this.uitxLabelStores.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeightLabel);
                end
                
               
                
                this.uipStores.build(this.hPanel, dLeft, dTop, this.dWidthStores, this.dHeightPopup);
                dLeft = dLeft + this.dWidthStores;
            end

        end
      
        
        function moveToDest(this)
        %MOVETODEST Performs the HIO motion to the destination shown in the
        %GUI display.  It converts from the display units to raw and tells
        %the Api 
        %   HardwareIO.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW, MOVE
        
            this.msg(sprintf('moveToDest %s', this.uieDest.val()));
            
            if this.fhValidateDest() ~= true                
                this.msg('moveToDest returning');
                return;
                
            end
            
            this.getApi().set(this.uieDest.val());
                       
        end
        
        
        
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the Api to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            this.uitApi.lVal = true;
            this.uitApi.setTooltip(this.cTooltipApiOn);

                        
            % Update destination values to match device values
            this.setDest(this.getApi().get());
            
            % Kill the Apiv
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.setApiv([]); % This is calling the setter
            end
            
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
           
        end
        
        function setApi(this, api)
            this.api = api;
        end
        
        function setApiv(this, api)
            
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
            end

            this.apiv = api;
            
        end
        
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

            this.msg('delete', 5);
            this.save();
            
           % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task'); 
                this.clock.remove(this.id());
            end
            
            % The Apiv instances have clock tasks so need to delete them
            % first
            
            delete(this.apiv);
            
            if ~isempty(this.api) && ... % isvalid(this.api) && ...
                isa(this.api, 'ApivGetSetText')
                delete(this.api)
            end
            
            delete(this.uieDest);  
            delete(this.uitxVal);
            delete(this.uitApi);
            delete(this.uibtPlay);
            delete(this.uitxName);
            delete(this.uipStores);
            
            delete(this.uitxLabelName);
            delete(this.uitxLabelVal);
            delete(this.uitxLabelDest);
            delete(this.uitxLabelStores);
            delete(this.uitxLabelPlay);
            delete(this.uitxLabelApi);
                      
            delete(this.config)

                        
        end
        
        function handleClock(this) 
        %HANDLECLOCK Callback triggered by the clock
        %   HardwareIO.HandleClock()
        %   updates the position reading and the hio status (=/~moving)
        
            cVal = this.getApi().get();
            if ~strcmp(this.cValPrev, cVal)
                notify(this, 'eChange');
            end
            this.uitxVal.cVal = cVal;
            
        end 
        
        function c = val(this)
            c = this.getApi().get();
        end
        
        function c = dest(this)
            c = this.uieDest.val();
        end
        
        function setDest(this, cVal)
            this.uieDest.setVal(cVal);
        end
        
        
        function enable(this)
            this.uieDest.enable();
            this.uitxVal.enable();
            this.uitApi.enable();
            this.uibtPlay.enable();
            this.uitxName.enable();
            this.uipStores.enable();
            
            this.uitxLabelName.enable();
            this.uitxLabelVal.enable();
            this.uitxLabelDest.enable();
            this.uitxLabelPlay.enable();
            this.uitxLabelApi.enable();
            this.uitxLabelStores.enable();
        end
        
        
        
        function disable(this)
            this.uieDest.disable();
            this.uitxVal.disable();
            this.uitApi.disable();
            this.uibtPlay.disable();
            this.uitxName.disable();
            this.uipStores.disable();
            
            this.uitxLabelName.disable();
            this.uitxLabelVal.disable();
            this.uitxLabelDest.disable();
            this.uitxLabelPlay.disable();
            this.uitxLabelApi.disable();
            this.uitxLabelStores.disable();
        end
        
       
        

    end %methods
    
    methods (Access = protected)
            

        function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
        
        
            % Load in the config file (Need to figure out how this will
            % work with classes that extend this class
                                   
            %activity ribbon on the right
            
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

            this.uitApi = mic.ui.common.Toggle( ...
                'lImg', true, ...
                'u8ImgOn', this.u8ToggleOn, ...
                'u8ImgOff',  this.u8ToggleOff, ...
                'stF2TOptions', st1, ...
                'stT2FOptions', st2 ...
            );
                        
            
            %GoTo button
            this.uibtPlay = mic.ui.common.ButtonToggle( ...
                'lImg', true, ...
                'u8ImgT', this.u8Play, ...
                'u8ImgF', this.u8Pause ...
            );
        
            
            % Dest
            this.uieDest = mic.ui.common.Edit('lShowLabel', false);
            
            % Value
            this.uitxVal = mic.ui.common.Text('cVal', '...');

            % Name (on the left)
            this.uitxName = mic.ui.common.Text('cVal', this.cLabel);

            this.setApiv(this.newApiv());
            
            % if ~isempty(this.config.ceStores)
                this.uipStores = mic.ui.common.PopupStruct(...
                    'ceOptions', this.config.ceStores, ...
                    'lShowLabel', false, ...
                    'cField', 'name' ...
                );
                
                addlistener(this.uipStores,   'eChange', @this.onStoresChange);
                this.uipStores.setTooltip('Go to a stored position');                
            % end
                        
            addlistener(this.uieDest,   'eChange', @this.onDestChange);
            %AW(5/24/13) : populating the destination
            this.uieDest.setVal(this.apiv.get());
            
            addlistener(this.uitApi,   'eChange', @this.onApiChange);
            addlistener(this.uibtPlay,   'eChange', @this.onPlayChange);

                
            
            this.uitxLabelName = mic.ui.common.Text('cVal', this.cLabelName);
            this.uitxLabelVal = mic.ui.common.Text('cVal', this.cLabelValue);
            this.uitxLabelDest = mic.ui.common.Text('cVal', this.cLabelDest);
            this.uitxLabelPlay = mic.ui.common.Text('cVal', this.cLabelPlay);
            this.uitxLabelApi = mic.ui.common.Text(...
                'cVal', this.cLabelApi, ...
                'cAlign', 'center' ...
            );
            this.uitxLabelStores = mic.ui.common.Text('cVal', this.cLabelStores);
            
            this.uitApi.setTooltip(this.cTooltipApiOff);
            this.uitxName.setTooltip('The name of this device');
            this.uitxVal.setTooltip('The value of this device');
            this.uieDest.setTooltip('Change the goal value');
            this.uibtPlay.setTooltip('Go to goal');
            
            this.load();
            
            
        end
        
        function onApiChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        function onStoresChange(this, src, evt)
            this.setDest(this.uipStores().val().val);
            this.moveToDest();
        end
        
        function onDestChange(this, src, evt)
            % notify(this, 'eChange');
        end
                
        function onPlayChange(this, src, evt)
            this.moveToDest();
        end
        
        
        
        % Deprecated (un-deprecitate if you want to move to dest on enter
        % keypress
        
        function handleDest(this, src, evt)
            if uint8(get(this.hParent,'CurrentCharacter')) == 13
                this.moveToDest();
            end
        end
        
       

        function updatePlayButton(this)
            
            % UIButtonTobble
            if this.lReady && ~this.uibtPlay.lVal
                this.uibtPlay.lVal = true;
            end

            if ~this.lReady && this.uibtPlay.lVal
                this.uibtPlay.lVal = false;
            end
            

        end
        
                
        function load(this)
            
            this.msg('load()', 7);

            if exist(this.file(), 'file') == 2
                load(this.file()); % populates variable s in local workspace
                this.loadClassInstance(s); 
            end
            
            
        end
        
        function save(this)
            
            this.msg('save()', 7);
            
            % Create a nested recursive structure of all public properties
            % s = this.saveClassInstance();
            
            % Only want to save u8UnitIndex
            
            s = struct();
            s.u8UnitIndex = this.u8UnitIndex;
                                    
            % Save
            
            save(this.file(), 's');
                        
        end
        
        function cReturn = file(this)
            
            this.checkDir(this.cDirSave);
            cReturn = fullfile(...
                this.cDirSave, ...
                [this.cName, '.mat']...
            );
            
        end
        
        
        
        function lOut = validateDest(this)
            lOut = true;
        end
        
       
        
        function api = getApi(this)
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end 
            
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowApi
               dOut = dOut + this.dWidthBtn;
            end

            % Always show name
            if this.lShowName
                dOut = dOut + this.dWidthName;
            end
            
            % Always show val
            if this.lShowVal
                dOut = dOut + this.dWidthVal + 5;
            end
            
            if this.lShowDest
                dOut = dOut + this.dWidthDest;
            end
            if this.lShowPlay
                dOut = dOut + this.dWidthBtn;
            end
            
            if this.lShowStores && ~isempty(this.config.ceStores)
                dOut = dOut + this.dWidthStores;
            end
            
            dOut = dOut + 5;
            
            
        end
        
        function api = newApiv(this)
            api = mic.device.GetSetText();
        end
        
    end

end %class
