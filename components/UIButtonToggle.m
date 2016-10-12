classdef UIButtonToggle < HandlePlus

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
       
        lVal            % true/false

    end


    properties (Access = private)
        hUI
        cTextT          % "True" text
        cTextF          % "False" text
        u8ImgT          % "True" image
        u8ImgF          % "False" image
        lImg            % use image?
        lAsk
        cMsg
        cTooltip = 'Tooltip: set me!';
    end


    events
        eChange  
    end


    methods
        %% constructor
        function this = UIButtonToggle( ...
                cTextT, ...
                cTextF, ...
                lImg, ...
                u8ImgT, ...
                u8ImgF, ...
                lAsk, ...
                cMsg)

            % default input

            if exist('lImg', 'var') ~= 1
                lImg = false;
            end

            if exist('u8ImgT', 'var') ~= 1
                u8ImgT = [];
            end
            
            if exist('u8ImgF', 'var') ~= 1
                u8ImgF = [];
            end

            if exist('lAsk', 'var') ~= 1
                lAsk = false;
            end

            if exist('lMsg', 'var') ~= 1
                cMsg = 'Are you sure you want to do that?';
            end            

            this.cTextT = cTextT;
            this.cTextF = cTextF;
            this.lImg = lImg;
            this.u8ImgT = u8ImgT;
            this.u8ImgF = u8ImgF;
            this.lAsk = lAsk;
            this.cMsg = cMsg;
            this.lVal = true;


        end

        %% Methods
        function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
            this.hUI = uicontrol(...
                'Parent', hParent,...
                'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent),...
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
        

    end

end