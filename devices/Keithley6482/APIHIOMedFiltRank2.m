classdef ApiHioMedFiltRank2 < InterfaceApiHardwareIO

    properties (Access = private)
        api
    end
    
    methods

        function this = ApiHioMedFiltRank2(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getMedianRank(2);
        end
        
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function set(this, dDest) % set new destination and move to it
            this.api.setMedianRank(2, uint8(dDest))
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
   end
    
    
end
