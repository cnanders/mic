classdef ApiKeithley6517aData < InterfaceApiHardwareOPlus
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6517aData(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getDataLatest();
        end
        
    end
    
    
    
end
