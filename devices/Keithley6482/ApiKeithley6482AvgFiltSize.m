classdef ApiKeithley6482AvgFiltSize < InterfaceApiHardwareIOPlus

    properties (Access = private)
        api
    end
    
    methods

        function this = ApiKeithley6482AvgFiltSize(api) 
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
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
   end
    
    
end
