classdef UIText < HandlePlus
    
    % uitx
    
    % meant to be inside of a panel.  Matlab makes the default background
    % color of a uicontrol('text') the same as panels
    
    properties (Constant)
       
    end
    
      
    properties
        cVal
    end
    
    
    properties (Access = private)
        hUI
        cHorizontalAlignment
        cFontWeight
        dFontSize
        cTooltip = 'Tooltip: set me!';
        dColorBg = [.94 .94 .94]; % MATLAB default
    end
    
    
    events

    end
    
    
    methods
        
       % constructor
       
       function this = UIText(cVal, cHorizontalAlignment, cFontWeight, dFontSize)
           
            % defaults
            if exist('cHorizontalAlignment', 'var') ~= 1
                cHorizontalAlignment = 'left';
            end
            
            if exist('cFontWeight', 'var') ~= 1
                cFontWeight = 'normal';
            end
            
            if exist('dFontSize', 'var') ~= 1
                dFontSize = 10;
            end
            
            
           this.cVal = cVal;
           this.cHorizontalAlignment = cHorizontalAlignment;
           this.cFontWeight = cFontWeight;
           this.dFontSize = dFontSize;
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
                                  
            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', this.cHorizontalAlignment, ...
                'FontWeight', this.cFontWeight, ... % 'FontSize', this.dFontSize, ...
                'Position', MicUtils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'text', ...
                'BackgroundColor', this.dColorBg, ...
                'TooltipString', this.cTooltip, ...
                'String', this.cVal ...
                );

       end
       
       
       function set.cVal(this, cVal)
           
           % prop
           if ischar(cVal)
               this.cVal = cVal;
           else
               cMsg = sprintf('UIText.set.cVal() requires type "char".  You supplied type "%s".  Not overwriting the cVal property.', ...
                   class(cVal) ...
                   );
               cTitle = 'UIText.set.sVal() error';
               % msgbox(cMsg, cTitle, 'warn');
               error(cMsg);
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'String', this.cVal);
           end
           
           drawnow;
            
           
       end
       
       
       function show(this)
    
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end

        end
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setBackgroundColor(this, dColor)
            
           if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'BackgroundColor', dColor) 
        end
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setColor(this, dColor)
            
            if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'ForegroundColor', dColor)
            
        end
        
        function setTooltip(this, cText)
        %SETTOOLTIP
        %   @param {char 1xm} cText - the text of the tooltip
        
            this.cTooltip = cText;
            if ishandle(this.hUI)        
                set(this.hUI, 'TooltipString', this.cTooltip);
            end
        end
        
        function enable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'on');
            end
        end
        
        function disable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'off');
            end
            
        end
        
        function delete(this)
            cMsg = sprintf('delete() %s', this.cVal);
            % this.msg(cMsg);
        end
       
       
        
    end
end