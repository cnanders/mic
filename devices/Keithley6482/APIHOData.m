classdef APIHOData < InterfaceAPIHardwareO
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHOData(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getDataLatest();
            d = d(1);
        end
        
    end
    
    
    
end
