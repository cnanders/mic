classdef HardwareIOToggle < HandlePlus

    % UIToggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device api,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
    
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidth = 290;   % width of the UIElement
        dWidthBtn = 24;
        
        cTooltipAPIOff = 'Connect to the real API / hardware';
        cTooltipAPIOn = 'Disconnect the real API / hardware (go into virtual mode)';
        
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
    end

    properties (SetAccess = private)
        cName   % name identifier
        cLabel
        lVal    % boolean status of device
        lActive     % boolean to tell whether the motor is active or not
    end

    properties (Access = protected)
        
        lShowAPI
        dWidthLabel
        dWidthToggle
        api             % API to the low level controls.  Must be set after initialized.
        apiv            % virtual API (for test and debugging).  Builds its own APIVHardwareIO
        uitAPI
        stUitParams
        
        clock        % clock 
        cDir        % current directory
        dPeriod
        
        hPanel      % panel container for the UI element
        
        uitCommand
        uitxLabel
        
        hAxes       % container for UI images
        hImage
        
        % Need a hggroup to store all of the image handles.  For some
        % reason the axes didn't work for this
        
        hStatusAxes
        hImageGroup
        hImageActiveTrue
        hImageActiveFalse
        hImageInactiveTrue
        hImageInactiveFalse
        
        u8ImgOff
        u8ImgOn
        stF2TOptions
        stT2FOptions
        
        u8Active
        u8Inactive
                        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = HardwareIOToggle(stParams)
    
        %@param {struct 1x1} stParams - configuration params 
        %@param {char 1xm} stParams.cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        %@param {clock 1x1} stParams.clock - the clock
        %@param {char 1x1} stParams.cLabel - the label in the GUI
        %@param {struct 1x1} [stParams.stUitParams = ] - parameters for
        %   configuring the UIToggle instance
        %@param {logical 1x1} [stParams.lShowAPI = true] - show the
        %   clickable toggle / status that shows if is using real API or
        %   virtual API
        %@param {double 1x1} [stParams.dWidthToggle = 100] - the width of
        %   the toggle
        %@param {double 1x1} [stParams.dWidthLabel = 100] - the width of
        %   the label
        
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
    
            
            % Default params
            stDefault = struct();
            stDefault.dPeriod = 0.1;
            stDefault.lShowAPI = true;
            stDefault.dWidthLabel = 100;
            stDefault.dWidthToggle = 100;
            
            stDefault.stUitParams = struct();
            stDefault.stUitParams.cTextOff = 'Off';
            stDefault.stUitParams.cTextOn = 'On';
            stDefault.stUitParams.lImg = false;
            
            stDefault.stUitParams.u8ImgOff = imread(fullfile(...
                this.cDir, ...
                '..', ... % sprintf('..%s', filesep), ...
                '..', ... % sprintf('..%s', filesep), ...
                'assets', ...
                'axis-play-24.png' ...
            ));
            
            
            stDefault.stUitParams.u8ImgOn = imread(fullfile(...
                this.cDir, ...
                sprintf('..%s', filesep), ...
                sprintf('..%s', filesep), ...
                'assets', ...
                'axis-pause-24.png' ...
            ));
            stDefault.stUitParams.stF2TOptions = struct();
            stDefault.stUitParams.stF2TOptions.lAsk = false;
            stDefault.stUitParams.stT2FOptions = struct();
            stDefault.stUitParams.stT2FOptions.lAsk = false;
            
            % Merge defaults
            stParams = mergestruct(stDefault, stParams);

           
            % Assign params to properties
            ceNames = fieldnames(stParams);
            for k = 1:length(ceNames)
                this.(ceNames{k}) = stParams.(ceNames{k});
            end
               
                        
            this.uitCommand = UIToggle( ...
                this.stUitParams.cTextOff, ...
                this.stUitParams.cTextOn, ...
                this.stUitParams.lImg, ...
                this.stUitParams.u8ImgOff, ...
                this.stUitParams.u8ImgOn, ...
                this.stUitParams.stF2TOptions, ...
                this.stUitParams.stT2FOptions);
            
            addlistener(this.uitCommand, 'eChange', @this.onCommandChange);
            
            this.uitxLabel = UIText(this.cLabel);
            
            
            % API toggle on the left
            
            this.u8Active = imread(fullfile(...
                this.cDir, ...
                sprintf('..%s', filesep), ...
                sprintf('..%s', filesep), ...
                'assets', ...
                'hiot-true-24.png' ...
            ));
            
            
            
            this.u8Inactive = imread(fullfile(...
                this.cDir, ...
                sprintf('..%s', filesep), ...
                sprintf('..%s', filesep), ...
                'assets', ...
                'hiot-false-24.png' ...
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
            
            
            addlistener(this.uitAPI,   'eChange', @this.onAPIChange);
            
            
            
            this.apiv = this.newAPIV();
            this.clock.add(@this.handleClock, this.id(), this.dPeriod);
            
        end

        function onAPIChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        function build(this, hParent, dLeft, dTop)
          
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', MicUtils.lt2lb([dLeft dTop this.getWidth() this.dHeight], hParent));
            drawnow
            
            dLeft = 0;
            dTop = 0;
            
            if this.lShowAPI
                this.uitAPI.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);            
                dLeft = dLeft + this.dWidthBtn + 5;
            end
            
            this.uitxLabel.build(this.hPanel, ...
                dLeft, ...
                6, ...
                this.dWidthLabel, ...
                12 ...
            );
             
            dLeft = dLeft + this.dWidthLabel;
                         
            this.uitCommand.build(this.hPanel, ...
                dLeft, ...
                0, ...
                this.dWidthToggle, ...
                this.dHeight);
                        
            
        end

        
        function onCommandChange(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click.  The toggle just issues set() commands.  It
            % doesn't do anything smart to show the value, this is handled
            % by the indicator image with each handleClock()
            
            this.getApi().set(this.uitCommand.lVal);            
                        
        end 
        
        % Expose the set command of the Api
        % @param {logical 1x1} 
        function set(this, l)
           this.getApi().set(l);
           
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
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.clock.remove(this.id());
            end

            
            % av.  Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.apiv)
                 delete(this.apiv);
            end

            % delete(this.setup);
            % setup ?

            if ~isempty(this.uitCommand)
                delete(this.uitCommand)
            end
            
        end
        
        function handleClock(this) 
           
            try
                this.lVal = this.getApi().get();
                this.uitCommand.setValWithoutNotification(this.lVal);
                
                % FIXME: Need to update visual status
                                               
            catch err
                this.msg(getReport(err));
                 
            end 

        end
        
        function setApi(this, api)
            this.api = api;
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
            
        
        
        function api = newAPIV(this)
        %@return {APIVHardwareIO}
            
            st = struct();
            st.cName = sprintf('%s-apiv', this.cName);
            api = APIVHardwareIOToggle(st);
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowAPI
               dOut = dOut + this.dWidthBtn;
            end

            dOut = dOut + this.dWidthLabel;
            dOut = dOut + this.dWidthToggle;
            dOut = dOut + 5;
            
            
            
        end
    end

end %class
