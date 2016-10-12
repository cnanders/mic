classdef TestProgressBar < HandlePlus
        
    properties (Constant)
        
        dWidth = 400
        dHeight = 100;
               
    end
    
	properties
        
        pb
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestProgressBar()
              
            stParams = struct();
            stParams.dColorFill = [1 0 1];
            stParams.dColorBg = [1 1 0];
            this.pb = ProgressBar(stParams);
            
        end
        
        
        
        function build(this)
            
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            else 
            
                dScreenSize = get(0, 'ScreenSize');
                this.hFigure = figure( ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'Name', 'Reticle Control', ...
                    'Position', [ ...
                        (dScreenSize(3) - this.dWidth)/2 ...
                        (dScreenSize(4) - this.dHeight)/2 ...
                        this.dWidth ...
                        this.dHeight ...
                     ],... % left bottom width height
                    'Resize', 'off', ...
                    'HandleVisibility', 'on', ... % lets close all close the figure
                    'Visible', 'on'...
                );
            end
            
            this.pb.build(this.hFigure, 10, 10);
            this.pb.setProgress(0.3);
        end
        
        function delete(this)
            this.msg('delete', 5);
            
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end