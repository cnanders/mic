classdef ApiKeithley6517aAvgFiltType < InterfaceApiHardwareIOText
    
    properties (Access = private)
        % {< ApiKeithley6517a 1x1}
        api
    end
    
    methods
        
        function this = ApiKeithley6517aAvgFiltType(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageType();
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageType(cVal);
        end
        
        
    end
    
    
    
end
