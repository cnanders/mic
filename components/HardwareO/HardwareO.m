classdef HardwareO < HandlePlus
        
    % Hungarian: ho

    properties (Constant)
        dHeight = 24;   % height of the UIElement
        dWidth = 290;   % width of the UIElement
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
        apiv            % virtual API (for test and debugging).  Builds its own APIVHardwareIO
        api             % API to the low level controls.  Must be set after initialized.
    end

    properties (SetAccess = private)
        cName           % name identifier
        dValRaw         % CA 2014.05.01 added for quick access to value
        dValCal         % CA 2014.05.01 added for quick access to value
    end

    properties (Access = private)
        cDispName   % name to be displayed by the UI element
        cDir        % current directory

        uitxVal     % label to display the current value reading
        lActive     % boolean to tell whether the motor is active or not
        uitActive   % UIToggle button ;made private 6/20/13 (AW)
        uitCal      % UIToggle button to tell whether the reading is calibr
        uibSetup    % button that launches the setup menu
        uitxLabel   % label to displau the name of the element

        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff = [244 245 169]./255;
        dColorOn = [241 241 241]./255; 
        cl          % clock
    end
    

    events
    end

    
    methods        
        
        function this = HardwareO(cName, cl, cDispName)  
        
            
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
                'Position', MicUtils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent));
            drawnow
                        
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',MicUtils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'Visible', 'off');
            
            this.hImage = image(imread(fullfile(MicUtils.pathAssets(), 'HardwareO.png')));
            set(this.hImage, 'Parent', this.hAxes);
            % set(this.hImage, 'CData', imread(sprintf('%s../assets/HardwareO.png', this.cDir)));
            
            set(this.hAxes, 'Visible', 'off');
            
            
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
            this.uitxVal.build(hPanel, this.dWidth-12-36-36-18-75-75-6, 12+y_rel, 75, 12);
            this.uitxLabel.build(hPanel, 3, 12+y_rel, this.dWidth-12-36-36-18-75-75, 12);
            %}
            
            this.uitCal.build(this.hPanel, ...
                this.dWidth - 2*this.dHeight, ...
                0, ...
                this.dHeight, ...
                this.dHeight ...
            );
            this.uibSetup.build(this.hPanel, ...
                this.dWidth - this.dHeight, ...
                0, ...
                this.dHeight, ...
                this.dHeight ...
            );
            this.uitxVal.build(this.hPanel, this.dWidth-36-36-18-75-75-6, 6+y_rel, 75, 12);
            this.uitxLabel.build(this.hPanel, 3, 6+y_rel, this.dWidth-36-36-18-75-75, 12);
            
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

        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the h
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            set(this.hImage, 'Visible', 'off');
            
            % Kill the APIV
            if ~isempty(this.apiv)
                delete(this.apiv);
                this.apiv = [];
            end
            
        end
        
        
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareIO.turnOn()
        %
        % See also TURNON
        
            % Make sure APIV is available
            if isempty(this.apiv)
                this.apiv = APIVHardwareO(this.cName, this.cl);
            end
        
            this.lActive = false;
            set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
        end
        
        
        
        function set.apiv(this, value)
            if ~isempty(this.apiv)
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
                this.msg('Axis.delete() removing clock task', 7); 
                this.cl.remove(this.id());
            end

           
            % Need to delete because it has a timer that needs to be
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
            if ~isempty(this.uitxVal)
                delete(this.uitxVal)
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
                %AW 2019-9-9
                %TODO : this should be refactored in a readRaw function
                %see HardwareO for example
                %make sure diode etc have it also
                
                if this.lActive
                    this.dValRaw = this.api.get();
                else
                    this.dValRaw = this.apiv.get();
                end
                
                
                this.dValCal = this.setup.raw2cal(this.dValRaw);
                %endtodo
                
                % update uitxVal
                if this.uitCal.lVal
                    % cal
                    this.uitxVal.cVal = sprintf('%.3f', this.dValCal); %num2str(this.setup.raw2cal(dValRaw));                    
                else
                    % raw
                    this.uitxVal.cVal = sprintf('%.3f', this.dValRaw); % num2str(dValRaw);
                end
                
                
            catch err
                this.msg(getReport(err), 2);
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
    
    methods (Access = private)
        
         function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
            this.setup = SetupHardwareO(this.cName);
            addlistener(this.setup, 'eCalibrationChange', @this.handleCalibrationChange);
            addlistener(this.setup, 'eDelayChange', @this.handleDelayChange);
            
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
                imread(fullfile(MicUtils.pathAssets(), 'raw-24.png')), ...
                imread(fullfile(MicUtils.pathAssets(), 'cal-24.png')) ...
                );            

            %setup toggle button
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(fullfile(MicUtils.pathAssets(), 'settings-24.png')) ...
                );

            %value reading
            this.uitxVal = UIText('Value', 'right');

            % Name (on the left)
            this.uitxLabel = UIText(this.cDispName);

            % APIV (always build one in the beginning)
            
            stConfig = {};
            stConfig.cName = this.cName;
            stConfig.clock = this.cl;
            this.apiv = APIVHardwareO(stConfig);
            
            % Update the display value periodically
            this.cl.add(@this.handleClock, this.id(), this.setup.uieDelay.val());

            % event listeners
            addlistener(this.uitCal,    'eChange', @this.handleUI);
            addlistener(this.uibSetup,  'eChange', @this.handleUI);

         end
        

        function handleUI(this, src, evt)
        %HANDLEUI Callback for the User interface (uicontrols etc.)
        %   HardwareIO.handleUI(src,~)

            if (src==this.uibSetup)
                
                this.setup.build();

            elseif (src==this.uitCal)
                % uitxVal will automatically change the next time the
                % value is refreshed
            
            end            
        end
        
        function handleDelayChange(this, ~, ~)
           this.msg('handleDelayChange()', 3);
           
           % Remove task from clock, add new task with different delay
           
           if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.msg('Axis.delete() removing clock task', 7); 
                this.cl.remove(this.id());
           end
           
           fh = @this.handleClock;
           this.cl.add(fh, this.id(), this.setup.uieDelay.val());
           
        end
        
        
        function handleCalibrationChange(this, ~, ~)
            %HANDLECALIBRATIONCHANGE Callback to handle change in RAW/Cal mode

            this.msg('handleCalibrationChange()',7); 

            % Don't need to do anything.  The next cycle of handleClock()
            % will update the display value 
        
        end

    end

end %class
