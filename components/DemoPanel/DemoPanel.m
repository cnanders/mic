classdef DemoPanel < HandlePlus
    
    % abbr = pan    
   	
    properties
                
        
        dHeight = 300
        dWidth = 200
        
        uipHairColor
        uilHairStyle
        uieDelay
        test
                
    end
    
    properties (Constant)
        
        
    end
    
    
    properties (Constant, Access = private)
               
        
        dButtonWidth = 100;
        dButtonHeight = 30;
        dUIPad = 20;
                
    end
    
    
    
    properties (Access = private)
                
        % handles
        
        hParent
        hPanel
        dLeft
        dTop
        
    end
    
    events
        eSomethingClick;
    end    
   
    methods (Static)
        
        
    end
    
    methods
        
        function this = DemoPanel()
            
            this.init();
             
        end
        
        function init(this)
            
         
            % this.editBox1 = UIEdit('EditBox1','u8',160,240,50,this.hFigure);
            
            this.uilHairStyle = UIList({'one', 'two', 'three', 'four', 'five', 'six', 'seven'}, 'List label', true, true, true, true);
            this.uipHairColor = UIPopup({'blonde', 'brown', 'red'}, 'Popup label', true);
            this.uieDelay = UIEdit('delay', 'd', true); 
            
            
            this.uilHairStyle.setRefreshFcn(@this.refresh);
            
            addlistener(this.uilHairStyle, 'eDelete', @this.handleListDelete);
            
        end
        
        
        function ceReturn = refresh(this)
           
            ceReturn = {'bob', 'dave', 'joel', 'chris'};
            
        end
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Demo Panel',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
            
            this.uilHairStyle.build(this.hPanel, 10, 20, 180, 100);
            this.uipHairColor.build(this.hPanel, 10, 180, 100, 100);
            this.uieDelay.build(this.hPanel, 10, 220, 100, 30);
            % addlistener(this.ppHairColor, 'eChange', @this.cb);
   
        end
        
        
        function cb(this,src,evt)
            
            switch src
                case this.uilHairStyle
                    disp('DemoPanel.cb() uilHairStyle');
                case this.uipHairColor
                    disp('DemoPanel.cb() uiHairColor');
            end
            
            
        end
        
        function handleListDelete(this, src, evt)
            
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData.  The structure has one property called ceOptions which
            % is a cell array
            
            this.msg('handleListDelete');
            this.test = evt.stData.ceOptions;
        end
        
    end
    
end
    