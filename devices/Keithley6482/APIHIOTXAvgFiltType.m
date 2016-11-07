classdef APIHIOTXAvgFiltType < InterfaceAPIHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHIOTXAvgFiltType(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageType(1);
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageType(1, cVal);
        end
        
        
    end
    
    
    
end