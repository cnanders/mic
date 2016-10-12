classdef GlobalHardwareIO < HandlePlus
    
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
        
        dDelay = 0.1;   % Delay for isThere update.
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
        lIsThere
        lActive     % boolean to tell whether the motor is active or not
    end
    
    properties (Access = protected)
        
        cl          % clock
        cDispName   % name to be displayed by the UI element
        cDir        % current directory

        uibtPlay    % UIToggle to start motion to the desired value
        uitxLabel   % label to displau the name of the element

        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [144 145 169]./255;
        dColorOn    = [141 141 241]./255;
        
        lReady

    end
    
    
    events
        
        
    end
    
    
    methods
        
        function this = GlobalHardwareIO(cName, cl, cDispName)
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
            
            this.hImage = image(imread(sprintf('%s../assets/HardwareIO.png', this.cDir)));
            set(this.hImage, 'Parent', this.hAxes);
            % set(this.hImage, 'CData', imread(sprintf('%s../assets/HardwareIO.png', this.cDir)));
            
            axis('image');
            axis('off');
            
            y_rel = -1;
 
           

            % this.uitPlay.build(this.hPanel, this.dWidth - 36 - 36, 0+y_rel + 1, 36, 36);
            this.uibtPlay.build(this.hPanel, this.dWidth - 36 - 36, 0+y_rel + 1, 36, 36);


            this.uitxLabel.build(this.hPanel, ...
                3, ...
                12 + y_rel, ...
                this.dWidth-36-36-18-75-75-3, ...
                12);
            
        end
        
        function lReadyVal = get.lReady(this)
            if this.lActive
                this.lReady = this.api.isReady();
            else
                this.lReady = this.apiv.isReady();
            end
            lReadyVal = this.lReady;
        end
        
        
        function moveToDest(this)
            %MOVETODEST Performs the HIO motion to the destination
            %   HardwareIO.moveToDest()
            %
            %   See also SETDESTCAL, SETDESTRAW, MOVE
            
            
            this.lIsThere = false;
            
            if this.lActive
                % Device
                this.api.set();
            else
                this.apiv.set();
            end
        end
        
        
        
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
            %TURNON Turns the motor on, actually using the API to control the h
            %   HardwareIO.turnOn()
            %
            % See also TURNOFF
            
            this.lActive = true;
            
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            set(this.hImage, 'Visible', 'off');
            
            
            
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
            
            
            if ~isempty(this.uitPlay)
                delete(this.uitPlay)
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
                
                % 2013.08.22: Instead of comparison, check to see if the
                % difference is less than something
                  
                %{
                if this.lIsThere && this.uitPlay.lVal
                % if (abs(this.destRaw - this.dValRaw) <= this.setup.uieTolRaw.val()) & this.uitPlay.lVal
                    % switch toggle off (show play button)
                    this.uitPlay.lVal = false;
                end
                %}
                
                
                if this.lActive
                    this.lReady = this.api.isReady();
                else
                    this.lReady = this.apiv.isReady();
                end
                
                this.updatePlayButton()
                

%                 if this.lActive
%                     this.lIsThere = this.api.isReady();
%                 else
%                     this.lIsThere = this.apiv.isReady();
%                 end
%                 
%                 if this.lIsThere && ~this.uibtPlay.lVal
%                     this.uibtPlay.lVal = true;
%                 end
%                 
%                 if ~this.lIsThere && this.uibtPlay.lVal
%                     this.uibtPlay.lVal = false;
%                 end
                
            catch err
                this.msg(getReport(err));
                
            end %try/catch
            
        end
        
    end %methods
    
    methods (Access = protected)
        
        
        function init(this)
            %INIT Initializes the class
            %   HardwareIO.init()
            %
            % See also HARDWAREIO, INIT, BUILD
            this.setup = SetupHardwareIO(this.cName);
            

            %GoTo button
            this.uibtPlay = UIButtonToggle( ...
                'play', ... % stopped
                'stop', ... % moving
                true, ...
                this.u8Play, ...
                this.u8Pause ...
                );

            % Name (on the left)
            this.uitxLabel = UIText(this.cDispName);
            

            addlistener(this.uibtPlay, 'eChange', @this.handleUI);

%             % Add call to clock:
%             fh = @this.handleClock;
%             this.cl.add(fh, this.id(), this.dDelay);
%             
%             addlistener(this.uibtPlay,   'eChange', @this.handleUI);
            
        end
        
        
        
        function handleUI(this, src, evt)
            %HANDLEUI Callback for the User interface (uicontrols etc.)
            %   HardwareIO.handleUI(src,~)
            
            

            if (src==this.uibtPlay)
                
                % Ready means it isn't moving
                
                if this.lReady
                    this.msg('handleUI lReady = true. moveToDest()');
                    this.moveToDest();
                else
                    this.msg('handleUI lReady = false. stop()');
                    this.stop();
                end
                

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

       
    end
    
    
end %class
