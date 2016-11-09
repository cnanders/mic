classdef ApiKeithley6482AvgFiltState2 < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiKeithley6482AvgFiltState2(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getAverageState(2);
        end
            
        function set(this, cVal) % set new value
            this.api.setAverageState(2, cVal);
        end
        
        
    end
    
    
    
end
