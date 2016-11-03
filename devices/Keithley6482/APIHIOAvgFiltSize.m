classdef APIHIOAvgFiltSize < InterfaceAPIHardwareIO

    properties (Access = private)
        api
    end
    
    methods

        function this = APIHIOAvgFiltSize(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getAverageCount(1);
        end
        
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function set(this, dDest) % set new destination and move to it
            this.api.setAverageCount(1, uint8(dDest))
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
   end
    
    
end
