classdef ApiKeithley6517aData < InterfaceApiHardwareOPlus
    
    properties (Access = private)
        % {< ApiKeithley6517a 1x1}
        api
    end
    
    methods
        
        function this = ApiKeithley6517aData(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getDataLatest();
        end
        
        function l = isInitialized(true)
            l = false;
        end
        
    end
    
    
    
end
