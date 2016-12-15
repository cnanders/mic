classdef Diode < HandlePlus
%DIODE  Class that allows reading a diode
%
% example of use
%   diode = diode('name', clock) creates an Axis with a name 'name'
%   diode.build(parent,top, left) build the UI equivalent for the class
%
% See also DIODESETUP, DIODEVIRTUAL, HARDWAREO
    
    %% Properties

    properties (Constant)
        dWidth = 290; % width of the UIElement
        dHeight = 24; % height of the UIElement
    end


    properties (SetAccess = private)
        
        cName       % name identifier
        dVolts              % read-only property updated in handleClock
        dAmps               % read-only property updated in handleClock
        dMjPerCm2s          % read-only property updated in handleClock
        cDispName
    end
   
    properties
        
        setup       % setup panel (DiodeSetup object)
        apiv
        api

    end

    properties (Access = private)
        
        cDir
        ceUnits = {'Volts' 'Amps' 'mJ/cm2'};
        
        clock
        lActive     % boolean to tell whether the motor is active or not
        uibSetup    % setup button
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        
        uipUnits    % popup menu
        uitxVal     % text 
        uitxLabel   % label
        
    end

    events
        eShutterClosed
    end

    methods
        
%% Constructor
        function this = Diode(cName, clock, cDispName)
        %DIODE  Class constructor
        %   diode = Didoe('name', clock)
        %
        % See also INIT, BUILD, DELETE
        
            if ~exist('cDispName', 'var')
                cDispName = cName; % ms
            end
            
            this.cName = cName;
            this.clock = clock;
            this.cDispName = cDispName;

            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));

            this.init();
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
                this.apiv = APIVHardwareO(this.cName, this.clock);
            end
        
            this.lActive = false;
            set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
        end
        
        

        

        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UIElement associated to the Diode
        %   Diode.build(hParent, dLeft, dTop)

            dPopupWidth = 100;
            dTextWidth = 75;

            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', MicUtils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
                );
            drawnow;
            
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
            % set(this.hImage, 'CData', imread(fullfile(MicUtils.pathAssets(), 'HardwareO.png')));
            
            axis('image');
            axis('off');
            
            %{
            this.uitActive.build(this.hPanel, ...
                this.dWidth-12, ...
                0, ...
                12, ...
                36);
            %}
            this.uibSetup.build(this.hPanel, ...
                this.dWidth - this.dHeight, ...
                0, ...
                this.dHeight, ...
                this.dHeight);
            this.uipUnits.build(this.hPanel, ...
                this.dWidth - this.dHeight - dPopupWidth, ...
                1, ...
                dPopupWidth, ...
                this.dHeight);
            this.uitxVal.build(this.hPanel, ...
                (this.dWidth - this.dHeight - dPopupWidth)/2, ...
                6, ...
                (this.dWidth - this.dHeight - dPopupWidth)/2, ...
                12);
            this.uitxLabel.build(this.hPanel, ...
                0, ...
                6, ...
                (this.dWidth - this.dHeight - dPopupWidth)/2, ...
                12);

        end

        %AW2013-7-16 : created a read function to refactor the handleClock:
        % There was no way but to wait for the next tick to get the value
        function dVal = read(this)
        %READ Reads the diode value
        %   dVal = Diode.read()
            try
                
                % 
                if this.lActive
                    % api
                    this.dVolts = this.api.get();
                else
                    % virtual
                    this.dVolts = this.apiv.get();
                end
                
                this.dAmps          = this.setup.volts2amps(this.dVolts);
                this.dMjPerCm2s     = this.setup.volts2mjpercm2s(this.dVolts);
                
                switch this.uipUnits.val()
                    case this.ceUnits{1}
                        % volts
                        dVal = this.dVolts;
                    case this.ceUnits{2}
                        % amps
                        dVal = this.dAmps;
                    case this.ceUnits{3}
                        % mj/cm2/s
                        dVal = this.dMjPerCm2s;
                end
            catch err
                this.msg(getReport(err),2);
            end
        end


        %AW2013-7-16 : Refactored the handleclock by creating a read function
        function handleClock(this)
        %HANDLECLOCK Callback used by the clock to update the reading
        %
        % See also CLOCK
            this.uitxVal.cVal = num2str(this.read());
        end
        
        function handleUI(this, src, ~)
        %HANDLEUI Callback that builds the DiodeSetup panel
        
        %     switch src
        %         case this.uibSetup
        %             this.setup.build();
        %     end
            if isequal(src,this.uibSetup)
                    this.setup.build();
            end
        end
        
        

        %% destructor
        function delete(this)
        %DELETE Class destuctor
        %   Diode.delete()

            
            % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end

            % Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.apiv)
                 delete(this.apiv);
            end
            
        end
        
               
        function set.apiv(this, value)
            if ~isempty(this.apiv)
                delete(this.apiv);
            end

            this.apiv = value;
        end
        
        


    end %methods
    
    
    methods (Access = private)
        
        function init(this)
        
            %{
            st1 = struct();
            st1.lAsk        = false;
            
            st2 = struct();
            st2.lAsk        = true;
            st2.cTitle      = 'Disable';
            st2.cQuestion   = 'Are you sure you want to disable the hardware?';
            st2.cAnswer1    = 'Yes';
            st2.cAnswer2    = 'Cancel';
            st2.cDefault    = st2.cAnswer2;
        
            this.uitActive = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                imread(fullfile(MicUtils.pathAssets(), 'controllernotactive.png')), ...
                imread(fullfile(MicUtils.pathAssets(), 'controlleractive.png')), ...
                st1, ...
                st2);
            %}
            
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(fullfile(MicUtils.pathAssets(), 'settings-24.png')) ...
                );

            addlistener(this.uibSetup, 'eChange', @this.handleUI);

            this.uipUnits = UIPopup(this.ceUnits, 'Units', false);
            this.uitxVal = UIText('Volts', 'right');
            this.uitxLabel = UIText(this.cDispName);
            
            stParams = {};
            stParams.cName = this.cName;
            stParams.clock = this.clock;
            
            this.apiv = APIVHardwareO(stParams);
            this.setup = SetupDiode(this.cName);
            addlistener(this.setup, 'eDelayChange', @this.handleDelayChange);

            % Update the display value periodically
            this.clock.add(@this.handleClock, this.id(), this.setup.uieDelay.val());
            
        end
        
        function handleDelayChange(this, ~, ~)
                      
           % Remove task from clock, add new task with different delay
           
           if isvalid(this.clock) && ...
               this.clock.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.clock.remove(this.id());
           end
           
           this.clock.add(@this.handleClock, this.id(), this.setup.uieDelay.val());
           
        end
        
        
    end
end %classdef