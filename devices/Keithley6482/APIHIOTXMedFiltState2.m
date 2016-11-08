classdef ApiHiotxMedFiltState2 < InterfaceApiHardwareIOText
    
    properties (Access = private)
        api
    end
    
    methods
        
        function this = ApiHiotxMedFiltState2(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getMedianState(2);
        end
            
        function set(this, cVal) % set new value
            this.api.setMedianState(2, cVal);
        end
        
        
    end
    
    
    
end
