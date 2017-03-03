classdef HardwareIOPlus < HandlePlus
    
%HARDWAREIO Class that creates the controls to a specific piece of hardware
% Contrary to Axis Class, this class is meant to have direct access to the
% hardware (whatever it is : motor, galvo, etc)
%
%   hio = HardwareIO('name', clock)creates an instance with a name 'name'
%   hio = HardwareIO('name', clock, 'display name') will do the same, except
%       that the displayed name will not be default 'name'
%
% See also HARDWAREO, AXIS
    
    % Hungarian: hio

    properties (Constant)
                
    end

    properties      
        % {uint8 1x1} storage of the index of uipUnit
        u8UnitIndex = 1;
        % {double 1x1 zero offset in raw units when in relative mode}
        dZeroRaw = 0;
        % {logical 1x1 value of uitRel}
        lRelVal = false;
    end

    properties (SetAccess = private)
        
        % @param {char 1xm} cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        cName = 'CHANGE ME' % name identifier
        lActive = false   % boolean to tell whether the motor is active or not
        lReady = false  % true when stopped or at its target
        
        % {logical 1x1} store if delete() has been called.  When true,
        % immediately back out of handleClock()
        lDeleted = false
        
        % @param {uint8 1x1} [u8Layout = uint8(1)] - the layout.  1 = wide, not
        %   tall. 2 = narrow, twice as tall. 
        u8Layout = uint8(1); 
        % lIsThere 

    end

    properties (Access = protected)
        
        dHeight = 26;   % height of the row for controls
        dHeightBtn = 24;
        dHeightEdit = 24;
        dHeightPopup = 24;
        dHeightLabel = 16;
        dHeightText = 16;
        
        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthEdit = 70;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        dWidthRange = 100;
        
        dWidthPadApi = 0;
        dWidthPadInitButton = 0;
        dWidthPadInitState = 0;
        dWidthPadName = 5;
        dWidthPadVal = 0;
        dWidthPadDest = 5;
        dWidthPadPlay = 0;
        dWidthPadJog = 0;
        dWidthPadUnit = 0;
        dWidthPadRel = 5;
        dWidthPadZero = 0;
        dWidthPadStores = 0;
        dWidthPadRange = 5;
        
        dWidth2 = 250;
        dHeight2 = 50;
        dPad2 = 0;
        dWidthStatus = 5;
        
        cLabelApi = 'API'
        cLabelInit = 'Init'
        cLabelInitState = 'Init'
        cLabelName = 'Name';
        cLabelValue = 'Val';
        cLabelDest = 'Goal'
        cLabelPlay = 'Go'
        cLabelStores = 'Stores'
        cLabelRange = 'Range'
        cLabelUnit = 'Unit'
        cLabelJogL = '';
        cLabelJog = 'Step';
        cLabelJogR = '';
        cTooltipApiOff = 'Connect to the real Api / hardware';
        cTooltipApiOn = 'Disconnect the real Api / hardware (go into virtual mode)';
        cTooltipInitButton = 'Send the initialize command to this device';
        
        apiv        % virtual Api (for test and debugging).  Builds its own ApivHardwareIO
        api         % Api to the low level controls.  Must be set after initialized.
        
        % @param {clock 1x1} clock - the clock
        clock 
        % @param {char 1x1} cLabel - the label in the GUI
        cLabel = 'CHANGE ME' % name to be displayed by the UI element
        cDir        % current directory
        cDirSave    
        

        uieDest     % textbox to input the desired position
        uieStep     % textbox to input the desired step in disp units
        uitxVal     % label to display the current value
        uitApi      % toggle for real / virtual Api
        uibInit    % button to perform a initialization sequence
        uiilInitState % image logical to show isInitialized state
        % {UIButtonToggle 1x1}
        uibtInit
        uibIndex    % button to perform a homing sequence
        
        
        uibtPlay     % 2014.11.19 - Using a button instead of a toggle
        uitRel      % UIToggle to switch between abs units and rel units (rel to the value when the toggle was clicked)      
        uibZero     % Button to store current position as zero
        
        uibStepPos  % button to perform a positive step move
        uibStepNeg  % button to perform a negative step move
        uitxName  % label to displau the name of the element
        uipUnit    % popup menu
        
        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
        dColorBg = [.94 .94 .94]; % MATLAB default
        
        
        dColorTextMoving = [0 170 0]./255;
        dColorTextStopped = [0 0 0]./255;
        
        u8Play
        u8Pause
        u8Plus
        u8Minus
        u8Bg
        u8Rel
        u8Abs
        u8Zero
        u8Active
        u8Inactive
        u8InitTrue
        u8InitFalse
        u8ToggleOff
        u8ToggleOn
        
        % @param {ConfigHardwareIOPlus 1x1} [config = new ConfigHardwareIOPlus()] - the config instance
        %   !!! WARNING !!!
        %   DO NOT USE a single Config for multiple HardwareIO instances
        %   because deleting one HardwareIO will delete the reference to
        %   the Config instance that the other Hardware IO is using
        config
        
        % @param {function_handle 1x1} [fhValidateDest =
        %   this.validateDest()] - a function that returns a
        %   locical that validates if the requested move is allowed.
        %   It is called within moveToDest() and if it returns false, a
        %   message is displayed sayint the current move is not
        %   allowed.  Is expected that the higher-level class that
        %   implements this (which may access more than one HardwareIO
        %   instance) implements this function
        fhValidateDest
        
        uipStores % UIPopupStruct
        
        % {char 1xm} - string format for value. See formatSpec. 'e', 'f'
        % asupported as of 2016.10.24.  To add support for other formats,
        % search for uitxVal.cVal and add more to the switch block.
        cConversion = 'f'; 
       
        
        % {logical 1x1} - show the name (on left)
        lShowName = true;
        % {logical 1x1} - show the value (right of the edit)
        lShowVal = true;
        % {logical 1x1}
        lShowUnit = true;
        % {logical 1x1}
        lShowZero = true
        % {logical 1x1}
        lShowRel = true
        % {logical 1x1}
        lShowJog = true
        % {logical 1x1}
        lShowDest = true
        % {logical 1x1}
        lShowPlay = true
        % {logical 1x1} - labels above name, val, dest, play, jog, etc.
        lShowLabels = true
        % {logical 1x1} - show the list of stored positions (only if they
        % are present in config)
        lShowStores = true
        % {logical 1x1} - show the clickable toggle / status that shows if
        % is using real Api or virtual Api
        lShowApi = true
        % {logical 1x1} - show the clickable initialize toggle
        lShowInitButton = false
        % {logical 1x1} - show isInitialized() state
        lShowInitState = false
        % {logical 1x1} - show allowed range (config.min - config.max)
        lShowRange = false
        
        % {logical 1x1} - disable the "I" part of HardwareIO (removes jog,
        % play, dest, stores)
        lDisableI = false
        
        % {logical 1x1} - ask the user if they are sure when clicking API
        % button/toggle
        lAskOnApiClick = true
        % {logical 1x1} - ask the user if they are sure when clicking the
        % Init button
        lAskOnInitClick = true
                
        uitxLabelName
        uitxLabelVal
        uitxLabelUnit
        uitxLabelDest
        uitxLabelJog
        uitxLabelJogL
        uitxLabelJogR
        uitxLabelStores
        uitxLabelPlay
        uitxLabelApi
        uitxLabelInit
        uitxLabelInitState
        uitxLabelRange
        
        uitxRange
        
        % {char 1xm} storage of the last display value.  Used to emit
        % eChange events
        cValPrev = '...'
        
        % {char 1xm} - type to use for UIEdit for the destination
        % This ended up opening up a can of worms.  All of the raw/cal
        % logic assumes we are dealing with doubles, not uint or int.  For
        % now, I'm going to cast all values as double
        % cTypeDest = 'd'
        
        % {logical 1x1} true after the initialize() command has been issued
        % up until getApi().isInitialized() returns true
        lIsInitializing = false
    end
    

    events
        
        eUnitChange
        eChange
        eTurnOn
        eTurnOff
    end

    
    methods       
        
        
        %HARDWAREIO Class constructor
        
        function this = HardwareIOPlus(varargin)  
                    
            % Default properties
            
            this.fhValidateDest = this.validateDest;
            this.config = ConfigHardwareIOPlus();
                       
            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    % this.msg(sprintf('settting %s', varargin{k}), 3);
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
                'hiop' ...
            );
                
            
            if this.lDisableI == true
                this.lShowJog = false; 
                this.lShowStores = false; 
                this.lShowPlay = false; 
                this.lShowDest = false; 
                this.lShowInitButton = false;
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
                                    %'BorderWidth',0, ... 

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
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth',0, ... 
                'Position', MicUtils.lt2lb([dLeft dTop dWidth dHeight], hParent));
            drawnow

            %{
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',MicUtils.lt2lb([0 0 this.dWidthStatus dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'Visible', 'off');

            this.hImage = image(this.u8Bg);
            set(this.hImage, 'Parent', this.hAxes);
            %}


            % set(this.hImage, 'CData', imread(fullfile(MicUtils.pathAssets(), 'HardwareIO.png')));

            axis('image');
            axis('off');

            y_rel = -1;


            %{
            this.uibIndex.build(this.hPanel, this.dWidth - 36, 24+y_rel, 36, 12);
            %}

            dTop = -1;
            dTop = 0;
            dTopLabel = -1;
            if this.lShowLabels
                dTop = this.dHeightLabel;
            end

            dLeft = 1;

            % Api toggle
            if (this.lShowApi)
                dLeft = dLeft + this.dWidthPadApi;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn; 
            end


            % Init button
            if (this.lShowInitButton)
                dLeft = dLeft + this.dWidthPadInitButton;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelInit.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibInit.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn; 
            end

            if (this.lShowInitState)
                dLeft = dLeft + this.dWidthPadInitState;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelInitState.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uiilInitState.build(this.hPanel, dLeft, dTop);
                dLeft = dLeft + this.dWidthBtn; 
            end

            % Name
            if this.lShowName
                dLeft = dLeft + this.dWidthPadName;
                if this.lShowLabels
                    this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeightLabel);
                end
                this.uitxName.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthName, this.dHeightText);
                dLeft = dLeft + this.dWidthName;
            end


            
            % Val
            if this.lShowVal
                dLeft = dLeft + this.dWidthPadVal;
                if this.lShowLabels
                    this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthVal, this.dHeightLabel);
                end
                this.uitxVal.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthVal, this.dHeightText);
                dLeft = dLeft + this.dWidthVal;
            end

            % Dest
            if this.lShowDest
                dLeft = dLeft + this.dWidthPadDest;
                if this.lShowLabels
                    this.uitxLabelDest.build(this.hPanel, dLeft, dTopLabel, this.dWidthDest, this.dHeightLabel);
                end
                this.uieDest.build(this.hPanel, dLeft, dTop, this.dWidthDest, this.dHeightEdit);
                dLeft = dLeft + this.dWidthDest;
            end


            % Play
            if this.lShowPlay
                dLeft = dLeft + this.dWidthPadPlay;
                if this.lShowLabels
                    this.uitxLabelPlay.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibtPlay.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

            end 

            % Jog
            if this.lShowJog
                dLeft = dLeft + this.dWidthPadJog;
                if this.lShowLabels
                    this.uitxLabelJogL.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibStepNeg.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

                if this.lShowLabels
                    this.uitxLabelJog.build(this.hPanel, dLeft, dTopLabel, this.dWidthStep, this.dHeightLabel);
                end
                this.uieStep.build(this.hPanel, dLeft, dTop, this.dWidthStep, this.dHeightEdit);
                dLeft = dLeft + this.dWidthStep;

                if this.lShowLabels
                    this.uitxLabelJogR.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibStepPos.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

            end

            

            % Stores
            if this.lShowStores
                dLeft = dLeft + this.dWidthPadStores;
                if this.lShowLabels
                    this.uitxLabelStores.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeight);
                end
                
                % Only draw pulldown if not empty
                if ~isempty(this.config.ceStores)
                    this.uipStores.build(this.hPanel, dLeft, dTop, this.dWidthStores, this.dHeightPopup);
                end
                dLeft = dLeft + this.dWidthStores;
            end

            

            % Range
            if this.lShowRange
                dLeft = dLeft + this.dWidthPadRange;
                
                dLeft = dLeft + this.dWidthPadStores;
                if this.lShowLabels
                    this.uitxLabelRange.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeight);
                end
                
                this.uitxRange.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthRange, this.dHeightBtn)
                dLeft = dLeft + this.dWidthRange;
            end
            
            
            
            % Unit
            if this.lShowUnit
                dLeft = dLeft + this.dWidthPadUnit;
                if this.lShowLabels
                    this.uitxLabelUnit.build(this.hPanel, dLeft, dTopLabel, this.dWidthUnit, this.dHeight);
                end
                this.uipUnit.build(this.hPanel, dLeft, dTop, this.dWidthUnit, this.dHeightPopup);
                dLeft = dLeft + this.dWidthUnit;
            end
            
            % Abs/Rel (to zero)
            if this.lShowRel
                dLeft = dLeft + this.dWidthPadRel;
                this.uitRel.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;
            end

            % Zero
            if this.lShowZero
                dLeft = dLeft + this.dWidthPadZero;
                this.uibZero.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;
            end
            
                    
        end


        % RM 11.28.14: Need to expose a method that checks if hardware IO
        % is at its desired position:
        

        function stepPos(this)
        %STEPPOS Increment dest by +jog step and move to dest.  Units don't
        %come into play here because the dest and the step are in the same
        %unit
        %   see also STEPNEG
        
            
            msg = sprintf(...
                'stepPos from %1.*f %s by + %1.*f %s', ...
                this.unit().precision, ...
                this.valCalDisplay(), ...
                this.unit().name, ...
                this.unit().precision, ...
                this.uieStep.val(), ...
                this.unit().name ...
            );
            this.msg(msg, 3);
            
            % dDest = this.valCalDisplay() + this.uieStep.val()
            dDestCal = this.uieDest.val() + this.uieStep.val();
           
            this.uieDest.setVal(dDestCal);
            this.moveToDest();
        end
        

        function stepNeg(this)
        %STEPPOS Increment dest by -jog step and move to dest.
        %   see also STEPPOS
        
            msg = sprintf(...
                'stepNeg from %1.*f %s by - %1.*f %s', ...
                this.unit().precision, ...
                this.valCalDisplay(), ...
                this.unit().name, ...
                this.unit().precision, ...
                this.uieStep.val(), ...
                this.unit().name ...
            );
            this.msg(msg, 3);
        
            % dDest = this.valCalDisplay() + this.uieStep.val()
            dDestCal = this.uieDest.val() - this.uieStep.val();
           
            this.uieDest.setVal(dDestCal);
            this.moveToDest();           
        end
       
        function setDestCal(this, dCalAbs, cUnit)
        % SETDESTCALABS Update the destination inside the UIEdit based on
        % an absolute value in a particular unit.
        %   @param {double} dCal - desired destination in an abs calibrated
        %       unit (regardless of the UI's "abs/rel" state).
        %   @param {char} [cUnit = this.unit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value was
        %       5 mm and you want the destination to be +1 mm (relative
        %       change), dCalAbs should be 6 and cUnit should be "mm".  
        %       See also SETDESTCAL, SETDESTRAW
        
            if nargin == 1
                cUnit = this.unit().name;
            end
            
            % Convert the absolute value in the passed unit to raw, then convert from raw to
            % the display unit and display abs/rel
            dRaw = this.cal2raw(dCalAbs, cUnit, false);
            
            % Set dest
            this.uieDest.setVal(this.raw2cal(dRaw, this.unit().name, this.uitRel.lVal));
        
            
        end
        
        function setDestCalDisplay(this, dCal, cUnit)
        %SETDESTCAL Update the destination (cal) inside the dest UIEdit.
        %   @param {double} dCal - desired destination in a calibrated
        %       unit that can be either "abs" or "rel" (should match UI state)
        %       If the UI is in "abs" mode, it is assumed
        %       the value passed in is an "abs" value; if the UI is in "rel"
        %       mode, it is assumed the value passed in is a "rel" value
        %       (relative to a stored zero).  If you need to set the
        %       destination with an "abs" value even when the UI is displaying
        %       a "rel" value, use setDestCalAbs.  
        %   @param {char} [cUnit = this.unit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value
        %       was 5 mm and you want the absolute destination to be 6 mm,
        %       dCal should be 1 and cUnit should be "mm".  Alternatively,
        %       you could use setDestCalAbs(6, "mm")
        %   See also SETDESTCALABS, SETDESTRAW

       
            if nargin == 2
                cUnit = this.unit().name;
            end
            
            if ~this.lShowDest
                return
            end
            
            % Convert from the passed unit to raw, then convert from raw to
            % the display unit
            
            dRaw = this.cal2raw(dCal, cUnit, this.uitRel.lVal);
            dDisplay = this.raw2cal(dRaw, this.unit().name, this.uitRel.lVal)
            this.uieDest.setVal(dDisplay);
            
           
        end
        
        

        
        function setDestRaw(this, dRaw)
        %SETDESTRAW Update the destination inside the dest UIEdit from a
        %raw value.  The raw value is converted to the unit and abs/rel
        %settings of the UI
        
            this.uieDest.setVal(this.raw2cal(dRaw, this.unit().name, this.uitRel.lVal));
        end
                
        
        function moveToDest(this)
        %MOVETODEST Performs the HIO motion to the destination shown in the
        %GUI display.  It converts from the display units to raw and tells
        %the Api 
        %   HardwareIO.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW, MOVE
        
            if this.fhValidateDest() ~= true
                return;
            end
            
            msg = sprintf( ...
                'moving from %1.*f %s to %1.*f %s', ...
                this.unit().precision, ...
                this.valCalDisplay(), ...
                this.unit().name, ...
                this.unit().precision, ...
                this.uieDest.val(), ...
                this.unit().name ...
            );
        
            this.msg(msg, 3);
               
            % Need to manually set this for the situation where the lReady
            % property is accessed before handleClock() has a chance to
            % update its value from the device Api.
            
            this.lReady = false;         
            dRaw = this.cal2raw(this.uieDest.val(), this.unit().name, this.uitRel.lVal);
            this.getApi().set(dRaw);
                       
        end
        
        function stop(this)
        %STOPMOVE Aborts the current motion
        %   HardwareIO.stopMove()
            this.getApi().stop();
            
        end

        
        function index(this)
        %INDEX Moves the HIO to the index position
        %   HardwareIO.index()
        
            this.getApi().index();
            
        end
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the Api to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitApi.lVal = true;
            this.uitApi.setTooltip(this.cTooltipApiOn);
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            % set(this.hImage, 'Visible', 'off');
                        
            % Update destination values to match device values
            
            % 2017.01.09 THIS LINE IS FUCKING EVERYTHING AND I DO NOT KNOW WHY
            
            if ~this.lDisableI
                % dVal = this.valCalDisplay()
                % this.setDestCalDisplay(dVal);
            end
            % this.setDestCalDisplay(this.valCalDisplay());

            
            % Kill the Apiv
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.setApiv([]); % This is calling the setter
            end
            
            notify(this, 'eTurnOn');
            
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
            
            % THIS LINE IS FUCKING THINGS AND I DO NOT KNOW WHY
            if ~this.lDisableI
                % this.setDestCalDisplay(this.valCalDisplay());
            end
            % this.setDestCalDisplay(this.valCalDisplay());
            % set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
            
            notify(this, 'eTurnOff');
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
            
            %{
            try
                this.uieDest.setVal(this.apiv.get());
            catch err
                this.uieDest.setVal(0);
            end
            %}
        end
        
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

            % I think a good rule for delete should be that it only
            % deletes things that it adds
            
            this.msg('delete', 5);
            this.lDeleted = true;
            this.save();
            
           % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task'); 
                this.clock.remove(this.id());
            end
                
            %{
            delete(this.uieDest);  
            delete(this.uieStep);
            delete(this.uitxVal);
            delete(this.uitApi);
            delete(this.uibInit);
            delete(this.uiilInitState);
            delete(this.uibIndex);

            delete(this.uibtPlay);
            delete(this.uitRel);     
            delete(this.uibZero);

            delete(this.uibStepPos);
            delete(this.uibStepNeg);
            delete(this.uitxName);
            delete(this.uipUnit);
                
            delete(this.uipStores) 
            delete(this.uitxLabelName);
            delete(this.uitxLabelVal);
            delete(this.uitxLabelUnit);
            delete(this.uitxLabelDest);
            delete(this.uitxLabelJog);
            delete(this.uitxLabelJogL);
            delete(this.uitxLabelJogR);
            delete(this.uitxLabelStores);
            delete(this.uitxLabelPlay);
            delete(this.uitxLabelApi);
            delete(this.uitxLabelInit);
            delete(this.uitxLabelInitState);
            %}
            
            % delete(this.config)
            
            % The Apiv instances have clock tasks so need to delete them
            % first
            
            % delete(this.apiv);
            
            %{
            if ~isempty(this.api) && ... % isvalid(this.api) && ...
                isa(this.api, 'ApivHardwareIOPlus')
                delete(this.api)
            end
            %}
                        
        end
        
        
        function handleClock(this) 
        %HANDLECLOCK Callback triggered by the clock
        %   HardwareIO.HandleClock()
        %   updates the position reading and the hio status (=/~moving)
        
            if this.lDeleted
                fprintf('handleClock() %s returning (already deleted)', this.cName);
                return
            end
            
            try
                               
                % 2016.11.02 CNA always cast as double.  Underlying unit
                % may not be double
                                
                if ~this.lDisableI
                    this.lReady = this.getApi().isReady();
                    this.updatePlayButton()
                else
                    % The Api(V) doesn't implement isReady since this is a
                    % HardwareIO
                end
                
                this.updateDisplayValue();
                
                lInitialized = this.getApi().isInitialized();
                
                % Update visual appearance of button to reflect state
                if this.lShowInitButton
                    if lInitialized
                        this.uibInit.setU8Img(this.u8InitTrue);
                    else
                        this.uibInit.setU8Img(this.u8InitFalse);
                    end
                end
                
                if this.lShowInitState
                    this.uiilInitState.setVal(lInitialized);
                end
                
                
                if this.lIsInitializing && ...
                   lInitialized
                    this.lIsInitializing = false;
                    % this.enable();
                end
                
               
            catch err
                this.msg(getReport(err),2);
        %         %AW(5/24/13) : Added a timer stop when the axis instance has been
        %         %deleted
        %         if (strcmp(err.identifier,'MATLAB:class:InvalidHandle'))
        %                 %msgbox({'Axis Timer has been stopped','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
        %                 stop(this.t);
        %         else
        %             this.msg(getReport(err));
        %         end
        
                % CA 2016 remove the task from the timer
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
                
            end %try/catch

            % this.msg('handleClock() end');
        end 
        
        function dOut = valCal(this, cUnit)
        %VALCAL Get the abs value (not relative to a stored zero) in a calibrated unit.
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in.  We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale. 
        %   @returns {double} - the calibrated value
        %
        %   If you want the value showed in the display (with the active
        %   display unit and abs/rel state use valCalDisplay()
                        
            dOut = this.raw2cal(this.getApi().get(), cUnit, false);
            
        end
        
        function dOut = valCalDisplay(this)
        %VALCALDISPLAY Get the value as shown in the UI with the active
        %display unit and abs/rel state
        %
        %   @returns {double} - the calibrated value
        %
        %   see also VALCAL 
                        
            dOut = this.raw2cal(this.getApi().get(), this.unit().name, this.uitRel.lVal);
            
        end
        
        function dOut = valRaw(this)
        %VALRAW Get the value (not the destination) in raw units. 
           dOut = this.getApi().get(); 
        end
        
        
        function dOut = destCal(this, cUnit)
        %DESTCAL Get the abs destination in a calibrated unit.  
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in. We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale.
        %   @return {double} - the calibrated value
        %   see also DESTCALDISPLAY
            
            % Convert from the UI (unit, rel/abs) into raw, then convert from raw
            % into the specified absolute unit
            
            dRaw = this.cal2raw(this.uieDest.val(), this.unit().name, this.uitRel.lVal);
            dOut = this.raw2cal(dRaw, cUnit, false);
            
        end
        
        
        function dOut = destCalDisplay(this)
        %DESTCALDISPLAY Get the destinatino as shown in the UI with the active
        %display unit and abs/rel state 
        %   @return {double} - the calibrated value
        
            dOut = this.uieDest.val();
            
        end
        

        function dOut = destRaw(this)
        %DESTRAW Get the abs dest value in raw units. Raw value can never
        %changed with the UI configuration so this returns the same thing
        %regardless of UI configuration.
        
        %   HardwareIO.destRAW()  
        
            % CAL =  slope * (RAW - offset)
            % (CAL / slope) + offset = RAW
            dOut = this.cal2raw(this.uieDest.val(), this.unit().name, this.uitRel.lVal);
        
        end
        
        % @return {struct 1x1}
        function stOut = unit(this)
        %UNIT Retrive the active display unit definition structure 
        % (slope, offset, precision)
            stOut = this.config.unit(this.uipUnit.val());
            
        end
        
        function setUnit(this, cUnit)
        %SETUNIT set the active display unit by name
        %   @param {char} cUnit - the name of the unit, i.e., "mm", "m"
        
            for n = 1 : length(this.config.ceUnits)
                this.config.ceUnits{n}.name
                if strcmp(cUnit, this.config.ceUnits{n}.name)
                    this.uipUnit.u8Selected = uint8(n);
                end
            end            
        end
        
        function initialize(this)
           
            this.lIsInitializing = true;
            this.getApi().initialize();
            % this.disable();
            
        end
        
        function enable(this)
            
            this.uitApi.enable();
            this.uibInit.enable();
            this.uiilInitState.disable();
            this.uibtPlay.enable();
            this.uitRel.enable();
            this.uibZero.enable();
            this.uibStepPos.enable();
            this.uibStepNeg.enable();
            this.uieDest.enable();
            this.uieStep.enable();
            this.uipUnit.enable();
            this.uitxVal.enable();
            this.uitxName.enable();
            this.uipStores.enable();

                            
            this.uitxLabelName.enable();
            this.uitxLabelVal.enable();
            this.uitxLabelUnit.enable();
            this.uitxLabelDest.enable();
            this.uitxLabelJog.enable();
            this.uitxLabelJogL.enable();
            this.uitxLabelJogR.enable();
            this.uitxLabelStores.enable();
            this.uitxLabelRange.enable();
            this.uitxLabelPlay.enable();
            this.uitxLabelApi.enable();
            this.uitxLabelInit.enable();
            this.uitxLabelInitState.enable();
            
            
        end
        
        
        function disable(this)
            
            this.uitApi.disable();
            this.uibInit.disable();
            this.uiilInitState.disable();
            this.uibtPlay.disable();
            this.uitRel.disable();
            this.uibZero.disable();
            this.uibStepPos.disable();
            this.uibStepNeg.disable();
            this.uieDest.disable();
            this.uieStep.disable();
            this.uipUnit.disable();
            this.uitxVal.disable();
            this.uitxName.disable();
            this.uipStores.disable();

            this.uitxLabelName.disable();
            this.uitxLabelVal.disable();
            this.uitxLabelUnit.disable();
            this.uitxLabelDest.disable();
            this.uitxLabelJog.disable();
            this.uitxLabelJogL.disable();
            this.uitxLabelJogR.disable();
            this.uitxLabelStores.disable();
            this.uitxLabelRange.disable();
            this.uitxLabelPlay.disable();
            this.uitxLabelApi.disable();
            this.uitxLabelInit.disable();
            this.uitxLabelInitState.disable();
            
            
        end
        
        
        function api = getApi(this)
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end 
            
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
                       
            
            this.u8Play     = imread(fullfile(MicUtils.pathAssets(), 'axis-play-24-3.png'));
            this.u8Pause    = imread(fullfile(MicUtils.pathAssets(), 'axis-pause-24-3.png'));
            %this.u8Plus     = imread(fullfile(MicUtils.pathAssets(), 'axis-plus-24.png'));
            %this.u8Minus    = imread(fullfile(MicUtils.pathAssets(), 'axis-minus-24.png'));
            this.u8Plus     = imread(fullfile(MicUtils.pathAssets(), 'axis-step-forward-24-7.png'));
            this.u8Minus    = imread(fullfile(MicUtils.pathAssets(), 'axis-step-back-24-7.png'));
            switch this.u8Layout
                case 1
                    this.u8Bg = imread(fullfile(MicUtils.pathAssets(), 'hio-bg-24x5-red.png'));
                case 2
                    this.u8Bg = imread(fullfile(MicUtils.pathAssets(), 'hio-bg-50x5-red.png'));
            end
            this.u8Rel = imread(fullfile(MicUtils.pathAssets(), 'abs-rel-rel-24-3.png'));
            this.u8Abs = imread(fullfile(MicUtils.pathAssets(), 'abs-rel-abs-24.png'));
            this.u8Zero = imread(fullfile(MicUtils.pathAssets(), 'set-24.png'));
            
            this.u8ToggleOn = imread(fullfile(MicUtils.pathAssets(), 'hiot-horiz-24-true.png'));
            this.u8ToggleOff = imread(fullfile(MicUtils.pathAssets(), 'hiot-horiz-24-false-yellow.png'));
            
            this.u8Active = imread(fullfile(MicUtils.pathAssets(), 'hiot-true-24.png'));
            this.u8Inactive = imread(fullfile(MicUtils.pathAssets(), 'hiot-false-24.png'));
            
            this.u8InitTrue = imread(fullfile(MicUtils.pathAssets(), 'init-button-true.png'));
            this.u8InitFalse = imread(fullfile(MicUtils.pathAssets(), 'init-button-false-yellow.png'));
            
            
            %activity ribbon on the right
            
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
                this.u8ToggleOff, ...
                this.u8ToggleOn, ...
                st1, ...
                st2 ...
            );
        
            this.uibInit = UIButton( ...
                'Init', ...
                true, ...
                this.u8InitFalse, ...
                true, ...
                'Are you sure you want to initialize this device?  It may take a couple minutes.' ...
            );
            this.uibInit.setTooltip(this.cTooltipInitButton);
            addlistener(this.uibInit,   'eChange', @this.onInitChange);
            
            this.uiilInitState = UIImageLogical();
                        
            
            %{
            
            %set index toggle button
            this.uibIndex = UIButton( ...
                'Index', ...
                true, ...
                imread(fullfile(MicUtils.pathAssets(), 'mcindex.png')), ...
                true, ...
                'Are you sure you want to index?' ...
                );
            
            %}
            %GoTo button
            
            this.uibtPlay = UIButtonToggle( ...
                'Play', ...
                'Pause', ...
                true, ...
                this.u8Play, ...
                this.u8Pause ...
            );
        
            this.uitRel = UIToggle( ...
                'abs', ... % off (showing abs)
                'rel', ... % on (showing rel)
                true, ...
                this.u8Abs, ...
                this.u8Rel ...
            );
        
        
             this.uibZero = UIButton( ...
                'Zero', ...
                true, ...
                this.u8Zero ...
                );

            % imread(fullfile(MicUtils.pathAssets(), 'movingoff.png')), ...
            % imread(fullfile(MicUtils.pathAssets(), 'movingon.png')) ...           
            
            %Jog+ button
            this.uibStepPos = UIButton( ...
                '>', ...
                true, ...
                this.u8Plus ...
                );

            %Jog- button
            this.uibStepNeg = UIButton( ...
                '<', ...
                true, ...
                this.u8Minus ...
                );

            %Editbox to enter the destination
            this.uieDest = UIEdit(sprintf('%s Dest', this.cName), 'd', false);
            
            % Edit box for calibrated jog amount
            this.uieStep = UIEdit(...
                sprintf('%s Step', this.cName),...
                'd', ...
                false, ...
                'center' ...
            );
            this.uieStep.setVal(this.config.dStep);
            
            % Build cell of unit names
            units = {};
            for n = 1:length(this.config.ceUnits)
                units{end + 1} = this.config.ceUnits{n}.name;
            end
            this.uipUnit = UIPopup(units, 'Unit', false);
            
            
            
            %position reading
            this.uitxVal = UIText('Pos', 'right');

            % Name (on the left)
            this.uitxName = UIText(this.cLabel);

            this.setApiv(this.newApiv());
            
            
            % if ~isempty(this.config.ceStores)
                this.uipStores = UIPopupStruct(...
                    'ceOptions', this.config.ceStores, ...
                    'lShowLabel', false, ...
                    'cField', 'name' ...
                );
                
                addlistener(this.uipStores,   'eChange', @this.onStoresChange);
                this.uipStores.setTooltip('Go to a stored position');

                
            % end
                        
            %AW(5/24/13) : populating the destination
            this.uieDest.setVal(this.apiv.get());

            

            % event listeners
            %addlistener(this.uibIndex,  'eChange', @this.handleIndex);

            
            % addlistener(this.uitPlay,   'eChange', @this.handleUI);
            
            addlistener(this.uieDest, 'eEnter', @this.onDestEnter);
            addlistener(this.uitApi,   'eChange', @this.onApiChange);
            addlistener(this.uibtPlay,   'eChange', @this.onPlayChange);
            addlistener(this.uitRel,   'eChange', @this.onRelChange);
            addlistener(this.uipUnit,   'eChange', @this.onUnitChange);

            addlistener(this.uieDest, 'eChange', @this.onDestChange);
            addlistener(this.uieStep, 'eChange', @this.onStepChange);
            addlistener(this.uibStepPos, 'eChange', @this.onStepPosPress);
            addlistener(this.uibStepNeg, 'eChange', @this.onStepNegPress);
            addlistener(this.uibZero, 'eChange', @this.onSetZeroPress);
                 
           
            
            this.uitxLabelName = UIText(this.cLabelName);
            this.uitxLabelVal = UIText(this.cLabelValue, 'Right');
            this.uitxLabelUnit = UIText(this.cLabelUnit);
            this.uitxLabelDest = UIText(this.cLabelDest);
            this.uitxLabelPlay = UIText(this.cLabelPlay);
            this.uitxLabelApi = UIText(this.cLabelApi, 'center');
            this.uitxLabelInit = UIText(this.cLabelInit, 'center');
            this.uitxLabelInitState = UIText(this.cLabelInitState, 'center');
            this.uitxLabelJogL = UIText(this.cLabelJogL, 'center');
            this.uitxLabelJog = UIText(this.cLabelJog, 'center');
            this.uitxLabelJogR = UIText(this.cLabelJogR, 'center');
            this.uitxLabelStores = UIText(this.cLabelStores);
            this.uitxLabelRange = UIText(this.cLabelRange);
            
            this.uitApi.setTooltip(this.cTooltipApiOff);
            this.uitxName.setTooltip('The name of this device');
            this.uitxVal.setTooltip('The value of this device');
            this.uieStep.setTooltip('Change the goal increment value.  Use < > to step goal.');
            this.uieDest.setTooltip('Change the goal value');
            this.uibtPlay.setTooltip('Go to goal');
            this.uipUnit.setTooltip('Change the display units');
            this.updateRelTooltip();
            this.updateZeroTooltip();
            this.updateStepTooltips();
            this.uipUnit.u8Selected = this.u8UnitIndex;
            
            this.uitxRange = UIText('[... - ...]');
            this.updateRange();
            
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
            this.setDestRaw(src.val().raw);
            this.moveToDest();
            
        end
        
        function onDestChange(this, src, evt)
            % notify(this, 'eChange');
        end
        
        function onDestEnter(this, src, evt)
            this.msg('onDestEnter');
            this.moveToDest();
        end
        
        function onStepChange(this, src, evt)
            this.updateStepTooltips();
        end
        
        function onStepPosPress(this, src, evt)
            this.stepPos();
        end
        
        function onStepNegPress(this, src, evt)
            this.stepNeg();
        end
        
        function handleIndex(this, src, evt)
            this.index();
        end
        
        function onInitChange(this, src, evt)
            
            this.msg('onInitChange()');
            this.initialize();
            
        end
        
        function onPlayChange(this, src, evt)
            % Ready means it isn't moving
            
            this.msg('onPlayChange()');
            if this.lReady
                this.msg('handleUI lReady = true. moveToDest()');
                this.moveToDest();
            else
                this.msg('handleUI lReady = false. stop()');
                this.stop();
            end
        end
        
        
        
        % Deprecated (un-deprecitate if you want to move to dest on enter
        % keypress
        
        function handleDest(this, src, evt)
            if uint8(get(this.hParent,'CurrentCharacter')) == 13
                this.moveToDest();
            end
        end
        
        function onUnitChange(this, src, evt)
        % onUnitChange Convert the destination value to the new display unit 
        %   and update storage of u8UnitIndex to the new pulldown index
        
            
           % We have access to the previous display unit via
           % this.u8UnitIndex. Convert the destination value from old unit
           % to raw and then from raw into new unit
          
           
           msg = sprintf(...
               'Changed display units from %s to %s', ...
               this.uipUnit.ceOptions{this.u8UnitIndex}, ...
               this.uipUnit.val() ...
           );
            this.msg(msg, 3);
            
           cUnitPrev = this.config.ceUnits{this.u8UnitIndex}.name;
           dRaw = this.cal2raw(this.uieDest.val(), cUnitPrev, this.uitRel.lVal);
            
            this.uieDest.setVal(this.raw2cal(dRaw, this.unit().name, this.uitRel.lVal));
            
            % Update u8UnitIndex
            this.u8UnitIndex = this.uipUnit.u8Selected;
            
            this.updateZeroTooltip();
            this.updateStepTooltips();
            
            this.updateRange();
            
            notify(this, 'eUnitChange');
                    
        end

        function updateRange(this)
           
            if ~this.lShowRange
                return
            end
            
            dMin = this.raw2cal(this.config.dMin, this.unit().name, this.uitRel.lVal);
            dMax = this.raw2cal(this.config.dMax, this.unit().name, this.uitRel.lVal);
            
            cVal = sprintf(...
                '[%.*f, %.*f]', ...
                this.unit().precision, ...
                dMin, ...
                this.unit().precision, ...
                dMax ...
            );
            this.uitxRange.cVal = cVal;            
        end
        function updateDisplayValue(this)
            
            % Precision can be a number, or an asterisk (*) to refer to an
            % argument in the input list. For example, the input list
            % ('%6.4f', pi) is equivalent to ('%*.*f', 6, 4, pi).
                
           switch this.cConversion
                case 'f'
                    
                    cVal = sprintf(...
                        '%.*f', ...
                        this.unit().precision, ...
                        this.valCalDisplay() ...
                    );
                case 'e'
                    cVal = sprintf(...
                        '%.*e', ...
                        this.unit().precision, ...
                        this.valCalDisplay() ...
                    );
           end 
            
           
           if ~strcmp(this.cValPrev, cVal)
               notify(this, 'eChange');
           end
           
           this.uitxVal.cVal = cVal;
           
           % Update text color for IO (not O) when value is changing
           if ~this.lDisableI
               if this.lReady
                   this.uitxVal.setColor(this.dColorTextStopped);
               else
                   this.uitxVal.setColor(this.dColorTextMoving);
               end
           end
           
           this.cValPrev = cVal;
            
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
        
        function dOut = cal2raw(this, dCal, cUnit, lRel)
        %CAL2RAW Convert from a calibrated unit to raw.
        %   @param {double} dCal - the calibrated value
        %   @param {char} cUnit - the unit of the calibrated value
        %   @param {logical} lRel - true if the calibrated value is
        %       relative to the stored zero, false otherwise
        %   @return {double} - the raw value
        %
        % See also RAW2CAL
        
            stUnitDef = this.config.unit(cUnit);
                    
            % cal = slope * (raw - offset)
            % (cal / slope) + offset = raw
            
            if (lRel)
                % Offset is replaced by the stored dZeroRaw in rel mode
                dOut = dCal/stUnitDef.slope + this.dZeroRaw;
            else
                dOut = dCal/stUnitDef.slope + stUnitDef.offset;
            end

        end

        function dOut = raw2cal(this, dRaw, cUnit, lRel)
        %RAW2CAL Convert from raw to a calibrated unit
        %   @param {double} dRaw - the raw value
        %   @param {char} cUnit - the name of the unit you want to convert to
        %   @param {logical} lRel - true if you want calibrated value
        %       relative to the stored zero, false otherwise
        %   @return {double} the calibrated value
        %
        % See also CAL2RAW
        
            stUnitDef = this.config.unit(cUnit);

            % cal = slope * (raw - offset)
            
            if (lRel)
                % Offset is replaced by the stored dZeroRaw in rel mode
                dOut = stUnitDef.slope * (dRaw - this.dZeroRaw);
            else
                dOut = stUnitDef.slope * (dRaw - stUnitDef.offset);
            end
            
            

        end
                
        
                
        function load(this)
            
            this.msg('load()');
            
            
            if exist(this.file(), 'file') == 2
                load(this.file()); % populates variable s in local workspace
                this.loadClassInstance(s); 
            end
            
            % Update unit UiPopup to saved state
            if  this.lShowUnit && ...
                ~isempty(this.uipUnit)
                this.uipUnit.u8Selected = this.u8UnitIndex;
            end
            
            % Set dZeroRaw (happens automaticallY)
            
            % Update abs/rel UiToggle toggle to saved state
            % The first set does not trigger a nofity (should probably
            % address this at some point) so manually call the handler.

            this.uitRel.lVal = this.lRelVal;
            this.onRelChange([],[]);
            
        end
        
        function save(this)
            
            this.msg('save()');
            
            % Create a nested recursive structure of all public properties
            s = this.saveClassInstance();
            
            % Only want to save u8UnitIndex
            
            %{
            s = struct();
            s.u8UnitIndex = this.u8UnitIndex;
            %}
                                    
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
        
        
        % Allow the user to set the current raw position to any desired calibrated value
        function onSetPress(this, src, evt)
                       
            cePrompt = {'New calibrated value of current position:'};
            cTitle = 'Set Value';
            dLines = 1;
            ceDefaultAns = {num2str(this.valCalDisplay())};
            ceAnswer = inputdlg(...
                cePrompt,...
                cTitle,...
                dLines,...
                ceDefaultAns);
            
            if isempty(ceAnswer)
                return
            end
              
            % Two equations, one unknown.
            %
            % The motor is at raw position "RAW"
            % cal0 = curent calibrated value at RAW 
            % cal1 = future calibrated value at RAW 
            % slope0 = slope before change (from config) (unaffected by
            % this change)
            % offset0 = offset before change (from config)
            % offset1 = offset after change
            %
            % EQ1: cal0 = slope0 * (RAW - offset0)
            % EQ2: cal1 = slope0 * (RAW - offset1)
            % Subtract EQ1 from EQ2:
            % cal1 - cal0 = slope0 * (-offset1 + offset0)
            % Solve for offset1 (offsets are alway in RAW units)
            % offset1 = offset0 - (cal1 - cal0)/slope0  
           
            dNewOffset = this.unit().offset - (str2double(ceAnswer{1}) - this.valCalDisplay())/this.unit().slope;
            this.dZeroRaw = dNewOffset;
            
            this.updateZeroTooltip();
            % Force to "Rel" mode
            this.uitRel.lVal = true;
            
        end
        
        function onSetZeroPress(this, src, evt)
           
            this.onSetPress(src, evt);
            return;
            
            this.dZeroRaw = this.valRaw(); % raw units            
            this.updateZeroTooltip();
            
            % Force to "Rel" mode
            this.uitRel.lVal = true;
            
        end
        
        function onRelChange(this, src, evt)
           
            this.msg('onRelChange');
            % Set the destination to the hardware value in the new
            % calibrated unit
            
            this.lRelVal = this.uitRel.lVal;
            this.uieDest.setVal(this.valCalDisplay());
            this.updateRelTooltip();
            this.updateRange();
            
        end
        
        function lOut = validateDest(this)
            lOut = true;
        end
        
        function updateZeroTooltip(this)
            cMsg = sprintf(...
                'Update the stored zero. It is currently %1.*f %s', ...
                this.unit().precision, ...
                this.raw2cal(this.dZeroRaw, this.unit().name, false), ...
                this.unit().name ...
            );            
            this.uibZero.setTooltip(cMsg);
        end
        
        
        function updateStepTooltips(this)
            cMsgNeg = sprintf(...
                'Decrease goal by %1.*f %s.', ...
                this.unit().precision, ...
                this.uieStep.val(), ...
                this.unit().name ...
            ); 
        
            cMsgPos = sprintf(...
                'Increase goal by %1.*f %s.', ...
                this.unit().precision, ...
                this.uieStep.val(), ...
                this.unit().name ...
            ); 
            this.uibStepPos.setTooltip(cMsgPos);
            this.uibStepNeg.setTooltip(cMsgNeg);
        end
        
        function updateRelTooltip(this)
            
            switch this.uitRel.lVal
                case false
                    cMsg = 'Make value relative to the stored zero. Value is currently absolute.';
                case true
                    cMsg = 'Make value absolute.  Value is currently relative to the stored zero.';
            end
            
            this.uitRel.setTooltip(cMsg);
            
        end
        
        
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowApi
               dOut = dOut + this.dWidthPadApi + this.dWidthBtn;
            end
            
            if this.lShowInitButton
               dOut = dOut + this.dWidthPadInitButton + this.dWidthBtn;
            end
            
            if this.lShowInitState
               dOut = dOut + this.dWidthPadInitState + this.dWidthBtn;
            end

            if this.lShowName
                dOut = dOut + this.dWidthPadName + this.dWidthName;
            end
            
            if this.lShowVal
                dOut = dOut + this.dWidthPadVal + this.dWidthVal;
            end
            
            if this.lShowDest
                dOut = dOut + this.dWidthPadDest + this.dWidthDest;
            end
            if this.lShowPlay
                dOut = dOut + this.dWidthPadPlay + this.dWidthBtn;
            end
            if this.lShowJog
                dOut = dOut + this.dWidthPadJog + 2 * this.dWidthBtn + this.dWidthStep;
            end
            
            if this.lShowUnit
                dOut = dOut + this.dWidthPadUnit + this.dWidthUnit;
            end
            if this.lShowStores % && ~isempty(this.config.ceStores)
                dOut = dOut + this.dWidthPadStores + this.dWidthStores;
            end
            if this.lShowRel
                dOut = dOut + this.dWidthPadRel +  this.dWidthBtn;
            end
            if this.lShowZero
                dOut = dOut + this.dWidthPadZero + this.dWidthBtn;
            end
            
            if this.lShowRange
                dOut = dOut + this.dWidthPadRange + this.dWidthRange;
            end
            
            dOut = dOut + 5;
            % dOut = dOut + this.dWidthUnit;
            
        end
        
        function api = newApiv(this)
        %@return {ApivHardwareIO}
            api = ApivHardwareIOPlus(this.cName, 0, this.clock);
        end
        
        
        

    end

end %class
