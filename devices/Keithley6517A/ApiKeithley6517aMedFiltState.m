classdef ApiKeithley6517aMedFiltState < InterfaceApiHardwareIOText
    
    properties (Access = private)
        % {< ApiKeithley6517a 1x1}
        api
    end
    
    methods
        
        function this = ApiKeithley6517aMedFiltState(api) 
            this.api = api;
        end
        
        function c = get(this) % retrieve value
            c = this.api.getMedianState();
        end
            
        function set(this, cVal) % set new value
            this.api.setMedianState(cVal);
        end
        
        
    end
    
    
    
end
