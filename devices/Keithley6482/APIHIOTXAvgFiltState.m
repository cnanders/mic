classdef APIHIOTXAvgFiltState < InterfaceAPIHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHIOTXAvgFiltState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageState(1);
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageState(1, cVal);
        end
        
        
    end
    
    
    
end
