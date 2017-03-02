classdef ButtonToggle < mic.Base

    % uibt
    
    % 2014.11.19 CNA
    % This is a hybrid of a button and a toggle.  The idea is you want a
    % button that can have two visual states and a property that indicates
    % which visual state it is showing.  The difference between it and a
    % toggle is that clicking it doesn't actually change its visual state.
    % The visual state can only be changed programatically.  This is used
    % for the play/pause button of HardwareIO

    properties (Constant)

    end


    properties
       
        lVal = false            % true/false

    end


    properties (Access = private)
        hUI
        cTextT = 'True'         % "True" text
        cTextF = 'False'        % "False" text
        u8ImgT = uint8(0)         % "True" image
        u8ImgF = uint8(0)         % "False" image
        lImg = false          % use image?
        lAsk = false
        cMsg = 'Are you sure you want to do that?'
        cTooltip = 'Tooltip: set me!';
    end


    events
        eChange  
    end


    methods
        %% constructor
        % LEGACY ORDER cTextT, cTextF,lImg,u8ImgT,u8ImgF,lAsk,cMsg
        function this = ButtonToggle(varargin)

            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end


        end

        %% Methods
        function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
            this.hUI = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent),...
                'Style', 'pushbutton',...
                'TooltipString', this.cTooltip, ...
                'Callback', @this.cb ...
                );
            
            % Set lVal to update button image
            this.lVal = this.lVal;
            
        end

        %% Event handlers
        function cb(this, src, evt)
           switch src
               case this.hUI
                    if this.lAsk
                        % ask
                        cAns = questdlg(this.cMsg, 'Warning', 'Yes', 'Cancel', 'Cancel');
                        switch cAns
                            case 'Yes'
                                notify(this,'eChange');

                            otherwise
                                return
                        end  

                    else
                        notify(this,'eChange');
                    end
           end
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
        
        function lReturn = isVisible(this)
            
            if ishandle(this.hUI)
                switch get(this.hUI, 'Visible')
                    case 'on'
                        lReturn = true;
                    otherwise
                        lReturn = false;
                end
            else
                lReturn = false;
            end
            
        end
            
        function set.lVal(this, l)
            
            % this.msg('set.lVal');
            
            this.lVal = l;  
            
            if this.lImg
                
                % Using image
                if this.lVal
                    set(this.hUI, 'CData', this.u8ImgT);
                else
                    set(this.hUI, 'CData', this.u8ImgF);
                end
                    
            else
                % Use text
                if this.lVal
                    set(this.hUI, 'String', this.cTextT);
                else
                    set(this.hUI, 'String', this.cTextF);
                end
            end
                        
            
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
         
        

    end

end