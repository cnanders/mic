classdef APIHIOTXAvgFiltType2 < InterfaceAPIHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHIOTXAvgFiltType2(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageType(2);
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageType(2, cVal);
        end
        
        
    end
    
    
    
end
