classdef ApiKeithley6482Data2 < InterfaceApiHardwareOPlus
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6482Data2(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.read(2);
        end
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
    
    
    
end
