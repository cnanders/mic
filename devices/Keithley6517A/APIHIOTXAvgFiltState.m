classdef APIHIOTXAvgFiltState < InterfaceAPIHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHIOTXAvgFiltState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageState();
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageState(cVal);
        end
        
        
    end
    
    
    
end
