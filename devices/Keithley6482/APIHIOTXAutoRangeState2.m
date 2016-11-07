classdef APIHIOTXAutoRangeState2 < InterfaceAPIHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHIOTXAutoRangeState2(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAutoRangeState(2);
        end
            
        function set(this, cVal) % set new value
            this.api.setAutoRangeState(2, cVal);
        end
        
        
    end
    
    
    
end
