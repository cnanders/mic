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
        dHeight = 24;   % height of the UIElement
        
        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthEdit = 70;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        
        dWidth2 = 250;
        dHeight2 = 50;
        dPad2 = 0;
        dWidthStatus = 5;
        
        cTooltipAPIOff = 'Connect to the real API / hardware';
        cTooltipAPIOn = 'Disconnect the real API / hardware (go into virtual mode)';

        
    end

    properties      
        u8UnitIndex = 1;
    end

    properties (SetAccess = private)
        cName = 'CHANGE ME' % name identifier
        lActive     % boolean to tell whether the motor is active or not
        lReady = false  % true when stopped or at its target
        u8Layout = uint8(1); % {uint8 1x1} to store the layout style
        % lIsThere 

    end

    properties (Access = protected)
        
        apiv        % virtual API (for test and debugging).  Builds its own APIVHardwareIO
        api         % API to the low level controls.  Must be set after initialized.
        
        clock       % clock 
        cLabel = 'CHANGE ME' % name to be displayed by the UI element
        cDir        % current directory
        cDirSave    
        

        uieDest     % textbox to input the desired position
        uieStep     % textbox to input the desired step in disp units
        uitxVal     % label to display the current value
        uitAPI      % toggle for real / virtual API
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
        
        config
        dZeroRaw = 0;
        fhValidateDest
        dValRaw % value in raw units (updated by clock)
        
        
        uipStores % UIPopupStruct
        
        lShowZero = true
        lShowRel = true
        lShowJog = true
        lShowDest = true
        lShowPlay = true
        lShowLabels = true
        lShowStores = true
        lShowAPI = true
        lDisableI = false
                
        uitxLabelName
        uitxLabelVal
        uitxLabelUnit
        uitxLabelDest
        uitxLabelJog
        uitxLabelJogL
        uitxLabelJogR
        uitxLabelStores
        uitxLabelPlay
        uitxLabelAPI
    end
    

    events
        
        eUnitChange
    end

    
    methods       
        
        
        %HARDWAREIO Class constructor
        %@param {char 1xm} cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        %@param {clock 1x1} clock - the clock
        %@param {char 1x1} cLabel - the label in the GUI
        %@param {config 1x1} [config = new Config()] - the config instance
        %   !!! WARNING !!!
        %   DO NOT USE a single Config for multiple HardwareIO instances
        %   because deleting one HardwareIO will delete the reference to
        %   the Config instance that the other Hardware IO is using
        %@param {function_handle 1x1} [fhValidateDest =
        %   this.validateDest()] - a function that returns a
        %   locical that validates if the requested move is allowed.
        %   It is called within moveToDest() and if it returns false, a
        %   message is displayed sayint the current move is not
        %   allowed.  Is expected that the higher-level class that
        %   implements this (which may access more than one HardwareIO
        %   instance) implements this function
        %@param {double 1x1} [u8Layout = uint8(1)] - the layout.  1 = wide, not
        %   tall. 2 = narrow, twice as tall. 
        %@param {logical 1x1} [lShowZero = true]
        %@param {logical 1x1} [lShowRel = true]
        %@param {logical 1x1} [lShowStores = true]
        %@param {logical 1x1} [lShowJog = true]
        %@param {logical 1x1} [lShowPlay = true]
        %@param {logical 1x1} [lShowDest = true]
        %@param {logical 1x1} [lShowLabels = true]
        %@param {logical 1x1} [lShowAPI = true] - show the
        %   clickable toggle / status that shows if is using real API or
        %   virtual API
        %@param {logical 1x1} [lDisableI = false] - disable the
        %"I" of HardwareIO (removes jog, play, dest, stores)
        
 
        
        
        function this = HardwareIOPlus(varargin)  
                    
            % Default properties
            
            this.fhValidateDest = this.validateDest;
            this.config = Config();
            
            
            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if isprop(this, varargin{k})
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
                'hiop' ...
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
            
            
            switch this.u8Layout
                
                case 1
                    
                                            %'BorderWidth',0, ... 
                    
                    dHeight = this.dHeight;
                    if this.lShowLabels
                        dHeight = dHeight + 12;
                    end
                    
                    dWidth = this.getWidth();
                    
                    this.hPanel = uipanel( ...
                        'Parent', hParent, ...
                        'Units', 'pixels', ...
                        'Title', blanks(0), ...
                        'Clipping', 'on', ...
                        'BorderWidth',0, ... 
                        'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent));
                    drawnow

                    %{
                    this.hAxes = axes( ...
                        'Parent', this.hPanel, ...
                        'Units', 'pixels', ...
                        'Position',Utils.lt2lb([0 0 this.dWidthStatus dHeight], this.hPanel),...
                        'XColor', [0 0 0], ...
                        'YColor', [0 0 0], ...
                        'HandleVisibility','on', ...
                        'Visible', 'off');

                    this.hImage = image(this.u8Bg);
                    set(this.hImage, 'Parent', this.hAxes);
                    %}
                    
                    
                    % set(this.hImage, 'CData', imread(fullfile(Utils.pathAssets(), 'HardwareIO.png')));

                    axis('image');
                    axis('off');

                    y_rel = -1;


                    %{
                    this.uibIndex.build(this.hPanel, this.dWidth - 36, 24+y_rel, 36, 12);
                    %}
                    
                    dTop = -1;
                    dTopLabel = -1;
                    if this.lShowLabels
                        dTop = 12;
                    end
                    
                    dLeft = 0;
                    
                    % API toggle
                    if (this.lShowAPI)
                        if this.lShowLabels
                            % FIXME
                            this.uitxLabelAPI.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeight);
                        end
                        this.uitAPI.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn + 5; 
                    end
                    
                    
                    % Name
                    if this.lShowLabels
                        this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeight);
                    end
                    this.uitxName.build(this.hPanel, dLeft, 6 + dTop, this.dWidthName, 12);
                    dLeft = dLeft + this.dWidthName;
                    
                    % Val
                    if this.lShowLabels
                        this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthVal, this.dHeight);
                    end
                    this.uitxVal.build(this.hPanel, dLeft, 6 + dTop, this.dWidthVal, 12);
                    dLeft = dLeft + this.dWidthVal;
                                        
                    % Dest
                    if this.lShowDest
                        dLeft = dLeft + 5;
                        if this.lShowLabels
                            this.uitxLabelDest.build(this.hPanel, dLeft, dTopLabel, this.dWidthDest, this.dHeight);
                        end
                        this.uieDest.build(this.hPanel, dLeft, dTop, this.dWidthDest, this.dHeight);
                        dLeft = dLeft + this.dWidthDest;
                    end
                    
                    
                    % Play
                    if this.lShowPlay
                        if this.lShowLabels
                            this.uitxLabelPlay.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeight);
                        end
                        this.uibtPlay.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn;
                        
                    end 
                    
                    % Jog
                    if this.lShowJog
                        
                        if this.lShowLabels
                            this.uitxLabelJogL.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeight);
                        end
                        this.uibStepNeg.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn;
                        
                        if this.lShowLabels
                            this.uitxLabelJog.build(this.hPanel, dLeft, dTopLabel, this.dWidthStep, this.dHeight);
                        end
                        this.uieStep.build(this.hPanel, dLeft, dTop, this.dWidthStep, this.dHeight);
                        dLeft = dLeft + this.dWidthStep;
                        
                        
                        
                        
                        if this.lShowLabels
                            this.uitxLabelJogR.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeight);
                        end
                        this.uibStepPos.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn;
                        
                    end
                    
                    
                    
                   
                    
                    
                    % Unit
                    if this.lShowLabels
                        this.uitxLabelUnit.build(this.hPanel, dLeft, dTopLabel, this.dWidthUnit, this.dHeight);
                    end
                    this.uipUnit.build(this.hPanel, dLeft, dTop, this.dWidthUnit, this.dHeight);
                    dLeft = dLeft + this.dWidthUnit;
                    
                    % Stores
                    if this.lShowStores && ...
                       ~isempty(this.config.ceStores)
                        if this.lShowLabels
                            this.uitxLabelStores.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeight);
                        end
                        this.uipStores.build(this.hPanel, dLeft, dTop, this.dWidthStores, this.dHeight);
                        dLeft = dLeft + this.dWidthStores;
                    end
                    
                     % Rel
                    if this.lShowRel
                        this.uitRel.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn;
                    end
                    
                    % Zero
                    
                    if this.lShowZero
                        this.uibZero.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);
                        dLeft = dLeft + this.dWidthBtn;
                    end
                    
                    
                    
                case 2
                    

                    this.hPanel = uipanel( ...
                        'Parent', hParent, ...
                        'Units', 'pixels', ...
                        'Title', blanks(0), ...
                        'Clipping', 'on', ...
                        'BorderWidth',0, ... 
                        'Position', Utils.lt2lb([ ...
                            dLeft ...
                            dTop ...
                            this.dWidth2 ...
                            this.dHeight2], hParent));
                    drawnow

                    this.hAxes = axes( ...
                        'Parent', this.hPanel, ...
                        'Units', 'pixels', ...
                        'Position',Utils.lt2lb([0 0 this.dWidthStatus this.dHeight2], this.hPanel),...
                        'XColor', [0 0 0], ...
                        'YColor', [0 0 0], ...
                        'HandleVisibility','on', ...
                        'Visible', 'off');

                    this.hImage = image(this.u8Bg);
                    set(this.hImage, 'Parent', this.hAxes);

                    axis('image');
                    axis('off');

                    %{
                    this.uibIndex.build(this.hPanel, this.dWidth - 36, 24+y_rel, 36, 12);
                    %}

                    
                    % First row, from right to left
                    
                    dTop = this.dPad2;
                    right = this.dWidth2;
                    
                    % Unit
                    right = right + 2 * this.dPad2 - this.dWidthUnit - this.dPad2;                     
                    this.uipUnit.build(this.hPanel, right, dTop, this.dWidthUnit, this.dHeight);

                    
                    right = right - 75 - 3;
                    this.uitxVal.build(this.hPanel, right, 3 + dTop, 75, 12);
                    
                    dPad = 5;

                    this.uitxName.build(this.hPanel, this.dWidthStatus + dPad, 3 + dTop, right - this.dWidthStatus - dPad, 12);
                    
                    % Second row, from right to left
                    
                    dTop = 24;
                    right = this.dWidth2;
                    
                    if this.lShowZero
                        right = right + 2 * this.dPad2 - this.dWidthBtn - this.dPad2; 
                        this.uibZero.build(this.hPanel, right, dTop, this.dWidthBtn, this.dHeight);
                    end
                    
                    if this.lShowRel
                        right = right - this.dWidthBtn;
                        this.uitRel.build(this.hPanel, right, dTop + 1, this.dWidthBtn, this.dHeight);
                    end

                    if this.lShowJog
                        right = right - this.dWidthBtn;
                        this.uibStepPos.build(this.hPanel, right, dTop, this.dWidthBtn, this.dHeight);

                        right = right - 50;
                        this.uieStep.build(this.hPanel, right, dTop, 50, this.dHeight);

                        right = right - this.dWidthBtn;
                        this.uibStepNeg.build(this.hPanel, right, dTop, this.dWidthBtn, this.dHeight);
                    end
                    
                    if this.lShowPlay
                        right = right - this.dWidthBtn;
                        this.uibtPlay.build(this.hPanel, right, dTop, this.dWidthBtn, this.dHeight);
                    end
                    
                    % Absorb rest of the width with the edit
                    
                    if this.lShowDest
                        dWidth = right - this.dWidthStatus;
                        this.uieDest.build(this.hPanel, this.dWidthStatus, dTop, dWidth, this.dHeight);
                    end
                    
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

       
            if nargin == 1
                cUnit = this.unit().name;
            end
            
            % Convert from the passed unit to raw, then convert from raw to
            % the display unit
            
            dRaw = this.cal2raw(dCal, cUnit, this.uitRel.lVal);
            this.uieDest.setVal(this.raw2cal(dRaw, this.unit().name, this.uitRel.lVal));
            
           
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
        %the API 
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
            % update its value from the device API.
            
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
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitAPI.lVal = true;
            this.uitAPI.setTooltip(this.cTooltipAPIOn);
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            % set(this.hImage, 'Visible', 'off');
                        
            % Update destination values to match device values
            this.setDestRaw(this.api.get());
            
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
            % set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
        end
        
        function setApi(this, api)
            this.api = api;
        end
        
        function set.apiv(this, value)
            
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
            end

            this.apiv = value;
            try
                this.uieDest.setVal(this.apiv.get());
            catch err
                this.uieDest.setVal(0);
            end
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
            
            % The APIV instances have clock tasks so need to delete them
            % first
            
            delete(this.apiv);
            
            if ~isempty(this.api) && ... % isvalid(this.api) && ...
                isa(this.api, 'APIVHardwareIOPlus')
                delete(this.api)
            end
            
            delete(this.uieDest);  
            delete(this.uieStep);
            delete(this.uitxVal);
            delete(this.uitAPI);
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
            delete(this.uitxLabelAPI);
            
            
          
            delete(this.config)

                        
        end
        
        function handleClock(this) 
        %HANDLECLOCK Callback triggered by the clock
        %   HardwareIO.HandleClock()
        %   updates the position reading and the hio status (=/~moving)
        
            try
                %AW 2014-9-9
                %TODO : this should be refactored in a readRaw function
                %see HardwareO for example
                %make sure diode etc have it also
                
                this.dValRaw = this.getApi().get();                
                      
                % update uitxVal
                
                % Precision can be a number, or an asterisk (*) to refer to an
                % argument in the input list. For example, the input list
                % ('%6.4f', pi) is equivalent to ('%*.*f', 6, 4, pi).
                
                this.uitxVal.cVal = sprintf(...
                    '%.*f', ...
                    this.unit().precision, ...
                    this.valCalDisplay() ...
                );
                                
                % 2014.05.19 
                % Need to update a property lIsThere which is true when
                % the destination and the position match within a tolerance
                % (for now we will set tolerance to zero)
                % 2014.11.19: changing this so that there is a tolerance:
                
                
                % 2014.11.20: Linking this check to the api call which asks
                % stage if it's ready, which means that it's either stopped
                % or reached its target.
                
                if ~this.lDisableI
                    this.lReady = this.getApi().isReady();
                    this.updatePlayButton()
                else
                    % The API(V) doesn't implement isReady since this is a
                    % HardwareIO
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
        %VALRAW Get the value (not the destination) in raw units. This
        %value is also accessible with the dValRaw property
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
        
        function stOut = unit(this)
        %UNIT Regrive the active display unit definition structure 
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
        
        

    end %methods
    
    methods (Access = protected)
            

        function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
        
        
            % Load in the config file (Need to figure out how this will
            % work with classes that extend this class
                       
            
            this.u8Play     = imread(fullfile(Utils.pathAssets(), 'axis-play-24-3.png'));
            this.u8Pause    = imread(fullfile(Utils.pathAssets(), 'axis-pause-24-3.png'));
            %this.u8Plus     = imread(fullfile(Utils.pathAssets(), 'axis-plus-24.png'));
            %this.u8Minus    = imread(fullfile(Utils.pathAssets(), 'axis-minus-24.png'));
            this.u8Plus     = imread(fullfile(Utils.pathAssets(), 'axis-step-forward-24-7.png'));
            this.u8Minus    = imread(fullfile(Utils.pathAssets(), 'axis-step-back-24-7.png'));
            switch this.u8Layout
                case 1
                    this.u8Bg = imread(fullfile(Utils.pathAssets(), 'hio-bg-24x5-red.png'));
                case 2
                    this.u8Bg = imread(fullfile(Utils.pathAssets(), 'hio-bg-50x5-red.png'));
            end
            this.u8Rel = imread(fullfile(Utils.pathAssets(), 'axis-rel-24-3.png'));
            this.u8Abs = imread(fullfile(Utils.pathAssets(), 'axis-abs-24-3.png'));
            this.u8Zero = imread(fullfile(Utils.pathAssets(), 'axis-zero-24-2.png'));
            
            this.u8Active = imread(fullfile(Utils.pathAssets(), 'hiot-true-24.png'));
            this.u8Inactive = imread(fullfile(Utils.pathAssets(), 'hiot-false-24.png'));
            
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

            this.uitAPI = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                this.u8Inactive, ...
                this.u8Active, ...
                st1, ...
                st2 ...
            );
                        
            
            %{
            
            %set index toggle button
            this.uibIndex = UIButton( ...
                'Index', ...
                true, ...
                imread(fullfile(Utils.pathAssets(), 'mcindex.png')), ...
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
                false, ...
                this.u8Abs, ...
                this.u8Rel ...
            );
        
        
             this.uibZero = UIButton( ...
                'Zero', ...
                true, ...
                this.u8Zero ...
                );

            % imread(fullfile(Utils.pathAssets(), 'movingoff.png')), ...
            % imread(fullfile(Utils.pathAssets(), 'movingon.png')) ...           
            
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

            this.apiv = this.newAPIV();
            
            
            if ~isempty(this.config.ceStores)
                this.uipStores = UIPopupStruct(...
                    'ceOptions', this.config.ceStores, ...
                    'lShowLabel', false, ...
                    'cField', 'name' ...
                );
                
                addlistener(this.uipStores,   'eChange', @this.onStoresChange);
                this.uipStores.setTooltip('Go to a stored position');

                
            end
                        
            %AW(5/24/13) : populating the destination
            this.uieDest.setVal(this.apiv.get());

            

            % event listeners
            %addlistener(this.uibIndex,  'eChange', @this.handleIndex);

            
            % addlistener(this.uitPlay,   'eChange', @this.handleUI);
            
            addlistener(this.uitAPI,   'eChange', @this.onAPIChange);
            addlistener(this.uibtPlay,   'eChange', @this.onPlayChange);
            addlistener(this.uitRel,   'eChange', @this.onRelChange);
            addlistener(this.uipUnit,   'eChange', @this.onUnitChange);

            addlistener(this.uieStep, 'eChange', @this.onStepChange);
            addlistener(this.uibStepPos, 'eChange', @this.onStepPosPress);
            addlistener(this.uibStepNeg, 'eChange', @this.onStepNegPress);
            addlistener(this.uibZero, 'eChange', @this.onZeroPress);
                        
            this.uitxLabelName = UIText('Name');
            this.uitxLabelVal = UIText('Value', 'Right');
            this.uitxLabelUnit = UIText('Unit');
            this.uitxLabelDest = UIText('Goal');
            this.uitxLabelPlay = UIText('Go');
            this.uitxLabelAPI = UIText('API', 'center');
            this.uitxLabelJogL = UIText('', 'center');
            this.uitxLabelJog = UIText('Step', 'center');
            this.uitxLabelJogR = UIText('', 'center');
            this.uitxLabelStores = UIText('Stores');
            
            this.uitAPI.setTooltip(this.cTooltipAPIOff);
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
            
            this.load();
            
            
        end
        
        function onAPIChange(this, src, evt)
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
        
        
        
        function onPlayChange(this, src, evt)
            % Ready means it isn't moving
            if this.lReady
                % this.msg('handleUI lReady = true. moveToDest()');
                this.moveToDest();
            else
                % this.msg('handleUI lReady = false. stop()');
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
            
            notify(this, 'eUnitChange');
                    
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
        
        function onZeroPress(this, src, evt)
           
            this.dZeroRaw = this.valRaw(); % raw units            
            this.updateZeroTooltip();
            
            % Force to "Rel" mode
            this.uitRel.lVal = true;
            
        end
        
        function onRelChange(this, src, evt)
           
            % Set the destination to the hardware value in the new
            % calibrated unit
            
            this.uieDest.setVal(this.valCalDisplay());
            this.updateRelTooltip();
            
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
        
        function api = getApi(this)
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end 
            
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowAPI
               dOut = dOut + this.dWidthBtn;
            end

            dOut = dOut + this.dWidthName;
            dOut = dOut + this.dWidthVal;
            if this.lShowDest
                dOut = dOut + this.dWidthDest + 5;
            end
            if this.lShowPlay
                dOut = dOut + this.dWidthBtn;
            end
            if this.lShowJog
                dOut = dOut + 2 * this.dWidthBtn + this.dWidthStep;
            end
            if this.lShowStores && ~isempty(this.config.ceStores)
                dOut = dOut + this.dWidthStores;
            end
            if this.lShowRel
                dOut = dOut + this.dWidthBtn;
            end
            if this.lShowZero
                dOut = dOut + this.dWidthBtn;
            end
            dOut = dOut + this.dWidthUnit;
            
        end
        
        function api = newAPIV(this)
        %@return {APIVHardwareIO}
            api = APIVHardwareIOPlus(this.cName, 0, this.clock);
        end
        
        
        

    end

end %class
