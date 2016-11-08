classdef ApiHoData < InterfaceApiHardwareO
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHoData(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.read(1);
        end
        
    end
    
    
    
end
