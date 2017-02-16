classdef ApiKeithley6517aAvgFiltMode < InterfaceApiHardwareIOText
    
    properties (Access = private)
        % {< ApiKeithley6517a 1x1}
        api
    end
    
    methods
        
        function this = ApiKeithley6517aAvgFiltMode(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageMode();
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageMode(cVal);
        end
        
        
    end
    
    
    
end
