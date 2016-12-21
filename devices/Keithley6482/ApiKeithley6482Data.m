classdef ApiKeithley6482Data < InterfaceApiHardwareOPlus
    
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
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
    
    
    
end
