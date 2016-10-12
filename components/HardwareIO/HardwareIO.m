classdef HardwareIO < HandlePlus
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
        dHeight = 36;   % height of the UIElement
        dWidth = 290;   % width of the UIElement
        
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
        apiv            % virtual API (for test and debugging).  Builds its own APIVHardwareIO
        api             % API to the low level controls.  Must be set after initialized.
    end

    properties (SetAccess = private)
        cName   % name identifier
        dValRaw
        dValCal
        dDest  % Stores the value of uieDest
        lIsThere
        lActive     % boolean to tell whether the motor is active or not
    end

    properties (Access = protected)
        
        cl          % clock 
        cDispName   % name to be displayed by the UI element
        cDir        % current directory

        uieDest     % textbox to input the desired position
        uitxPos     % label to display the current position reading
        uitActive   % UIToggle button ;made private 6/20/13 (AW)
        uitCal      % UIToggle button to tell whether the reading is calibr
        uibSetup    % button that launches the setup menu
        uibIndex    % button to perform a homing sequence
        uitPlay     % UIToggle to start motion to the desired value
        
        uibtPlay     % 2014.11.19 - Using a button instead of a toggle
        
        uibStepPos  % button to perform a positive step move
        uibStepNeg  % button to perform a negative step move
        uitxLabel   % label to displau the name of the element


        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
        u8Play
        u8Pause
        u8Plus
        u8Minus
        lReady
        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = HardwareIO(cName, cl, cDispName)  
        %HARDWAREIO Class constructor
        %   hio = HardwareIO('name', clock) uses 'name' as default display
        %   hio = HardwareIO('name', clock, 'dispName') 
        %
        % See also DELETE, INIT, BUILD
            
            if ~exist('cDispName', 'var')
                cDispName = cName; % ms
            end
            
            this.cName = cName;
            this.cl = cl;
            this.cDispName = cDispName;

            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));

            this.init();
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
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent));
            drawnow
                        
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'Visible', 'off');
            
            this.hImage = image(imread(fullfile(Utils.pathAssets(), 'HardwareIO.png')));
            set(this.hImage, 'Parent', this.hAxes);
            % set(this.hImage, 'CData', imread(sprintf('%s../assets/HardwareIO.png', this.cDir)));
            
            axis('image');
            axis('off');
            
            y_rel = -1;
 
            %{
            this.uitActive.build(hPanel, this.dWidth-12, 0+y_rel, 12, 36);
            this.uitCal.build(  hPanel, this.dWidth-12-36, 0+y_rel, 36, 12);
            this.uibSetup.build(hPanel, this.dWidth-12-36, 12+y_rel, 36, 12);
            this.uibIndex.build(hPanel, this.dWidth-12-36, 24+y_rel, 36, 12);

            this.uitPlay.build(hPanel, this.dWidth-12-36-36, 0+y_rel, 36, 36);

            this.uibStepPos.build(hPanel, this.dWidth-12-36-36-18, 0+y_rel, 18, 18);
            this.uibStepNeg.build(hPanel, this.dWidth-12-36-36-18, 18+y_rel, 18, 18);

            this.uieDest.build(hPanel, this.dWidth-12-36-36-18-75, 0+y_rel, 75, 36);
            this.uitxPos.build(hPanel, this.dWidth-12-36-36-18-75-75-6, 12+y_rel, 75, 12);
            this.uitxLabel.build(hPanel, 3, 12+y_rel, this.dWidth-12-36-36-18-75-75, 12);
            %}
            this.uitCal.build(this.hPanel, this.dWidth - 36, 0+y_rel + 1, 36, 12);
            this.uibSetup.build(this.hPanel, this.dWidth - 36, 12+y_rel, 36, 12);
            this.uibIndex.build(this.hPanel, this.dWidth - 36, 24+y_rel, 36, 12);

            % this.uitPlay.build(this.hPanel, this.dWidth - 36 - 36, 0+y_rel + 1, 36, 36);
            this.uibtPlay.build(this.hPanel, this.dWidth - 36 - 36, 0+y_rel + 1, 36, 36);
            

            this.uibStepPos.build(this.hPanel, this.dWidth - 36 - 36 - 18, 0+y_rel, 18, 18);
            this.uibStepNeg.build(this.hPanel, this.dWidth - 36 - 36 - 18, 18+y_rel, 18, 18);

            this.uieDest.build(this.hPanel, this.dWidth-36-36-18-75, 0+y_rel, 75, 36);
            this.uitxPos.build(this.hPanel, ...
                this.dWidth-36-36-18-75-75-6, ...
                12 + y_rel, ...
                75, ...
                18);
            this.uitxLabel.build(this.hPanel, ...
                3, ...
                12 + y_rel, ...
                this.dWidth-36-36-18-75-75-3, ...
                18);
            
            %{
            ch = get(this.hPanel,'Children');

            try
                set(this.hPanel,'BackgroundColor',([0 0 0]+1)*0.90);
                for i=1:length(ch)
                    if ~strcmp(get(ch(i),'Style'),'edit')
                        set(ch(i),'BackgroundColor',([0 0 0]+1)*0.90);
                    end
                end
            catch err

            end
            %}
        end


        % RM 11.28.14: Need to expose a method that checks if hardware IO
        % is at its desired position:
        

        function stepPos(this)
        %STEPPOS Performs a positive step motion
        %   HardwareIO.stepPos()
        
            % update destination
            if this.uitCal.lVal
                this.uieDest.setVal(this.uieDest.val() + this.setup.uieStepCal.val());
            else
                this.uieDest.setVal(this.uieDest.val() + this.setup.uieStepRaw.val());
            end
            % move
            this.moveToDest();
        end
        

        function stepNeg(this)
        %STEPNEG Performs a positive step motion
        %   HardwareIO.stepNeg()
        
            % update destination
            if this.uitCal.lVal
                this.uieDest.setVal(this.uieDest.val() - this.setup.uieStepCal.val());
            else
                this.uieDest.setVal(this.uieDest.val() - this.setup.uieStepRaw.val());
            end
            % move
            this.moveToDest();           
        end
       
        
        function setDestCal(this, dCal)
        %SETDESTCAL Changes the destination (cal) inside the dest UIEdit
        %   HardwareIO.setDestCal(dest)
        %   useful for command line control 
        %       (shorthand for hio.uieDest.setVal(value))
        
            if this.uitCal.lVal
                this.uieDest.setVal(dCal);
            else
                this.uieDest.setVal(this.setup.cal2raw(dCal));
            end
        end

        
        function setDestRaw(this, dRaw)
        %SETDESTRAW Changes the destination (cal) inside the dest UIEdit
        %   HardwareIO.setDestRaw(dest)
        
            if this.uitCal.lVal
                this.uieDest.setVal(this.setup.raw2cal(dRaw));
            else
                this.uieDest.setVal(dRaw);
            end
        end
        
        
        function moveToDest(this)
        %MOVETODEST Performs the HIO motion to the destination
        %   HardwareIO.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW, MOVE
        
        
            this.lIsThere = false;
        
            if this.lActive
                % Device
                if this.uitCal.lVal
                    this.api.set(this.setup.cal2raw(this.uieDest.val()));
                else
                    this.api.set(this.uieDest.val());
                end
            else
                % Virtual
                if this.uitCal.lVal
                    this.apiv.set(this.setup.cal2raw(this.uieDest.val()));
                else
                    this.apiv.set(this.uieDest.val());
                end
            end             
        end
        
        
        %AW2013-7-17 : added this method to programmatically change the
        %position. It was not possible to refactor moveToDest, 
        %since we need the data validation it provides.
        function move(this, value)
        %MOVE Moves the Axis to the desired position and updates the dest
        %   HardwareIO.move(value)
        %       value is either raw or cal, depending on the current
        %       settings
        %
        % See also SETDESTCAL, SETDESTRAW, MOVETODEST
            this.uieDest.setVal(value)
            this.moveToDest();
        end

        
        function stop(this)
        %STOPMOVE Aborts the current motion
        %   HardwareIO.stopMove()
        
            if this.lActive
                this.api.stop();
            else
                this.apiv.stop();
            end 
        end

        
        function index(this)
        %INDEX Moves the HIO to the index position
        %   HardwareIO.index()
        
            if this.lActive
                this.api.index();
            else
                this.apiv.index();
            end 
        end
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            set(this.hImage, 'Visible', 'off');
                        
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
                this.apiv = APIVHardwareIO(this.cName, 0, this.cl);
            end
            
            this.lActive = false;
            set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
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
        
        function dDestVal = get.dDest(this)

            if this.uitCal.lVal
                dDestVal = (this.setup.cal2raw(this.uieDest.val()));
            else
                dDestVal = (this.uieDest.val());
            end
        end
        
        function lIsThereVal = get.lIsThere(this)
            if this.lActive
                this.lIsThere = this.api.isReady();
            else
                this.lIsThere = this.apiv.isReady();
            end
            lIsThereVal = this.lIsThere;
        end
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

           % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.cl.remove(this.id());
            end

            %{
            if isvalid(this.t)
                if strcmp(this.t.Running, 'on')
                     stop(this.t);
                end
                delete(this.t)
            end
            %}
            % av.  Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.apiv)
                 delete(this.apiv);
            end

            % delete(this.setup);
            % setup ?

            if ~isempty(this.uitActive)
                delete(this.uitActive)
            end
            if ~isempty(this.uitCal)
                delete(this.uitCal)
            end
            if ~isempty(this.uibSetup)
                delete(this.uibSetup)
            end
            if ~isempty(this.uibIndex)
                delete(this.uibIndex)
            end
            if ~isempty(this.uitPlay)
                delete(this.uitPlay)
            end
            if ~isempty(this.uibStepPos)
                delete(this.uibStepPos)
            end
            if ~isempty(this.uibStepNeg)
                delete(this.uibStepNeg)
            end
            if ~isempty(this.uieDest)
                delete(this.uieDest)
            end
            if ~isempty(this.uitxPos)
                delete(this.uitxPos)
            end
            if ~isempty(this.uitxLabel)
                delete(this.uitxLabel)
            end
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
                if this.lActive
                    this.dValRaw = this.api.get();
