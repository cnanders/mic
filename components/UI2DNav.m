classdef UI2DNav < HandlePlus
    
    %% Properties

    properties (Constant)

    end


    properties (Dependent = true)
    end


    properties
        dWidth = 256;
        dHeight = 256;
        
        hUI
        hAxes
        hScaleSlider
        hXCenterSlider
        hYCenterSlider
        
        dXCenter = 0;
        dYCenter = 0;
        dLogScale = 0;
    end

    properties (Access = private)

    end

    events
        eShutterClosed
    end

    methods
        
        %% Constructor
        function this = UI2DNav(dWidth, dHeight)
            this.dWidth = dWidth;
            this.dHeight = dHeight;
            
           this.init();
        end

        %% Methods
        function init(this)

        end

        function build(this, hParent, dLeft, dTop)
            
            this.hUI = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
                );
            drawnow
            
            delta = 10;
            
            this.hAxes = axes('Parent',this.hUI,...
                'Units', 'pixels',...
                'Position',[delta 2*delta this.dWidth-2*delta this.dHeight-2*delta ],...
                'Visible','on');
            this.drawWafer

            this.hScaleSlider = uicontrol(...
                'Parent', this.hUI,...
                'Style', 'slider',...
                'Units','pixels',...
                'Position',[delta delta this.dWidth-delta delta],...
                'Min',-3,'Value',0,'Max',3,...
                'Callback',@this.handleUI);
            
            this.hXCenterSlider = uicontrol(...
                'Parent', this.hUI,...
                'Style', 'slider',...
                'Units','pixels',...
                'Position',[delta 0 this.dWidth-delta delta],...
                'Value',0.5,...
                'Callback',@this.handleUI);
            
            this.hYCenterSlider = uicontrol(...
                'Parent', this.hUI,...
                'Style', 'slider',...
                'Units','pixels',...
                'Position',[0 delta delta this.dHeight-delta],...
                'Value',0.5,...
                'Callback',@this.handleUI);
            drawnow
            
           
        end
        
        function drawWafer(this)
            scale = 10^(this.dLogScale);
            t = linspace(0.5,2*pi-0.5,100);
            patch(-cos(t)*scale, sin(t)*scale,'w')
            axis square
            axis(this.hAxes,'off','square')
        end



        %% Modifiers

        %% Event handlers
        
        function handleUI(this, src, ~)
        %     switch src
        %         case this.uibSetup
        %             this.dsSetup.build();
        %     end
            this.dLogScale  = get(this.hScaleSlider,'Value');
            this.dXCenter   = get(this.hXCenterSlider,'Value');
            this.dYCenter   = get(this.hYCenterSlider,'Value');
            
%             if get(this.hScaleSlider,'Value')<get(this.hScaleSlider,'Min')*1.01;
%                 set(this.hScaleSlider, 'Value', get(this.hScaleSlider,'Min')*1.01);
%                 set(this.hScaleSlider, 'Min', get(this.hScaleSlider,'Min')-1)
%                 set(this.hScaleSlider, 'Max', get(this.hScaleSlider,'Max')-1)
%             end
%             
%             if get(this.hScaleSlider,'Value')>get(this.hScaleSlider,'Max')*0.99;
%                 set(this.hScaleSlider, 'Value', get(this.hScaleSlider,'Max')*0.99);
%                 set(this.hScaleSlider, 'Min', get(this.hScaleSlider,'Min')+1)
%                 set(this.hScaleSlider, 'Max', get(this.hScaleSlider,'Max')+1)
%             end
        end
        
        function set.dLogScale(this, value)
            this.dLogScale = value;
            %update the graph
            this.setScaleCenter()
        end
        
        function set.dXCenter(this, value)
            xl = xlim(this.hAxes);
            this.dXCenter = (value-0.5)*(xl(2)-xl(1));
            %update the graph
            this.setScaleCenter()
        end
        
        function set.dYCenter(this, value)
            yl = ylim(this.hAxes);
            this.dYCenter = (value-0.5)*(yl(2)-yl(1));
            %update the graph
            this.setScaleCenter()
        end
        
        
        function setScaleCenter(this)
            bound = 10^(this.dLogScale);
            vector = [-bound/2 bound/2];
            if ~isempty(this.hAxes)
                xlim(this.hAxes, vector-this.dXCenter)
                ylim(this.hAxes, vector-this.dYCenter)
            end
        end
        
        % TODO remove
        function setXCenter(this, value)

        end

        %% destructor
        function delete(this)
        end


    end %methods
end %classdef