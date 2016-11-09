classdef ApiKeithley6482AutoRangeState < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6482AutoRangeState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAutoRangeState(1);
        end
            
        function set(this, cVal) % set new value
            this.api.setAutoRangeState(1, cVal);
        end
        
        
    end
    
    
    
end
