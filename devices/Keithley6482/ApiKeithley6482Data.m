classdef ApiKeithley6482Data < InterfaceApiHardwareO
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6482Data(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.read(1);
        end
        
    end
    
    
    
end
