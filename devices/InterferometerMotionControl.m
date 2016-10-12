classdef InterferometerMotionControl < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth      = 1280
        dHeight     = 780
        
    end
    
	properties
        
        smarPod
        smarGoni

        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        cl
        
        hCameraControlPanel
        
         % Axes:
        hCameraAxes
        
        zpa
        hFigure
        hTrack
        hCarriage
        hIllum
        
        dDelay = 0.1
        dFieldX
        dFieldY
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = InterferometerMotionControl(cl)
            
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
                'Name', 'Interferometer Motion Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
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
            
            % Create stages:
            this.smarPod.build(this.hFigure,... 
                               dPad,...
                               dTop...
                               );
                           
            this.smarGoni.build(this.hFigure, ...
                                dPad, ...
                                dTop + dPad + this.smarPod.dHeight...
                                );
            
           
            
            % Build Camera panel
            this.buildCameraPanel();
            
            % Build axes:
            this.buildAxes();
        end
        
                        
        function buildCameraPanel(this)
            % Build camera panel
            

            drawnow; 
        end
        
        function buildAxes(this)
             this.hCameraAxes = axes(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([350 5 512 512], this.hFigure),...
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
            
           
            %this.rcs = ReticleCoarseStage(this.cl);
            this.smarPod    = SmarPodM(this.cl);
            this.smarGoni   = SmarGoni(this.cl);

            
            
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
            this.msg('ReticleControl.closeRequestFcn()');
            delete(this.hFigure);
            % this.saveState();
        end
        
        
        
        
        
        

    end % private
    
    
end