%                     try
%                         this.dValRaw = this.api.get();
%                     catch error
%                         warning('hio:error while reading %s. Deactivating...\ndetails : %s', ...
%                             this.cName, error.message)
%                         this.lActive = false;
%                     end
                else
                    this.dValRaw = this.apiv.get();
                end
                
                this.dValCal = this.setup.raw2cal(this.dValRaw);
                
                % 2014.05.19 
                % Need to update a property lIsThere which is true when
                % the destination and the position match within a tolerance
                % (for now we will set tolerance to zero)
                % 2014.11.19: changing this so that there is a tolerance:
                
                
                % 2014.11.20: Linking this check to the api call which asks
                % stage if it's ready, which means that it's either stopped
                % or reached its target.
                
                if this.lActive
                    this.lIsThere = this.api.isReady();
                else
                    this.lIsThere = this.apiv.isReady();
                end
                
                
                if this.lActive
                    this.lReady = this.api.isReady();
                else
                    this.lReady = this.apiv.isReady();
                end
                

                % update uitxPos
                if this.uitCal.lVal
                    % cal
                    this.uitxPos.cVal = sprintf('%.3f', this.dValCal); %num2str(this.setup.raw2cal(this.dValRaw));                    
                else
                    % raw
                    this.uitxPos.cVal = sprintf('%.3f', this.dValRaw); % num2str(this.dValRaw);
                end
               
                this.updatePlayButton()
                
               
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
            end %try/catch

        end 

    end %methods
    
    methods (Access = protected)
            

        function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
        
        
            
        
