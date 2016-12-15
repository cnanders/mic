classdef ConfigMotor < handle
    
    %ms
    
    properties
       uieDelay
       uieSlope
       uieOffset
       uieStepCal
       uieStepRaw
       uieLowLimitCal
       uieLowLimitRaw
       uieHighLimitCal
       uieHighLimitRaw
       uieTolCal
       uieTolRaw
       
       cName
    end
    
    
    properties (Access = private)
        hFigure
    end
    
    
    methods
        
        function this = ConfigMotor(cName)
            this.cName = cName;
            this.init();
        end
        
        
        function init(this)
            
            this.uieDelay =          UIEdit('Delay (s)', 'd');
            this.uieSlope =          UIEdit('Slope', 'd');
            this.uieOffset =         UIEdit('Offset (raw)', 'i16');
            this.uieStepCal =        UIEdit('Step (cal)', 'd');
            this.uieStepRaw =        UIEdit('Step (raw)', 'i16');
            this.uieLowLimitCal =    UIEdit('Low limit (cal)', 'd');
            this.uieLowLimitRaw =    UIEdit('Low limit (raw)', 'i16');
            this.uieHighLimitCal =   UIEdit('High limit (cal)', 'd');
            this.uieHighLimitRaw =   UIEdit('High limit (raw)', 'i16');
            this.uieTolCal =         UIEdit('Tol. (cal)', 'd');
            this.uieTolRaw =         UIEdit('Tol. (raw)', 'i16');
            
            % When you enter a value into the MotorControl position, it
            % checks that it is > lowLimit and < highLimit
                        
            % defaults until load/save is working
            this.uieDelay.setVal(0.5);
            this.uieSlope.setVal(1);
            this.uieOffset.setVal(int16(0));
            this.uieStepCal.setVal(0.5);
            this.uieLowLimitCal.setVal(0);
            this.uieHighLimitCal.setVal(100);
            this.uieTolCal.setVal(0.1);
            
            % Event listeners
            addlistener(this.uieDelay, 'eChange', @this.handleChange);
            addlistener(this.uieSlope, 'eChange', @this.handleChange);
            addlistener(this.uieOffset, 'eChange', @this.handleChange);
            addlistener(this.uieStepCal, 'eChange', @this.handleChange);
            addlistener(this.uieStepRaw, 'eChange', @this.handleChange);
            addlistener(this.uieLowLimitCal, 'eChange', @this.handleChange);
            addlistener(this.uieLowLimitRaw, 'eChange', @this.handleChange);
            addlistener(this.uieHighLimitCal, 'eChange', @this.handleChange);
            addlistener(this.uieHighLimitRaw, 'eChange', @this.handleChange);
            addlistener(this.uieTolCal, 'eChange', @this.handleChange);
            addlistener(this.uieTolRaw, 'eChange', @this.handleChange);
            
        end
        
        function build(this)
            
            dPanelLeft = 10;
            dPanelWidth = 200;
            
            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dEditWidth = 80;
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [100 100 220 490],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );
            
            dFigureTop = 10;
            dPanelTop = MicUtils.dPanelTopPad;
            
			
            % Delay
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Update rate',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
			drawnow;
			
            this.uieDelay.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dFigureTop = MicUtils.ut(hPanel, this.hFigure);
            
            
            % Calibration
            dTextHeight = 20;
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Calibration',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)+dTextHeight], this.hFigure) ...
            );
			drawnow;
        
 
            hText = uicontrol(...
                'Parent', hPanel , ...
                'HorizontalAlignment', 'left', ...
                'Position', MicUtils.lt2lb([dLeftCol1, dPanelTop, 150, dTextHeight], hPanel), ...
                'String', 'cal = slope*(raw - offset)', ...
                'Style', 'text' ...
                );
            dPanelTop = dPanelTop + dTextHeight;
            this.uieSlope.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieOffset.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dFigureTop = MicUtils.ut(hPanel, this.hFigure);
            dPanelTop = MicUtils.dPanelTopPad;
            
			
            % Step
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Step (+/- buttons)',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
			drawnow;
			
            this.uieStepCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieStepRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dFigureTop = MicUtils.ut(hPanel, this.hFigure);

                        
            % Software Limits
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '(Software) motion limits',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(2)], this.hFigure) ...
            );
			drawnow;
            
            this.uieLowLimitCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieLowLimitRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            
            dPanelTop = MicUtils.ut(this.uieLowLimitCal.hUI, hPanel);
            
            this.uieHighLimitCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieHighLimitRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            
            dFigureTop = MicUtils.ut(hPanel, this.hFigure);
            dPanelTop = MicUtils.dPanelTopPad;
            
			
            % "Is There?" Tol
            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '"Is There?" Tolerance',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dPanelLeft dFigureTop dPanelWidth MicUtils.panelHeight(1)], this.hFigure) ...
            );
			drawnow;
			
            this.uieTolCal.build(hPanel, dLeftCol1, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            this.uieTolRaw.build(hPanel, dLeftCol2, dPanelTop, dEditWidth, MicUtils.dEDITHEIGHT);
            dFigureTop = MicUtils.ut(hPanel, this.hFigure);
            
  
        end
        
        function cb(this, src, evt)
            
            switch src
                case this.hFigure
                    this.closeRequestFcn();
                    
            end
            
        end
        
        function handleChange(this, src, evt)
            
            % any time one of the UIEdit instances changes, we need to
            % update other ones since they are linked Raw <---> Cal and
            % visa versa
            
            disp(sprintf('MotorSetup.handleChange() src.cLabel = %s',src.cLabel));
                       
            switch src
                case this.uieDelay
                    % delete timer that refreshes refresh rate on motor
                    % position and 
                case {this.uieSlope, this.uieOffset}
                    
                    % need to update all cal
                    
                    % step not affected by offset
                    this.uieStepCal.setVal(double(this.uieStepRaw.val())*this.uieSlope.val());
                    % tol not affected by offset
                    this.uieTolCal.setVal(double(this.uieTolRaw.val())*this.uieSlope.val());
                                        
                    this.uieLowLimitCal.setVal(this.raw2cal(this.uieLowLimitRaw.val()));
                    this.uieHighLimitCal.setVal(this.raw2cal(this.uieHighLimitRaw.val()));
                    
                case this.uieStepCal
                    % step is not affected by offset
                    this.uieStepRaw.setVal(int16(this.uieStepCal.val()/this.uieSlope.val()));                
                case this.uieStepRaw
                    % step is not affected by offset
                    this.uieStepCal.setVal(double(this.uieStepRaw.val())*this.uieSlope.val());
                case this.uieLowLimitCal
                    this.uieLowLimitRaw.setVal(this.cal2raw(src.val()));
                case this.uieLowLimitRaw
                    this.uieLowLimitCal.setVal(this.raw2cal(src.val())); 
                case this.uieHighLimitCal
                    this.uieHighLimitRaw.setVal(this.cal2raw(src.val()));
                case this.uieHighLimitRaw
                    this.uieHighLimitCal.setVal(this.raw2cal(src.val()));
                case this.uieTolCal
                    % tol is not affected by offset
                    this.uieTolRaw.setVal(int16(src.val()/this.uieSlope.val()));                
                case this.uieTolRaw
                    % tol is not affected by offset
                    this.uieTolCal.setVal(double(src.val())*this.uieSlope.val());
                        
            end
        end
        
                
        function out = cal2raw(this, dCal)
            % cal = slope*(raw - offset)
            out = int16(dCal/this.uieSlope.val() + this.uieOffset.val());
        end
        
        function out = raw2cal(this, dRaw)
            % cal = slope*(raw - offset)
            out = this.uieSlope.val()*double(dRaw - this.uieOffset.val());
        end
        
        function closeRequestFcn(this)
            disp('Window.closeRequestFcn()');
            delete(this.hFigure);
        end
        
    end
    
end
        
        
        