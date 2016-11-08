classdef ApiHiotxAutoRangeState < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHiotxAutoRangeState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAutoRangeState();
        end
            
        function set(this, cVal) % set new value
            this.api.setAutoRangeState(cVal);
        end
        
        
    end
    
    
    
end