%             this.u8Play     = imread(sprintf('%s../assets/axis-play.png', this.cDir));
%             this.u8Pause    = imread(sprintf('%s../assets/axis-pause.png', this.cDir));
%             this.u8Plus     = imread(sprintf('%s../assets/axis-plus.png', this.cDir));
%             this.u8Minus    = imread(sprintf('%s../assets/axis-minus.png', this.cDir));
%             
            
            this.u8Play     = imread(fullfile(Utils.pathAssets(), 'axis-play.png'));
            this.u8Pause    = imread(fullfile(Utils.pathAssets(), 'axis-pause.png'));
            this.u8Plus     = imread(fullfile(Utils.pathAssets(), 'axis-plus.png'));
            this.u8Minus    = imread(fullfile(Utils.pathAssets(), 'axis-minus.png'));
        
            this.setup = SetupHardwareIO(this.cName);
            addlistener(this.setup, 'eLowLimitChange', @this.handleLowLimitChange);
            addlistener(this.setup, 'eHighLimitChange', @this.handleHighLimitChange);
            addlistener(this.setup, 'eCalibrationChange', @this.handleCalibrationChange);

            %activity ribbon on the right
            %{
            this.uitActive = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                imread(sprintf('%s../assets/controllernotactive.png', this.cDir)), ...
                imread(sprintf('%s../assets/controlleractive.png', this.cDir)), ...
                true, ...
                'Are you sure you want to change status?' ...
                );
            %}

            %calibration toggle button
            
            
            
            
            this.uitCal = UIToggle( ...
                'raw', ...  % (off) showing raw
                'cal', ...  % (on) showing cal
                true, ...
                imread(fullfile(Utils.pathAssets(), 'mcRAW.png')), ...
                imread(fullfile(Utils.pathAssets(), 'mcCAL.png')) ...
                );

            %set index toggle button
            this.uibIndex = UIButton( ...
                'Index', ...
                true, ...
                imread(fullfile(Utils.pathAssets(), 'mcindex.png')), ...
                true, ...
                'Are you sure you want to index?' ...
                );

            %setup toggle button
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(fullfile(Utils.pathAssets(), 'mcsetup.png')) ...
                );

            %GoTo button
            this.uitPlay = UIToggle( ...
                'play', ... % stopped
                'stop', ... % moving
                true, ...
                this.u8Play, ...
                this.u8Pause ...
                );
            
            this.uibtPlay = UIButtonToggle( ...
                'Play', ...
                'Pause', ...
                true, ...
                this.u8Play, ...
                this.u8Pause ...
            );

            % imread(sprintf('%s../assets/movingoff.png', this.cDir)), ...
            % imread(sprintf('%s../assets/movingon.png', this.cDir)) ...           

            
            
            %Jog+ button
            this.uibStepPos = UIButton( ...
                '+', ...
                true, ...
                this.u8Plus ...
                );

            %Jog- button
            this.uibStepNeg = UIButton( ...
                '-', ...
                true, ...
                this.u8Minus ...
                );

            %Editbox to enter the destination
            this.uieDest = UIEdit(sprintf('%s Dest', this.cName), 'd', false);

            % Setting to default to calibrated values:
            this.uitCal.lVal = true;
            
            %position reading
            this.uitxPos = UIText('Pos', 'right');

            % Name (on the left)
            this.uitxLabel = UIText(this.cDispName);

            this.apiv = APIVHardwareIO(this.cName, 0, this.cl);

            %AW(5/24/13) : populating the destination
            this.uieDest.setVal(this.apiv.get());

            % 2013.07.08 CNA
            % Using clock instead of timer
            fh = @this.handleClock;
            this.cl.add(fh, this.id(), this.setup.uieDelay.val());

            % event listeners
            addlistener(this.uitCal,    'eChange', @this.handleUI);
            addlistener(this.uitPlay,   'eChange', @this.handleUI);
            addlistener(this.uibtPlay,   'eChange', @this.handleUI);

            addlistener(this.uibStepPos,'eChange', @this.handleUI);
            addlistener(this.uibStepNeg,'eChange', @this.handleUI);
            addlistener(this.uibIndex,  'eChange', @this.handleUI);
            addlistener(this.uibSetup,  'eChange', @this.handleUI);

        end
        
        
        
        function handleUI(this, src, evt)
        %HANDLEUI Callback for the User interface (uicontrols etc.)
        %   HardwareIO.handleUI(src,~)

            if (src==this.uibStepPos)
                this.stepPos();

            elseif (src==this.uibStepNeg)
                this.stepNeg();

            elseif (src==this.uieDest)
                % if there is an enter key press, move to destination
                if uint8(get(this.hParent,'CurrentCharacter')) == 13
                    this.moveToDest();
                end
                
            elseif (src == this.uibtPlay)
                
                % Ready means it isn't moving
                
                if this.lReady
                    % this.msg('handleUI lReady = true. moveToDest()');
                    this.moveToDest();
                else
                    % this.msg('handleUI lReady = false. stop()');
                    this.stop();
                end
                
            elseif (src==this.uitPlay)
                
                % LEGACY, moved to UIButtonToggle
                %
                % Update 2014.11.19 CNA/RM
                %
                % We decided to treat clicking the toggle more as a button
                % press.  On click, we check to see if lIsThere =
                % true/false.  If lIsThere is false, it means we are moving
                % and we want to issue a stop command.  If lIsThere is
                % true, it means we are stopped and want to issue a move.
                % Immediately after clicking the toggle, its own lVal
                % property will change, changing its visual picture.  We
                % need to immediately invert it.
                %
                % The handleClock method will take care of making sure the
                % toggle shows the correct state based on the value of
                % lIsThere.
                
                
                %{
                % Pre 2014.11.19
                if this.uitPlay.lVal
                    this.moveToDest();
                else
                    this.stop();
                end
                %}
                
                % New 2014.11.19
                % Invert play button (need to set lInit property of UIT to
                % false first so it doesn't broadcast eChange when we
                % manually set lVal (that brodacast will get us in an
                % infinite loop with handleUI)
                
                this.uitPlay.lInit = false;
                this.uitPlay.lVal = ~this.uitPlay.lVal;
                
                if this.lIsThere
                    this.msg('handleUI lIsThere = true. moveToDest()');
                    this.moveToDest();
                else
                    this.msg('handleUI lIsThere = false. stop()');
                    this.stop();
                end

            elseif (src==this.uibSetup)
                this.setup.build();

            elseif (src==this.uitCal)
                this.updateDestUnits();
                % uitxPos will automatically change the next time the
                % value is refreshed
            elseif (src==this.uibIndex)
                this.index();

            end
            
            %Legacy : does not work on previous versions of matlab
            %        (switch works only for simple objects)
            %     switch src
            %         
            %         case this.uibStepPos
            %             this.stepPos();
            %             
            %         case this.uibStepNeg
            %             this.stepNeg();
            %             
            %         case this.uieDest
            %             % if there is an enter key press, move to destination
            %             if uint8(get(this.hParent,'CurrentCharacter')) == 13
            %                 this.moveToDest();
            %             end
            %             
            %         case this.uitPlay
            %             if this.uitPlay.lVal
            %                 this.moveToDest();
            %             else
            %                 this.stop();
            %             end
            %             
            %         case this.uibSetup
            %             this.as.build();
            %             
            %         case this.uitCal
            %             this.updateDestUnits();
            %             % uitxPos will automatically change the next time the
            %             % value is refreshed
            %         case this.uibIndex
            %             this.index();
            %             
            %     end
        end

        function handleCalibrationChange(this, ~, ~)
        %HANDLECALIBRATIONCHANGE Callback to handle change in RAW/Cal mode

            this.msg('HardwareIO.handleCalibrationChange()'); %TODO remove when finalized

            if this.uitCal.lVal

                % cal

                % need to update dMin, dMax, and val of uieDest since
                % raw2cal has changed.  For dest pos, set to motor pos set
                % dest to motor pos since there is no way to compute the
                % previous dest from current cal dest since cal2raw has
                % changed (slope has changed).

                if this.lActive
                    dPos = this.api.get();
                else
                    dPos = this.apiv.get();
                end

                % AxisSetup dispatches eCalibrationChange before updating
                % lowLimitCal and highLimitCal.  The reason is that when we
                % change units of uieDest, we need to set the new val, min,
                % and max at the same time.  If we set limits, then tried
                % to set value, dMax may be less than val and/or dMin may
                % be larger than dMin.  To get the calibrated limits,
                % convert lowLimitRaw to cal with raw2cal (raw2cal will use
                % updated slope and offset).  If you use lowLimitCal, this
                % will not have been updated.

                this.uieDest.setMinMaxVal( ...
                    this.setup.raw2cal(this.setup.uieLowLimitRaw.val()), ...
                    this.setup.raw2cal(this.setup.uieHighLimitRaw.val()), ...
                    this.setup.raw2cal(dPos) ...
                    );
            else
                % raw

                % do not need to update anything since raw values are not
                % affected by slope and offset
            end
        end

        function handleLowLimitChange(this, ~, ~)
        %HANDLELOWLIMITCHANGE Callback to deal with RAW/Cal mode
            this.msg('HardwareIO.handleLowLimitChange()'); %TODO remove when finalized

            % update dMin of uieDest
            if this.uitCal.lVal
                this.uieDest.setMin(this.setup.uieLowLimitCal.val());
            else
                this.uieDest.setMin(this.setup.uieLowLimitRaw.val());
            end  
        end

        function handleHighLimitChange(this, ~, ~)
        %HANDLEHIGHLIMITCHANGE Callback to deal with RAW/Cal mode
            this.msg('HardwareIO.handleHighLimitChange()'); %TODO remove when finalized

            % update dMax of uieDest
            if this.uitCal.lVal
                this.uieDest.setMax(this.setup.uieHighLimitCal.val());
            else
                this.uieDest.setMax(this.setup.uieHighLimitRaw.val());
            end   
        end

        function updateDestUnits(this)
        %UPDATEDESTUNITS Updates the position of the destination cal/raw
            if this.uitCal.lVal
                % was raw, should now be cal
                this.uieDest.setMinMaxVal( ...
                    this.setup.uieLowLimitCal.val(), ...
                    this.setup.uieHighLimitCal.val(), ...
                    this.setup.raw2cal(this.uieDest.val()) ...
                    );
            else
                % was cal, should now be raw
                this.uieDest.setMinMaxVal( ...
                    this.setup.uieLowLimitRaw.val(), ...
                    this.setup.uieHighLimitRaw.val(), ...
                    this.setup.cal2raw(this.uieDest.val()) ...
                    );
            end
        end
            % Because Axis can toggle units between cal and raw, uieDest.val()
            % can take on cal units or raw units.  If you want to set a
            % destination, you may want to do it in calibrated or raw units.  I
            % will build access for setting and retrieving cal or raw values


        function dOut = destCal(this)
        %DESTCAL Converts the dest position into cal units, if required
        %   HardwareIO.destCal() 
        
            if this.uitCal.lVal
                dOut = this.uieDest.val();
            else
                dOut = this.setup.raw2cal(this.uieDest.val());
            end
        end
        

        function dOut = destRaw(this)
        %DESTRAW Converts the dest position into RAW units, if required
        %   HardwareIO.destRAW()  
        
            if this.uitCal.lVal
                dOut = this.setup.cal2raw(this.uieDest.val());
            else
                dOut = this.uieDest.val();
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
            
            %{
            % UIButton (inefficient - set every clock cycle)
            if this.lReady
                this.uibtPlay.setU8Img(this.u8Play);
            else 
                this.uibtPlay.setU8Img(this.u8Pause);
            end
            %} 
            
            
            
            % LEGACY STUFF (USING  UITOGGLE)
            
            % if it is showing playing and should show stopped, flip the
            % play/pause button.

            % 2013.08.22: Instead of comparison, check to see if the
            % difference is less than something

            % Update the play/pause button based on isThere()

            %this.uitPlay.lInit = false;
            %this.uitPlay.lVal = this.lIsThere;

            %{ 
            % Legacy toggle
            if this.lIsThere && ~this.uitPlay.lVal
                this.uitPlay.lInit = false;
                this.uitPlay.lVal = true;
            end

            if ~this.lIsThere && this.uitPlay.lVal
                this.uitPlay.lInit = false;
                this.uitPlay.lVal = false;
            end
            %}

        end

    end

end %class
