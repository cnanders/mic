classdef Window < handle
    
    % abbr = win    
   	
    properties (Constant)
       
        
    end
    
    
    properties
                
        cName;
        dHeight;
        dWidth;
        panPanel1;
        panPanel2;
        editBox1;
        as1;

    end
    
    properties (Access = private)
                
        % handles
        hFigure
       
    end
    
    events
        eSomethingClick;
    end
    
       
    methods (Static)
        
    end
    
    methods
        
        
        function this = Window(...
                cName, ...      % id
                dWidth, ...    % width
                dHeight ...    % height
                )
            
            this.cName = cName;
            this.dWidth = dWidth;
            this.dHeight = dHeight;
            this.init();
            % this.build();
            
        end
        
        function init(this)
            
        	this.panPanel1 = DemoPanel('Panel1');
            this.as1 = AxisSetup('test-axis');
            
        end
        
        function build(this)
            
            % position: left bottom width height
            
            this.hFigure = figure(...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Name', this.cName,...
                'Position',[100 100 this.dWidth this.dHeight],... % left bottom width height
                'Resize','off',...
                'HandleVisibility','on',... % lets close all close the figure
                'Visible','on',...
                'CloseRequestFcn',@this.cb);
            
            this.panPanel1.build(this.hFigure, 10, 30, 300, 300)
            

        end
        
        function closeRequestFcn(this)
            disp('Window.closeRequestFcn()');
            delete(this.hFigure);
        end
        
        function save(this)
            disp('Window.save()');
        end
        
        
        function cb(this, hSource, eEvent)
            
            switch hSource
                case this.hFigure
                    this.save();
                    this.closeRequestFcn();
            end
        end
        
        
        % Destructor
        function delete(this)
            disp('Window.destructor()');
%             if(this.hFigure)
%                 delete(this.hFigure);
%             end
        end
                
    end
end
    
    
    