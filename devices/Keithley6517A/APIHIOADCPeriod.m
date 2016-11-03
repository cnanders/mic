classdef APIHIOADCPeriod < InterfaceAPIHardwareIO

    properties (Access = private)
        api
    end
    
    methods

        function this = APIHIOADCPeriod(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getIntegrationPeriod();
        end
        
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function set(this, dDest) % set new destination and move to it
            this.api.setIntegrationPeriod(dDest);
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
   end
    
    
end
