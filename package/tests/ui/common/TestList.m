classdef TestList < handle
    
    % abbr = pan    
   	
    properties
                
        uiList
                
    end
    
    properties (Constant)
        
        
    end
    
    
    properties (Constant, Access = private)
               
                        
    end
    
    
    properties (Access = private)
                        
    end
    
    events
        
    end    
   
    methods (Static)
        
        
    end
    
    methods
        
        function this = TestList()
            
            this.init();
             
        end
        
        function init(this)
            
            this.uiList = mic.ui.common.List(...
                'ceOptions', {'one', 'two', 'three', 'four', 'five', 'six', 'seven'}, ...
                'cLabel', 'Hello, World!' ...
            );

            this.uiList.setRefreshFcn(@this.onRefresh);
            addlistener(this.uiList, 'eDelete', @this.onDelete);
            
        end
        
        
        function ceReturn = onRefresh(this)
            ceReturn = {'bob', 'dave', 'joel', 'chris'};
        end
        
        function onDelete(this, src, evt)
            
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData.  The structure has one property called ceOptions which
            % is a cell array
            
            disp 'onDelete'
            evt.stData.ceOptions
        end
        
        function build(this, hParent, dLeft, dTop)
            this.uiList.build(hParent, dLeft, dTop, 180, 100);
            
        end
            
    end
    
end
    