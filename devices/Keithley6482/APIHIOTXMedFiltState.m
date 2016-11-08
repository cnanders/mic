classdef ApiHiotxMedFiltState < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHiotxMedFiltState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getMedianState(1);
        end
            
        function set(this, cVal) % set new value
            this.api.setMedianState(1, cVal);
        end
        
        
    end
    
    
    
end
