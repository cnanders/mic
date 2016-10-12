classdef SetupHardwareO < HandlePlus

    properties (Constant)
    end

    properties (Dependent = true)
    end

    properties
       uieDelay         % UIEdit thats sets the reading refresh time
       uieSlope         % UIEdit that sets the Slope for calibration
       uieOffset        % UIEdit that sets the offset for calibration
    end

    properties (SetAccess = private)
        cName   % name identifier // made private set since there is no setters available;-) 
       
        
        
        
    end

    properties (Access = private)
         hFigure % handle to the UI element figure
         cSaveDir
         cDir            % class directory
    end

    events
        eCalibrationChange
        eDelayChange
    end



    methods

        function this = SetupHardwareO(cName)
        %SETUPHARDWAREIO Class constructor
        %   shio = SetupHardwareIO('name')
        %
        %   See also INIT, BUILD, DELETE
        
            % test
            this.cName = cName;
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.cSaveDir = sprintf('save/setup-ho');                        
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
            

            % When you enter a value into the MotorControl position, it
            % checks that it is > lowLimit and < highLimit

            % Set slope + offset so the raw2cal and cal2raw work.  Then add
            % listeners for all change events and set the step, low, and
            % high limits.

            this.uieDelay.setVal(500/1000);
            this.uieSlope.setVal(1);
            this.uieOffset.setVal(0);            

            % listeners
            addlistener(this.uieDelay, 'eChange', @this.handleUI);
            addlistener(this.uieSlope, 'eChange', @this.handleUI);
            addlistener(this.uieOffset, 'eChange', @this.handleUI);
            
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
                'Position', [100 100 220 204],... % left bottom width height
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
                'Position', Utils.lt2lb([dPanelLeft dFigureTop dPanelWidth Utils.panelHeight(1)], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + Utils.panelHeight(1) + Utils.dEditPad; % bottom edge of delay panel
            
            
            dPanelTop = Utils.dPanelTopPad;
            this.uieDelay.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, Utils.dEDITHEIGHT);

            % Calibration panel          
            dTextHeight = 20;
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Calibration',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dPanelLeft dFigureTop dPanelWidth Utils.panelHeight(1) + dTextHeight], this.hFigure) ...
            );
            drawnow;
            dFigureTop = dFigureTop + Utils.panelHeight(1) + Utils.dEditPad + dTextHeight;

            hText = uicontrol(...
                'Parent', hPanel , ...
                'HorizontalAlignment', 'left', ...
                'Position', Utils.lt2lb([dLeftCol1, dPanelTop, 150, dTextHeight], hPanel), ...
                'String', 'cal = slope*(raw - offset)', ...
                'Style', 'text' ...
                );
            
            dPanelTop = Utils.dPanelTopPad + dTextHeight;
            this.uieSlope.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, Utils.dEDITHEIGHT);
            this.uieOffset.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, Utils.dEDITHEIGHT);            

        end

        function calibration(this, dSlope, dOffset)
        %CALIBRATION Sets the calibration properties
        %   AxisSetup.calibration(dSlope, dOffset) 

            this.uieSlope.setVal(dSlope);
            this.uieOffset.setVal(dOffset);
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
            
        end

    end %methods
    
    methods (Access = private)

        function handleUI(this, src, evt)
        %HANDLEUI Callback that handles UI events
        %   
            
        % any time one of the UIEdit instances changes, we need to
        % update other ones since they are linked Raw <---> Cal and
        % visa versa

            % fprintf('enter: AxisSetup.handleUI() src.cLabel = %s\n',src.cLabel);
            if (src==this.uieDelay)
                % delete timer that refreshes refresh rate on motor
                % position and
                notify(this, 'eDelayChange');
            elseif ((src==this.uieSlope) || (src==this.uieOffset))
                notify(this,'eCalibrationChange');
            end
            
        
        end

        function cb(this, src, evt)
            switch src
                case this.hFigure
                    this.closeRequestFcn(); %TODO : aski it to do something
            end
        end
        
        
        function closeRequestFcn(this)
            this.msg('AxisSetup.closeRequestFcn()', 9 ); %TODO remove when finalized
            
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
            
            cDirTmp = fullfile( ...
                this.cDir, ...
                '..', ...
                this.cSaveDir ...
            );
            this.checkDir(cDirTmp);
            cReturn = fullfile(cDirTmp, [this.cName, '.mat']);
            
        end
        
        
        
    end

end


