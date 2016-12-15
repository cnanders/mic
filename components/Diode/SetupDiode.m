classdef SetupDiode < HandlePlus
    
    % DIODESETUP Class for setting Diode parameters
    %
    % example of use :
    %   diode = Diode('name', clock )creates an instance of the class
    %   diode.dsSetupbuild(parent,left,top) builds a UI control for this class
    %
    % See also DIODE, AXISSETUP, SETUPHARDWAREIO

    %% Properties

    properties (Constant)
        dHeight = 350; % width of the UIElement
        dWidth = 220;  % height of the UIElement
    end

    properties (Dependent = true)
    end

    properties
        
       uieDelay     % UIEdit text edit box for the refresh rate
       uipGain      % UIEdit text edit box for diode gain
       uieCal       % UIEdit text edit box for diode calibration
       uieArea      % UIEdit text edit box for diode area
       uieAreaRatio % UIEdit text edit box for area ration
       uieCycles    % UIEdit text edit box for the refresh rate

       cName        % name identifier
    end

    properties (SetAccess = private)
    end

    properties (Access = private)
        hFigure
        
        cSaveDir
        cDir            % class directory
    end

    events
        
        eCalibrationChange
        eDelayChange
        
    end 

    methods
        %% Constructuor

        function this = SetupDiode(cName)
        %DIODESETUP Class constructor
        % ds = DiodeSetup('name')
            this.cName = cName;
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.cSaveDir = sprintf('save/setup-diode');
            
            this.init();
        end

        %% Methods
        function init(this)
        %INIT Initializes the DiodeSetup Class (primarily used by the constructor)
        %   DiodeSetup.init()
        %
        % See Also BUILD, DELETE

            this.uieDelay =             UIEdit('Delay (s)', 'd');
            this.uipGain =              UIPopup({1 10 10^2 10^3 10^4 10^5 10^6 10^7 10^8 10^9 10^10}, 'Gain', true);
            this.uieCal =               UIEdit('Cal (uA/W)', 'd');
            this.uieArea =              UIEdit('Lit area (cm^2)', 'd');
            this.uieAreaRatio =         UIEdit('Area diode / area target', 'd');
            this.uieCycles =            UIEdit('Cycles', 'u16');


            % defaults
            this.uieDelay.setVal(0.3);
            this.uieCal.setVal(1000);
            this.uieArea.setVal(1);
            this.uieAreaRatio.setVal(1);
            this.uieCycles.setVal(uint16(20));
            
            addlistener(this.uieDelay, 'eChange', @this.handleDelayChange);
            
            this.load();
        end
        
        function handleDelayChange(this, src, evt)
            notify(this, 'eDelayChange');
        end

        function build(this)
        %BUILD Builds the UIElement corresponding to the DiodeSetup class
        % It builds itself in a separate panel.
        %   DiodeSetup.build() 
        %
        % See also INIT, DELETE
        
        
            if ishghandle(this.hFigure)
               this.closeRequestFcn();
               return;
            end

            dSep = 55;
            dTop = 10;
            dLeftCol1 = 20;
            dEditWidth = 150;


            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [100 100 this.dWidth this.dHeight],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );

            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([0 0 this.dWidth this.dHeight], this.hFigure) ...
            );
            drawnow;


            this.uieDelay.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dTop = dTop + dSep;

            this.uipGain.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dTop = dTop + dSep;

            this.uieCal.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dTop = dTop + dSep;

            this.uieArea.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dTop = dTop + dSep;

            this.uieAreaRatio.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dTop = dTop + dSep;

            this.uieCycles.build(hPanel, dLeftCol1, dTop, dEditWidth, MicUtils.dEDITHEIGHT);

        end


        function dAmps = volts2amps(this, dVolts)
        %VOLT2AMPS Computes amplitude the according to the set gain.
        %   dAmps = DiodeSetup.volts2amps(dVolts)
        %
        % See also VOLTS2MJPERCM2S
            dAmps = abs(dVolts)/this.uipGain.val();
        end


        function mjpercm2s = volts2mjpercm2s(this, dVolts)
        %VOLTS2MJPERCM2S Computes the lightflux impeding on the diode
        %   mjpercm2s = DiodeSetup.volts2mjpercm2s(dVolts)
        %
        % See also VOLT2AMPS
            % V = Volts (V)
            % R = Load resistor (ohm) (gain)
            % I = Current (uA)
            % C = Calibration (uA/W)
            % A = Area (cm2)

            % I (uA) = V/R*10^6
            % I/C => W or J/s
            % (I/C)*1000 => mW or mJ/s
            % (I/C)*1000/A => mJ/s/cm2

            % Added nAreaScaleFactor

            dMicroAmps = abs(dVolts)/this.uipGain.val()*10^6; % uA
            dW = dMicroAmps/this.uieCal.val(); % W
            mjpercm2s = dW*1000/this.uieArea.val()*this.uieAreaRatio.val();

        end


        %% Modifiers

        %% Event handlers
        function cb(this, src, ~)
        %CB Callback that (for now) shuts down the UIelement
            switch src
                case this.hFigure
                    this.closeRequestFcn();
            end
        end

        function closeRequestFcn(this)
        %CLOSEREQUESTFCN Callback that shuts down the UIElement
            
            % 2014.11.19 CNA adding saving before close
            this.save();
            delete(this.hFigure);
        end

        %% Destructor
        function delete(this)
        %DELETE Class destructor
        %   DiodeSetup.delete()

            this.msg('DiodeSetup.delete()');
        end

    end
    
    
    methods (Access = private)
        
        
        function load(this)
            
            this.msg('load()', 7);

            if exist(this.file(), 'file') ~= 0
                load(this.file()); % populates s in local workspace
                this.loadClassInstance(s); 
            end
            
            
        end
        
        function save(this)
            
            this.msg('save()', 7);
            
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
                                    
            % Save
            
            save(this.file(), 's');
                        
        end
        
        function cReturn = file(this)
            
            % Return the full path (including filename) of the .mat file to
            % save
            
            cFullDir = fullfile( ...
                this.cDir, ...
                '..', ...
                this.cSaveDir ...
            );
            
            
            this.checkDir(cFullDir);
            
            cReturn = fullfile(...
                cFullDir, ...
                [this.cName, '.mat'] ...
            );
            
        end
        
        %{
        function checkDir(this)
            
            % Check that the dir we want to save to exists.  Make if needed

            cFullDir = fullfile( ...
                this.cDir, ...
                '..', ...
                this.cSaveDir ...
            );
        
            if (~exist(cFullDir, 'dir'))
                mkdir(cFullDir);
            end
            
        end
        %}
        
        
    end
    
end
        
        
        