classdef GetSetLogical < mic.Base

    % mic.ui.common.Toggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device api,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
                
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidthBtn = 24;
        
        cTooltipApiOff = 'Connect to the real API';
        cTooltipApiOn = 'Disconnect the real API (go into virtual mode)';
        
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
    end

    properties (SetAccess = private)
        cName   % name identifier
        cLabel = 'Fix me'
        lVal = false   % boolean status of device
        lActive     % boolean to tell whether the motor is active or not
    end

    properties (Access = protected)
        
        % {logical 1x1} show the API toggle on the left
        lShowApi = true
        
        % {logical 1x1} show the label 
        lShowLabel = true
        
        % {logical 1x1} show value with mic.ui.common.ImageLogical
        lShowValue = true
        
        dWidthLabel = 100
        dWidthToggle = 100
        dWidth = 290
        
        % {uint8 24x24} image when device.get() returns true
        u8ImgTrue = imread(fullfile(mic.Utils.pathAssets(), 'hiot-true-24.png'));
       
        % {uint8 24x24} image when device.get() returns false
        u8ImgFalse = imread(fullfile(mic.Utils.pathAssets(), 'hiot-false-24.png'));
        
        % {uint8 24x24} images for Api toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-true.png'));
        u8ToggleOff = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-false-yellow.png'));

        
        % { < mic.interface.device.GetSetLogical 1x1}  
        % Can be set after initialized or passed in
        api             
        
        % { < mic.interface.device.GetSetLogical 1x1}
        % Builds its own
        apiv
                
        % {cell of X 1xm} - varargin list of arguments for instantiating
        % the mic.ui.common.Toggle instance.  To pass it into the
        % mic.ui.common.Toggle, need to use the {:} syntax
        % http://stackoverflow.com/questions/12558819/matlab-pass-varargin-to-a-function-accepting-variable-number-of-arguments
        ceVararginToggle = {}
        
           
        % {mic.Clock 1x1} must be provided in constructor
        clock        
        dPeriod = 1
        
        
        hPanel      % panel container for the UI element
        
        % {mic.ui.common.Toggle 1x1} issues set() commands to device
        % whenever the user clicks it
        uitCommand
        
        % {mic.ui.common.Text 1x1} for the label
        uitxLabel
        
        % {mic.ui.common.Toggle 1x1} toggle for the API
        uitApi
           
        % {mic.ui.commin.ImageLogical 1x1} visual state
        uiilValue
               
                        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = GetSetLogical(varargin)
    
            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
             
            this.init()            
        end
        
                
        function build(this, hParent, dLeft, dTop)
          
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop this.getWidth() this.dHeight], hParent) ...
            );
            drawnow
            
            dLeft = 0;
            dTop = 0;
            
            if this.lShowApi
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);            
                dLeft = dLeft + this.dWidthBtn + 5;
            end
            
            if this.lShowLabel
                this.uitxLabel.build(this.hPanel, ...
                    dLeft, ...
                    6, ...
                    this.dWidthLabel, ...
                    12 ...
                );
                dLeft = dLeft + this.dWidthLabel;
            end
            
            if this.lShowValue
                this.uiilValue.build(this.hPanel, ...
                    dLeft, ...
                    0 ...
                );
                dLeft = dLeft + this.dWidthBtn;
            end
                         
            this.uitCommand.build(this.hPanel, ...
                dLeft, ...
                0, ...
                this.dWidthToggle, ...
                this.dHeight ...
            );
                        
            
        end

        
        
        %{
        % Expose the set command of the Api
        % @param {logical 1x1} 
        function set(this, l)
           this.getApi().set(l);
           
        end
        %}

           
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitApi.lVal = true;
            this.uitApi.setTooltip(this.cTooltipApiOn);
            
            
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
                this.apiv = this.newApiv();
            end
            
            this.lActive = false;
            this.uitApi.lVal = false;
            this.uitApi.setTooltip(this.cTooltipApiOff);
            
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
                    
        function api = newApiv(this)
            api = mic.device.GetSetLogical();
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowApi
               dOut = dOut + this.dWidthBtn;
            end
            
            if this.lShowLabel
                dOut = dOut + this.dWidthLabel;
            end
            
            if this.lShowValue
               dOut = dOut + this.dWidthBtn;
            end

            dOut = dOut + this.dWidthToggle;
            dOut = dOut + 5;
                        
        end
        
        function init(this)
            
            
            this.uitxLabel = mic.ui.common.Text('cVal', this.cLabel);
                        
            this.initCommandToggle();
            this.initApiToggle();
            this.initValueImageLogical();
                                       
            this.apiv = this.newApiv();
            this.clock.add(@this.onClock, this.id(), this.dPeriod);
            
        end
        
        function initValueImageLogical(this)
            
            this.uiilValue = mic.ui.common.ImageLogical(...
                'u8ImgTrue', this.u8ImgTrue, ...
                'u8ImgFalse', this.u8ImgFalse ...
            );
            
        end
        
        function initCommandToggle(this)
            
            % Need to expand cell array ceVararginToggle into comma-separated
            % list using the {:} syntax
            
            this.uitCommand = mic.ui.common.Toggle(this.ceVararginToggle{:});
            addlistener(this.uitCommand, 'eChange', @this.onCommandChange);
            
        end
        
        
        % API toggle on the left
        function initApiToggle(this)
            
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
                'u8ImgOff', this.u8ToggleOff, ...
                'u8ImgOn', this.u8ToggleOn, ...
                'stF2TOptions', st1, ...
                'stT2FOptions', st2 ...
            );
            addlistener(this.uitApi,   'eChange', @this.onApiChange);
            
            
        end
        
        function onClock(this) 
           
            try
                this.lVal = this.getApi().get();
                
                % Force the toggle back to the current state without it
                % notifying eChange
                
                this.uitCommand.setValWithoutNotification(this.lVal);
                
                this.uiilValue.setVal(this.lVal);
                                               
            catch err
                this.msg(getReport(err));
            end 

        end
        
        %{
        function set.apiv(this, value)
            
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
            end

            this.apiv = value;
            
        end
        %}
        
        function onCommandChange(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click.  The toggle just issues set() commands.  It
            % doesn't do anything smart to show the value, this is handled
            % by the indicator image with each onClock()
            
            this.getApi().set(this.uitCommand.lVal);            
                        
        end
        
        function onApiChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
    end

end %class
