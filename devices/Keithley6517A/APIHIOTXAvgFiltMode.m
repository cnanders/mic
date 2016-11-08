classdef ApiHiotxAvgFiltMode < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHiotxAvgFiltMode(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageMode();
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageMode(cVal);
        end
        
        
    end
    
    
    
end
