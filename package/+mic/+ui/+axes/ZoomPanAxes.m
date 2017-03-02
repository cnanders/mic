classdef ZoomPanAxes < HandlePlus
    
    % zpa
    
    % The class creates a panel in a parent figure that contains an axes.
    % The axes has a single direct child, which is an instance of a hgGroup
    % (Handle Graphics Group).  The idea of this class is to
    % provide a zoom/pan layer for viewing 2D graphical information.  All
    % you do is tell the class how big its axes is (pixels x pixels) and
    % the bounds (in arbitrary units) of the 2D graphical information it is
    % displaying
    %
    %   dXMin           (arb. units)
    %   dXMax           (arb. units)
    %   dyMin           (arb. units)
    %   dYMax           (arb. units)
    %   dAxesWidth      (pixels)
    %   dAxesHeight     (pixels)
    %
    % this class takes care of all of the math that is involved updating
    % the xlim and ylim properties of the axes as you move the zoom, panX,
    % and panY sliders around.  
    %
    % If you need to change the graphical information that is displayed
    % within the axes, all you do is modify the single hgGroup instance
    % that is the master parent for all graphical information.  If you are
    % unfamiliar with hgGroup, it is a way to group graphical elements that
    % matlab creates.  For example h = patch() returns a handle whose 
    % 'Parent' property can be set to the handle of an axis, the handle of
    % a hggroup, or the handle of a hgtransform. 
    %
    % Use:
    %
    % Create a ZoomPanAxes instanze
    %   zpa = ZoomPanInstance(-1, 1, -1, 1, 800, 500);
    % Set the hHggroup property
    %   zpa.hHggroup = hLocalHgGroup
    % Update hLocalHgGroup (including transformations, adding, removing
    % children, etc
    
    % h = hggroup creates an hggroup object as a child of the current axes
    % and returns its handle, h.
    
	properties
                
        dXPan
        dYPan
        dZoom
        hHggroup
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        hPanel
        hSliderZoom
        hSliderXPan
        hSliderYPan
        hAxes
        hCenterText
        hZoomText
                
        dXMin = -1
        dXMax = 1
        dYMin = -1
        dYMax = 1
                
        dZoomMin = 1
        dZoomMax = 5
        
        dAxesWidth = 1000
        dAxesHeight = 500
        
        % Minor step is when you click the little arrow at the end of the
        % slider; major step is when you click on the slider track to make
        % it jump by a large amount
        
        dMinorStep = 1/50;  % positive value that indicates the size of the major and minor steps as a percent change in slider value
        dMajorStep = 1/10;
        
        dXRange         % set in init()
        dYRange         % set in init()
        dAxesAR         % set in init()
        dCanvasAR       % set in init()
        
        dSliderPad = 10
        dSliderThick = 15
        dAxesColor = [0.7 0.7 0.7]
                        
    end
    
        
    events
        
        eClick
        
    end
    

    
    methods
        
        
        function this = ZoomPanAxes( ...
            dXMin, ...
            dXMax, ...
            dYMin, ...
            dYMax, ...
            dAxesWidth, ...
            dAxesHeight, ...
            dZoomMax ...
        )
            
            
            this.dXMin = dXMin;
            this.dXMax = dXMax;
            this.dYMin = dYMin;
            this.dYMax = dYMax;
            this.dAxesWidth = dAxesWidth;
            this.dAxesHeight = dAxesHeight;
            this.dZoomMax = dZoomMax;
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dLeft dTop this.dAxesWidth this.dAxesHeight], hParent) ...
            );
        
            % 'Title', 'Reticle Coarse Stage',...

        
			drawnow;
            
            % The axes fills the entire panel.  Sliders are "on top" of the
            % ases
            
            this.hAxes = axes(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Position', MicUtils.lt2lb([0 0 this.dAxesWidth this.dAxesHeight], this.hPanel), ...
                'XTick', [], ...
                'YTick', [], ...
                'XLim', [this.dXMin this.dXMax], ...
                'YLim', [this.dYMin this.dYMax], ...
                'XColor', 'white',...
                'YColor', 'white',...
                'Color', this.dAxesColor ,...
                'DataAspectRatio', [1 1 1],...
                'PlotBoxAspectRatio', [this.dAxesWidth this.dAxesHeight 1],...
                'HandleVisibility', 'on', ...
                'ButtonDownFcn', @this.handleAxesClick ...
            );
            
        
            
            
            this.hSliderXPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dXMin, ...
                'Max', this.dXMax, ...
                'Value', (this.dXMax + this.dXMin)/2, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', MicUtils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - 2*this.dSliderPad - 2*this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ...
            );
        
        
            this.hSliderYPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dYMin, ...
                'Max', this.dYMax, ...
                'Value', (this.dYMax + this.dYMin)/2, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', MicUtils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dSliderPad ...
                    this.dSliderThick ...
                    this.dAxesHeight - 4*this.dSliderPad - 2*this.dSliderThick], this.hPanel) ...
            );
        

            this.hSliderZoom = uicontrol(...
                'Parent', this.hPanel, ...
                'Style', 'slider', ...
                'Min', this.dZoomMin, ...
                'Max', this.dZoomMax, ...
                'Value', 1, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', MicUtils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - this.dSliderPad - this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ... 
            ); 
        
            %{
            this.hCenterText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    MicUtils.uicontrolY(this.ypos,this.hParent,15) ...
                    40 ...
                    15 ...
                 ],...
                'String','Center',...
                'Style','text');
            
            this.hZoomText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    MicUtils.uicontrolY(this.ypos+20,this.hParent,15) ...
                    40 ...
                    15 ...
                ],...
                'String','Zoom',...
                'Style','text');
            %}
                        
            
            lh2 = addlistener(this.hSliderXPan, 'ContinuousValueChange', @this.handleSliderXPan);
            lh3 = addlistener(this.hSliderYPan, 'ContinuousValueChange', @this.handleSliderYPan);
            lh1 = addlistener(this.hSliderZoom, 'ContinuousValueChange', @this.handleSliderZoom);
            
            
            this.hHggroup = hggroup('Parent', this.hAxes);
            this.dZoom = 1;
            
            
            set(hParent, 'WindowScrollWheelFcn', @this.handleScrollWheel);

            
        end
        
        
        
                
        
        %% Destructor
        
        function delete(this)
            
            
        end
        
                               
        function show(this)
    
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end
            
        end
        
        %{
        function this = set.hHggroup(this, h)
            
           % Clear the axes
           cla(this.hAxes, 'reset');
           
           % Set the parent of h to this 
           set(h, 'Parent', this.hAxes);
           
           this.hHggroup = h;
            
        end
        %}
        
        function this = set.dZoom(this, dVal)
                
            % Depending on the aspect ratio of the axes vs the aspect ratio
            % of the content you want to display within the axes, we do
            % different things for zoom:
            % 
            % When the aspect ratio of the axis (width/height) is > than
            % the aspect ratio of the content (the content is relatively 
            % taller) we do this :
            %
            %       At zoom 1, the x direction of the canvas fills the axis
            %       and there is canvas content hidden in the y direction
            %       above and below the axis limits
            %
            % When the aspect ratio of the axis is < the aspect ratio of
            % the content we do this (the content is relatively wider):
            % 
            %       At zoom 1, the y direction of the canvas fills the axis
            %       and there is canvas content hidden in the x direction to
            %       the left and right of the axis
            %
            % General notes:
            % 
            % As we zoom in, we change the viewed range by a factor 'zoom'.
            % The 'right amount of zoom' is simply achieved by setting the
            % xlim and ylim values to the canvas limits scaled by the zoom
            % value, and scaled by any aspect ratio factors as hinted at
            % above. However, this would always keep the geometric center
            % of the oMotorStage limits in the center of the axis - which
            % is not what we want to do.  We want to keep the current
            % center (pan) position as the center position while zooming.
            % So we first find the center position using the average of the
            % current limits in x and y and then shift the newly scaled
            % (zoomed) limits by the current center position.
        
           
            dXLimits = get(this.hAxes, 'Xlim');
            dYLimits = get(this.hAxes, 'Ylim');
            
            dXCenter = (dXLimits(1) + dXLimits(2))/2;
            dYCenter = (dYLimits(1) + dYLimits(2))/2;
            
            %{
            this.msg(sprintf(...
                'xrange: %1.1f, yrange: %1.1f', ...
                this.dXRange, ...
                this.dYRange ...
            ));
            %}
            
            
            if (this.dAxesAR > this.dCanvasAR)
                                
                % At zoom 1, the x direction of the canvas fills the axis
                % and there is canvas content hidden in the y direction
                % above and below the axis limits
                
                % this.msg('this.dAxesAR > this.dCanvasAR');
                
                dXMin = dXCenter - this.dXRange/2/dVal;
                dXMax = dXCenter + this.dXRange/2/dVal;
                
                dYMin = dYCenter - this.dXRange/2/dVal/this.dAxesAR;
                dYMax = dYCenter + this.dXRange/2/dVal/this.dAxesAR;
                
                                
            else
                
                % At zoom 1, the y direction of the canvas fills the axis
                % and there is canvas content hidden in the x direction to
                % the left and right of the axis
                
                % this.msg('this.dAxesAR < this.dCanvasAR');
                
                dYMin = dYCenter - this.dYRange/2/dVal;
                dYMax = dYCenter + this.dYRange/2/dVal;
                
                dXMin = dXCenter - this.dYRange/2/dVal*this.dAxesAR;
                dXMax = dXCenter + this.dYRange/2/dVal*this.dAxesAR;
                
            end

            %{
            this.msg(sprintf('x: [%1.1f, %1.1f] y: [%1.1f, %1.1f]', ...
                dXMin, ...
                dXMax, ...
                dYMin, ...
                dYMax ...
            ));
            %}
                            
            
            % Enforce limit constraints to the min/max range in both
            % directions
            
            if (dXMin < this.dXMin)
                dXMin = this.dXMin;
                
                %this.msg('dXMin < this.dXMin');
                
                
                if (this.dAxesAR > this.dCanvasAR)
                    dXMax = this.dXMin + this.dXRange/dVal;
                else
                    dXMax = this.dXMin + this.dYRange/dVal*this.dAxesAR;
                end
                    
            end
            
            if (dXMax > this.dXMax)
                
                %this.msg('dXMax > this.dXMax');
                dXMax = this.dXMax;
                
                 if (this.dAxesAR > this.dCanvasAR)
                    dXMin = this.dXMax - this.dXRange/dVal;
                 else
                    dXMin = this.dXMax - this.dYRange/dVal*this.dAxesAR;
                 end
            end
            
            if (dYMin < this.dYMin)
                %this.msg('dYMin < this.dYMin');
                dYMin = this.dYMin;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMax = this.dYMin + this.dXRange/dVal/this.dAxesAR;
                else
                    dYMax = this.dYMin + this.dYRange/dVal;
                end
                
            end
            
            if (dYMax > this.dYMax)
                %this.msg('dYMax > this.dYMax');
                dYMax = this.dYMax;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMin = this.dYMax - this.dXRange/dVal/this.dAxesAR;
                else
                    dYMin = this.dYMax - this.dYRange/dVal;
                end
                
            end
            
            % Set the limits
            
            set(this.hAxes, 'Xlim', [dXMin dXMax]);
            set(this.hAxes, 'Ylim', [dYMin dYMax]);
            
            % If we zoom out and hit the stage limit, the center of the view will
            % be at a different location on the stage.  We will update the
            % value of the xpan slider to reflect this change.
            
            set(this.hSliderXPan, 'Value', (dXMin + dXMax)/2);
            set(this.hSliderYPan, 'Value', (dYMin + dYMax)/2);
            % this.dXPan = (dXMin + dXMax)/2;
            
            
            % 2014.05.16 I think the steps for the pan should be set so
            % that at every zoom level it takes 20 steps to pan the one
            % edge of the viewable canvas across the axis
            
            
            set(this.hSliderXPan, 'SliderStep', [this.dMinorStep/dVal this.dMajorStep/dVal]);
            set(this.hSliderYPan, 'SliderStep', [this.dMinorStep/dVal this.dMajorStep/dVal]);
             
            this.dZoom = dVal;
                                    
        end
        
        function this = set.dXPan(this, dVal)
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            
            dLimits = get(this.hAxes, 'Xlim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dXMin
                dLimMin = this.dXMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dXMax
                dLimMax = this.dXMax;
                dLimMin = this.dXMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Xlim', [dLimMin dLimMax]);
                        
        end
        
        function this = set.dYPan(this, dVal)
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            
            dLimits = get(this.hAxes, 'Ylim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dYMin
                dLimMin = this.dYMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dYMax
                dLimMax = this.dYMax;
                dLimMin = this.dYMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Ylim', [dLimMin dLimMax]);
                        
        end
            

    end
    
    methods (Access = private)
        
        
        function handleSliderXPan(this, ~, ~)
            this.dXPan = get(this.hSliderXPan, 'Value');
        end
        
        function handleSliderYPan(this, ~, ~)
            this.dYPan = get(this.hSliderYPan, 'Value');
        end
        
        function handleSliderZoom(this, ~, ~)
            this.dZoom = get(this.hSliderZoom, 'Value'); 
        end        
                
        function init(this)
            
            this.dXRange = this.dXMax - this.dXMin;
            this.dYRange = this.dYMax - this.dYMin;
                        
            this.dAxesAR = this.dAxesWidth/this.dAxesHeight;
            this.dCanvasAR = this.dXRange/this.dYRange;

        end 
        
        function handleAxesClick(this, src, evt)
            
            this.msg('ZoomPanAxis.handleAxesClick()');
            
            % Update crosshair
            
            % dCursor = get(this.hFigure, 'CurrentPoint')     % [left bottom]
            dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
            dPanel = get(this.hPanel, 'Position');
            
            notify(this,'eClick');

        end
        
        function handleScrollWheel(this, src, evt)
            
           % this.msg(num2str(evt.VerticalScrollCount));
           
           % Increase/decrease zoom by a constant raised to the power
           % VerticalScrollCount
           % scale factor
           
           dMult = 1.02^(-evt.VerticalScrollCount);
           dNewZoom = this.dZoom*dMult;
           
           % this.msg(sprintf('zoom (before) %1.2f', this.dZoom));
           % this.msg(sprintf('zoom (after) %1.2f', dNewZoom));
           
           if (dNewZoom < this.dZoomMin)
               dNewZoom = this.dZoomMin;
           end
           
           if (dNewZoom > this.dZoomMax)
               dNewZoom = this.dZoomMax;
           end
           
           this.dZoom = dNewZoom;
           set(this.hSliderZoom, 'Value', dNewZoom);
                       
        end

    end % private
    
    
end