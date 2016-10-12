classdef UIButton < HandlePlus
    % uib
    % UIButton(cText, lImg, u8Img, lAsk, cMsg)

    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        hUI
        cText
        u8Img           % image cdata
        lImg            % use image?
        lAsk
        cMsg
        cTooltip = 'Tooltip: set me!';
    end


    events
        ePress
        eChange  
    end


    methods
        %% constructor
        function this = UIButton(cText, lImg, u8Img, lAsk, cMsg)
        %UIButton    
        %   UIButton(cText, lImg, u8Img, lAsk, cMsg)

            % default input

            if exist('lImg', 'var') ~= 1
                lImg = false;
            end

            if exist('u8Img', 'var') ~= 1
                u8Img = [];
            end

            if exist('lAsk', 'var') ~= 1
                lAsk = false;
            end

            if exist('cMsg', 'var') ~= 1
                cMsg = 'Are you sure you want to do that?';
            end            

            this.cText = cText;
            this.lImg = lImg;
            this.u8Img = u8Img;
            this.lAsk = lAsk;
            this.cMsg = cMsg;

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

            if this.lImg
                set(this.hUI, 'CData', this.u8Img);
            else
                set(this.hUI, 'String', this.cText);
            end

        end

        %% Event handlers
        function cb(this, src, evt)
           switch src
               case this.hUI
                    notify(this, 'ePress');
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
            
        
        %AW2013-7-17 : addded a setter to update the image
        function setU8Img(this, value)
            
            if ishandle(this.hUI) 
                this.u8Img = value;
                set(this.hUI, 'CData', this.u8Img);
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