classdef ProgressBar < HandlePlus
    
    % uitx
    
    % meant to be inside of a panel.  Matlab makes the default background
    % color of a uicontrol('text') the same as panels
    
    properties (Constant)
       
    end
    
      
    properties
    end
    
    properties (SetAccess = private)
        dProgress       % Number in [0 : 1] 
        cWeightFont
        dSizeFont
        dHeight
        dWidth
    end
    
    
    properties (Access = private)        
        hPanelBg
        hPanelFill
        dColorBg
        dColorFill
        dColorFont
        hText
        dWidthText
    end
    
    
    events

    end
    
    
    methods
        
       % constructor
       
       function this = ProgressBar(params)
       %PROGRESSBAR
       %    @param {struct} params - config
       %    @param {double 1x1} [params.dWidth = 300] - the width
       %    @param {double 1x1} [params.dHeight = 20] - the height
       %    @param {double 1x3] [params.dColorFill = [0 1 0]] - the color
       %        of the progress fill (see ColorSpec)
       %    @param {double 1x3} [params.dColorBg = [1 1 1]] - the color of
       %        the background (see ColorSpec)
       %    @param {double 1x3} [params.dColorFont = [1 1 1]] - the color of
       %        the progress font (see ColorSpec)
       %    @param {double 1x1} [params.dSizeFont = 10] - font size
       %    @param {char 1xm} [params.cWeightFont = 'normal'] - the font weight
       %    @param {double 1x1} [params.dWidthText = 50] - the width of the
       %        text label
       
            defaultParams.dWidth = 300;
            defaultParams.dHeight = 10;
            % defaultParams.dColorFill = [hex2dec('1F') hex2dec('86') hex2dec('FB')]/255; % [0 1 0];
            defaultParams.dColorFill = [hex2dec('a9') hex2dec('a9') hex2dec('a9')]/255; % [0 1 0];
            defaultParams.dColorBg = [1 1 1];
            defaultParams.dColorFont = [0 0 0];
            defaultParams.dSizeFont = 10;
            defaultParams.cWeightFont = 'normal';
            defaultParams.dWidthText = 50;
            
            params = mergestruct(defaultParams, params);
                   
            this.dWidth = params.dWidth;
            this.dHeight = params.dHeight;
            this.dColorBg = params.dColorBg;
            this.dColorFill = params.dColorFill;
            this.dColorFont = params.dColorFont;
            this.dSizeFont = params.dSizeFont;
            this.cWeightFont = params.cWeightFont;
            this.dWidthText = params.dWidthText;
            
                                  
            
       end
       
       function build(this, hParent, dLeft, dTop) 
                                  
            this.hPanelBg =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth', 0, ...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
        
            this.hPanelFill =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorFill,...
                'BorderWidth', 0, ...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
                
            this.hText = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', this.cWeightFont, ...
                'FontSize', this.dSizeFont, ...
                'ForegroundColor', this.dColorFont, ...
                'BackgroundColor', this.dColorBg,...
                'Position', Utils.lt2lb([dLeft + this.dWidth dTop this.dWidthText this.dHeight], hParent), ...
                'Style', 'text', ...
                'String', '0%'...
                );
            
        
            this.setProgress(0);
           
       end
       
       function setProgress(this, dVal)
           
           this.dProgress = dVal;
           
           if ishandle(this.hPanelFill)
           
               dPosition = get(this.hPanelFill, 'Position');
               dWidth = this.dWidth * this.dProgress;
               if dWidth < 1
                   dWidth = 1;
               end
               
               %LTWH
               set(this.hPanelFill, 'Position', ...
                   [dPosition(1) dPosition(2)  dWidth dPosition(4)]);
               
               %{
               dPosition = get(this.hText, 'Position');
               set(this.hText, 'Position', ...
                   [dWidth - this.dWidthText dPosition(2) dPosition(3) dPosition(4)]);
               %}
           end
           
           
           if ishandle(this.hText)
                set(this.hText, 'String', sprintf('%1.1f%%', this.dProgress * 100));
           end
           
       end
              
       
       function show(this)
    
            if ishandle(this.hPanelBg)
                set(this.hPanelBg, 'Visible', 'on');
            end
            
            if ishandle(this.hPanelFill)
                set(this.hPanelFill, 'Visible', 'on');
            end
            
            if ishandle(this.hText)
                set(this.hText, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanelBg)
                set(this.hPanelBg, 'Visible', 'off');
            end
            
            if ishandle(this.hPanelFill)
                set(this.hPanelFill, 'Visible', 'off');
            end
            
            if ishandle(this.hText)
                set(this.hText, 'Visible', 'off');
            end

        end
               
    end
end