classdef InterferometerCameraControl < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth      = 1280
        dHeight     = 780
        
    end
    
	properties
        
        uieCCDResX
        uieCCDResY
        uieCCDBinning
        
        uibCapture
        uibStream
        uibStop
        
       
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        bgcolor = [.6, .6, .6];
        
        cl
        
        
        hCameraSetupPanel
        hCameraControlPanel
        hFigure
        
         % Axes:
        hCameraAxes
        
        % Camera interface
        pcCCDControl
        
        dDelay = 0.1
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = InterferometerCameraControl(cl)
            
            this.cl = cl;
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Interferometer Camera Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Color', this.bgcolor,...
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            

           
            
            % Build Camera panel
            this.buildCameraPanels();
            
            % Build axes:
            this.buildAxes();
        end
        
                        
        function buildCameraPanels(this)
            % Build camera panel
            
            dTop = 25;
            dPad = 10;
            dLeft = 10;
            dPanelTop = dTop;
            dLeftCol1 = 10;
            dLeftCol2 = 100;
            dLeftCol3 = 190;
            dEditWidth = 80;
            dSep = 55;
                
            % Camera init panel setup
            CSPheight = 400;
%             this.hCameraSetupPanel = uipanel(...
%                 'Parent', this.hFigure,...
%                 'Units', 'pixels',...
%                 'Title', 'CCD setup',...
%                 'Clipping', 'on',...
%                 'BackgroundColor', this.bgcolor, ...
%                 ...%'BorderType', 'none', ...
%                 'Position', Utils.lt2lb([dLeft, dTop, ...
%                                         CSPheight, 250], this.hFigure) ...
%             );
        
            this.pcCCDControl.build(this.hFigure, dLeft, dTop, this.bgcolor);
            
        
        
            % Camera acquisition setup
            dTop = dTop + CSPheight;
            CCPHeight = 300;
            this.hCameraControlPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'CCD aquisition control',...
                'Clipping', 'on',...
                'BackgroundColor', this.bgcolor, ...
                'Position', Utils.lt2lb([10, dTop, ...
                                        CCPHeight, 250], this.hFigure) ...
            );
            
           
            
            this.uieCCDResX.build(this.hCameraControlPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCCDResY.build(this.hCameraControlPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCCDBinning.build(this.hCameraControlPanel, dLeftCol3, dTop, dEditWidth, Utils.dEDITHEIGHT);
            dTop = dTop + dSep;
            
            
            this.uibStream.build(this.hCameraControlPanel, dLeftCol1, dTop, 120, Utils.dEDITHEIGHT * 1.25);
            this.uibStop.build(this.hCameraControlPanel, dLeftCol1 + 130 , dTop, 120, Utils.dEDITHEIGHT * 1.25);
            dTop = dTop + dSep - 10;
            this.uibCapture.build(this.hCameraControlPanel, dLeftCol1, dTop, 250, Utils.dEDITHEIGHT * 1.5);
            dTop = dTop + dSep;
            
            drawnow; 
        end
        
        function buildAxes(this)
             this.hCameraAxes = axes(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([350 25 512 512], this.hFigure),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'DataAspectRatio',[1 1 1],...
                    'HandleVisibility','on'...
                    );
            
        end
               %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
       
        
        function handleClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
%             hHgtf = makehgtform('translate', [this.rcs.hioX.dValCal this.rcs.hioY.dValCal 0]);
%             if ishandle(this.hCarriage);
%                 set(this.hCarriage, 'Matrix', hHgtf);
%             end
            
            
        end
        
        
            

    end
    
    methods (Access = private)
        
        function init(this)
            
             
            % Camera control:
            this.pcCCDControl = PixisControl(this.cl, 'Pixis-CCD', 'Camera setup');

            
            this.uieCCDResX             =  UIEdit('CCD Res-X', 'u16');
            this.uieCCDResY             =  UIEdit('CCD Res-Y', 'u16');
            this.uieCCDBinning          =  UIEdit('Binning', 'u16');
            
            this.uibCapture             =  UIButton('Capture');
            this.uibStream              =  UIButton('Stream');
            this.uibStop                =  UIButton('Stop');
             
              % Default values
            
            this.uieCCDResX.setVal(uint16(2048));
            this.uieCCDResY.setVal(uint16(2048));
            this.uieCCDBinning.setVal(uint16(1));
           
            
            % Listeners:
            addlistener(this.uibCapture, 'eChange', @this.handleCapture);
            addlistener(this.uibCapture, 'eChange', @this.handleStream);
            addlistener(this.uibCapture, 'eChange', @this.handleStop);
            
            this.cl.add(@this.handleClock, this.id(), this.dDelay);

        end
        
        function handleStream(this, src, evt) 
            this.msg('CCD Stream');
        end
        function handleStop(this, src, evt) 
            this.msg('CCD Stop');
        end
        function handleCapture(this, src, evt) 
            this.msg('CCD Capture');
        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            this.msg('InterferometerCameraControl.closeRequestFcn()');
            delete(this.hFigure);
            % this.saveState();
        end
        

        

    end % private
    
    
end