classdef ApiHioAvgFiltSize < InterfaceApiHardwareIO

    properties (Access = private)
        api
    end
    
    methods

        function this = ApiHioAvgFiltSize(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getAverageCount();
        end
        
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function set(this, dDest) % set new destination and move to it
            this.api.setAverageCount(uint8(dDest))
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
   end
    
    
end
