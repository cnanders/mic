classdef SetupHardwareIO < HandlePlus

    properties (Constant)
    end

    properties (Dependent = true)
    end

    properties
       uieDelay     % UIEdit thats sets the reading refresh time
       uieSlope     % UIEdit that sets the Slope for calibration
       uieOffset    % UIEdit that sets the offset for calibration
       uieStepCal   % UIEdit that defines the step size, in cal units
       uieStepRaw   % UIEdit that defines the step size, in raw units
       uieLowLimitCal   % UIEdit that defines the low limit in cal units
       uieLowLimitRaw   % UIEdit that defines the low limit in raw units
       uieHighLimitCal  % UIEdit that defines the high limit in cal units
       uieHighLimitRaw  % UIEdit that defines the high limit in raw units
       uieTolCal    % UIEdit that defines the positionning tolerance in cal
       uieTolRaw    % UIEdit that defines the positionning tolerance in raw
    end

    properties (SetAccess = private)
        cName   % name identifier // made private set since there is no setters available;-) 
        cScans  % scans (?) 
       
    end

    properties (Access = private)
        hFigure % handle to the UI element figure
        cSaveDir
        cDir            % class directory
        
    end

    events 
        eLowLimitChange
        eHighLimitChange
        eCalibrationChange
        eDelayChange
    end



    methods

        function this = SetupHardwareIO(cName)
        %SETUPHARDWAREIO Class constructor
        %   shio = SetupHardwareIO('name')
        %
        %   See also INIT, BUILD, DELETE
        
            % test
            this.cName = cName;
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.cSaveDir = sprintf('save/setup-hio');
            
            this.init();
        end

        %% methods

        function init(this)
        %INIT Initializes the class
        %   SetupHardwareIO.init()
        %
        % See also SETUPHARDWAREIO, BUILD, DELETE

            this.uieDelay =          UIEdit('Delay (s)', 'd');
            this.uieSlope =          UIEdit('Slope', 'd');
            this.uieOffset =         UIEdit('Offset (raw)', 'd');
            this.uieStepCal =        UIEdit('Step (cal)', 'd');
            this.uieStepRaw =        UIEdit('Step (raw)', 'd');
            this.uieLowLimitCal =    UIEdit('Low limit (cal)', 'd');
            this.uieLowLimitRaw =    UIEdit('Low limit (raw)', 'd');
            this.uieHighLimitCal =   UIEdit('High limit (cal)', 'd');
            this.uieHighLimitRaw =   UIEdit('High limit (raw)', 'd');
            this.uieTolCal =         UIEdit('Tol. (cal)', 'd');
            this.uieTolRaw =         UIEdit('Tol. (raw)', 'd');

            % When you enter a value into the MotorControl position, it
            % checks that it is > lowLimit and < highLimit

            % Set slope + offset so the raw2cal and cal2raw work.  Then add
            % listeners for all change events and set the step, low, and
            % high limits.

            this.uieDelay.setVal(100/1000);
            this.uieSlope.setVal(1);
            this.uieOffset.setVal(0);            

            % listeners
            addlistener(this.uieDelay, 'eChange', @this.handleDelay);
            addlistener(this.uieSlope, 'eChange', @this.handleSlope);
            addlistener(this.uieOffset, 'eChange', @this.handleOffset);
            addlistener(this.uieStepCal, 'eChange', @this.handleStepCal);
            addlistener(this.uieStepRaw, 'eChange', @this.handleStepRaw);
            addlistener(this.uieLowLimitCal, 'eChange', @this.handleLowLimitCal);
            addlistener(this.uieLowLimitRaw, 'eChange', @this.handleLowLimitRaw);
            addlistener(this.uieHighLimitCal, 'eChange', @this.handleHighLimitCal);
            addlistener(this.uieHighLimitRaw, 'eChange', @this.handleHighLimitRaw);
            addlistener(this.uieTolCal, 'eChange', @this.handleTolCal);
            addlistener(this.uieTolRaw, 'eChange', @this.handleTolRaw);

            % limits
            %FIXME danger zone ! do not allocate sucha  high number instead of a limit
            %AW(5/24/13) : changed the default values to double type max
            this.uieStepCal.setVal(0.5);
            this.uieLowLimitCal.setVal(-10^100); %googol should be enough
            this.uieHighLimitCal.setVal(10^100);
            this.uieTolCal.setVal(0.001);
            
            this.load();
        end


        function build(this)
        %BUILD Builds in a seperate window the associated UI element.
        %   SetupHardwareIO.build()
        %
        % See also 
        
            if ishghandle(this.hFigure)
               this.closeRequestFcn();
               return;
            end

            dPanelLeft = 10;
            dPanelWidth = 200;

            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;

            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [100 100 220 510],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );


            % Delay panel
            
            dFigureTop = 10;
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Update rate',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + MicUtils.panelHeight(1) + MicUtils.dEditPad; % bottom edge of delay panel
            
            
            dPanelTop = MicUtils.dPanelTopPad;
            this.uieDelay.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);

            % Calibration           
            dTextHeight = 20;
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Calibration',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1) + dTextHeight], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + MicUtils.panelHeight(1) + MicUtils.dEditPad + dTextHeight;

            hText = uicontrol(...
                'Parent', hPanel , ...
                'HorizontalAlignment', 'left', ...
                'Position', MicUtils.lt2lb([dLeftCol1, dPanelTop, 150, dTextHeight], hPanel), ...
                'String', 'cal = slope*(raw - offset)', ...
                'Style', 'text' ...
                );
            
            dPanelTop = MicUtils.dPanelTopPad + dTextHeight;
            this.uieSlope.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieOffset.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);


            % Step
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Step (+/- buttons)',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + MicUtils.panelHeight(1) + MicUtils.dEditPad;
            
            dPanelTop = MicUtils.dPanelTopPad;
            this.uieStepCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieStepRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);


            % Software Limits
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '(Software) motion limits',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(2)], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + MicUtils.panelHeight(2) + MicUtils.dEditPad;
            
            dPanelTop = MicUtils.dPanelTopPad;
            this.uieLowLimitCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieLowLimitRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);

            dPanelTop = dPanelTop + MicUtils.dEDITHEIGHT + MicUtils.dEditPad;
            this.uieHighLimitCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieHighLimitRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);

            % "Is There?" Tol
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '"Is There?" Tolerance',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
            drawnow;
            
            dPanelTop = MicUtils.dPanelTopPad;
            this.uieTolCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieTolRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            

        end

        function calibration(this, dSlope, dOffset)
        %CALIBRATION Sets the calibration properties
        %   AxisSetup.calibration(dSlope, dOffset) 

            this.uieSlope.setVal(dSlope);
            this.uieOffset.setVal(dOffset);
        end

        function limitsCal(this, dLowLimitCal, dHighLimitCal)
        %LIMITSCAL Sets the hi-lo limits in calibrated units
        %   AxisSetup.limitsCal(dLowLimitCal, dHighLimitCal) 
        %   
        % See also LIMITSRAW
        
            this.uie.LowLimitCal.setVal(dLowLimitCal);
            this.uie.HighLimitCal.setVal(dHighLimitCal);
        end

        function limitsRaw(this, dLowLimitRaw, dHighLimitRaw)
        %LIMITSRAW   sets the hi-lo limits in Raw units
        %    AxisSetup.limitsRaw(dLowLimitRaw, dHighLimitRaw) 
        %
        % See also LIMITSCAL

            this.uieLowLimitRaw.setVal(dLowLimitRaw);
            this.uieHighLimitRaw.setVal(dHighLimitRaw);
        end



        function out = cal2raw(this, dCal)
        %CAL2RAW Translates the reading from calibrated units to raw units
        %   raw = SetupHardwareIO.cal2raw(cal)
        %
        % See also RAW2CAL
        
            % cal = slope*(raw - offset)
            % out = int16(dCal/this.uieSlope.val() + this.uieOffset.val());
            out = dCal/this.uieSlope.val() + this.uieOffset.val();

        end

        function out = raw2cal(this, dRaw)
        %RAW2CAL Translates the reading from raw units to calibrated units
        %   cal = SetupHardwareIO.raw2cal(raw)
        %
        % See also CAL2RAW
        
            % cal = slope*(raw - offset)
            % out = this.uieSlope.val()*double(dRaw - this.uieOffset.val());
            out = this.uieSlope.val()*(dRaw - this.uieOffset.val());

        end
        
        function delete(this)
        %DELETE Class destructor
        %   SetupHardwareIO.delete()
        %
        % See also SETUPHARDWAREIO, INIT, BUILD
        
        %AW(5/24/13): added deletion of all ui elements; it seems that some
        %remains in memory, what causes trouble sometimes.

            if ~isempty(this.uieDelay)
                delete(this.uieDelay)
            end
            if ~isempty(this.uieSlope)
                delete(this.uieSlope)
            end
            if ~isempty(this.uieOffset)
                delete(this.uieOffset)
            end
            if ~isempty(this.uieStepCal)
                delete(this.uieStepCal)
            end
            if ~isempty(this.uieStepRaw)
                delete(this.uieStepRaw)
            end    
            if ~isempty(this.uieLowLimitCal)
                delete(this.uieLowLimitCal)
            end
            if ~isempty(this.uieLowLimitRaw)
                delete(this.uieLowLimitRaw)
            end
            if ~isempty(this.uieHighLimitCal)
                delete(this.uieHighLimitCal)
            end
            if ~isempty(this.uieHighLimitRaw)
                delete(this.uieHighLimitRaw)
            end
            if ~isempty(this.uieTolCal)
                delete(this.uieTolCal)
            end
            if ~isempty(this.uieTolRaw)
                delete(this.uieTolRaw)
            end
        end

    end %methods
    
    methods(Hidden)

        function handleDelay(this, src, evt)
            notify(this,'eDelayChange');
        end
        
        function handleSlope(this, src, evt)
            notify(this,'eCalibrationChange');
            this.updateCalVals();
        end
        
        function handleOffset(this, src, evt)
            notify(this,'eCalibrationChange');
            this.updateCalVals(); 
        end
        
        function handleStepCal(this, src, evt)
            % step is not affected by offset
            this.uieStepRaw.setVal(this.uieStepCal.val()/this.uieSlope.val());

        end
        
        function handleStepRaw(this, src, evt)
            % step is not affected by offset
            this.uieStepCal.setVal(this.uieStepRaw.val()*this.uieSlope.val());

        end
        
        function handleLowLimitCal(this, src, evt)
             % update raw
            this.uieLowLimitRaw.setVal(this.cal2raw(src.val()));
            notify(this,'eLowLimitChange');
        end
        
        function handleLowLimitRaw(this, src, evt)
            % update cal
            this.uieLowLimitCal.setVal(this.raw2cal(src.val()));
            notify(this,'eLowLimitChange');
        end
        
        function handleHighLimitCal(this, src, evt)
            % update raw
            this.uieHighLimitRaw.setVal(this.cal2raw(src.val()));
            notify(this,'eHighLimitChange');
        end
        
        function handleHighLimitRaw(this, src, evt)
             % upcate cal
            this.uieHighLimitCal.setVal(this.raw2cal(src.val()));
            notify(this,'eHighLimitChange');
        end
        
        function handleTolCal(this, src, evt)
            % tol is not affected by offset
            this.uieTolRaw.setVal(src.val()/this.uieSlope.val());

        end
        
        function handleTolRaw(this, src, evt)
        	this.uieTolCal.setVal(src.val()*this.uieSlope.val());
        end
        
        function updateCalVals(this)
            % need to update all cal values
            % step not affected by offset

            % old
            % this.uieStepCal.setVal(double(this.uieStepRaw.val())*this.uieSlope.val());
            this.uieStepCal.setVal(this.uieStepRaw.val()*this.uieSlope.val());

            % tol not affected by offset

            % old
            % this.uieTolCal.setVal(double(this.uieTolRaw.val())*this.uieSlope.val());
            this.uieTolCal.setVal(this.uieTolRaw.val()*this.uieSlope.val());

            this.uieLowLimitCal.setVal(this.raw2cal(this.uieLowLimitRaw.val()));
            this.uieHighLimitCal.setVal(this.raw2cal(this.uieHighLimitRaw.val()));
        end
        

        function cb(this, src, evt)
            switch src
                case this.hFigure
                    this.closeRequestFcn(); %TODO : aski it to do something
            end
        end
        
        
        function closeRequestFcn(this)
            this.msg('AxisSetup.closeRequestFcn()', 9); %TODO remove when finalized
            % 2014.11.19 CNA Save before closing
            this.save();
            delete(this.hFigure);
        end
        
        
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
            
            this.checkDir();
            cReturn = fullfile( ...
                this.cDir, ...
                '..', ...
                this.cSaveDir, ...
                [this.cName, '.mat'] ...
            );
            
        end
        
        
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
        
    
    %%Legacy
     %AW6/25/13 Rollback !
        %AW6/20/13 : added modifiers for the calibration so that the call form
        %outside is not done to the UI elements directly.
        % data validation is done through the use of UIEdit
        % function dDelay = get.dDelay(this)
        %     dDelay = this.uieDelay.val();
        % end
        % 
        % function set.dDelay(this, value)
        %     this.uieDelay.setVal(value);
        % end
        % 
        % function dSlope = get.dSlope(this)
        %     dSlope = this.uieSlope.val();
        % end
        % 
        % function set.dSlope(this, value)
        %     this.uieSlope.setVal(value);
        % end
        % 
        % function dOffset = get.dOffset(this)
        %     dOffset = this.uieOffset.val();
        % end
        % 
        % function set.dOffset(this, value)
        %     this.uieOffset.setVal(value);
        % end
        %    
        % function dStepCal = get.dStepCal(this)
        %     dStepCal = this.uieStepCal.val();
        % end
        % 
        % function set.dStepCal(this, value)
        %     this.uieStepCal.setVal(value);
        % end
        %    
        % function dStepRaw = get.dStepRaw(this)
        %     dStepRaw = this.uieStepRaw.val();
        % end
        % 
        % function set.dStepRaw(this, value)
        %     this.uieStepRaw.setVal(value);
        % end
        % 
        % function dLowLimitCal= get.dLowLimitCal(this)
        %     dLowLimitCal = this.uieLowLimitCal.val();
        % end
        % 
        % function set.dLowLimitCal(this, value)
        %     this.uieLowLimitCal.setVal(value);
        % end
        %    
        % function dLowLimitRaw= get.dLowLimitRaw(this)
        %     dLowLimitRaw = this.uieLowLimitRaw.val();
        % end
        % 
        % function set.dLowLimitRaw(this, value)
        %     this.uieLowLimitRaw.setVal(value);
        % end
        % 
        % function dHighLimitCal= get.dHighLimitCal(this)
        %     dHighLimitCal = this.uieHighLimitCal.val();
        % end
        % 
        % function set.dHighLimitCal(this, value)
        %     this.uieHighLimitCal.setVal(value);
        % end
        %    
        % function dHighLimitRaw= get.dHighLimitRaw(this)
        %     dHighLimitRaw = this.uieHighLimitRaw.val();
        % end
        % 
        % function set.dHighLimitRaw(this, value)
        %     this.uieHighLimitRaw.setVal(value);
        % end
        % 
        % function dTolCal= get.dTolCal(this)
        %     dTolCal = this.uieTolCal.val();
        % end
        % 
        % function set.dTolCal(this, value)
        %     this.uieTolCal.setVal(value);
        % end
        % 
        % function dTolRaw= get.dTolRaw(this)
        %     dTolRaw = this.uieTolRaw.val();
        % end
        % 
        % function set.dTolRaw(this, value)
        %     this.uieTolRaw.setVal(value);
        % end

    end

end


