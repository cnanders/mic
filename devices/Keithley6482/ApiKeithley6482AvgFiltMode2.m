classdef ApiKeithley6482AvgFiltMode2 < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6482AvgFiltMode2(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageMode(2);
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageMode(2, cVal);
        end
        
        
    end
    
    
    
end
