classdef ApiHiotxAvgFiltType < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHiotxAvgFiltType(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageType();
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageType(cVal);
        end
        
        
    end
    
    
    
end
