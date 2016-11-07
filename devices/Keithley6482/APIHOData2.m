classdef APIHOData2 < InterfaceAPIHardwareO
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = APIHOData2(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.read(2);
        end
        
    end
    
    
    
end