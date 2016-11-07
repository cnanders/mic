classdef APIHIORange2 < InterfaceAPIHardwareIO

    properties (Access = private)
        api
    end
    
    methods

        function this = APIHIORange2(api) 
            this.api = api;
        end
        
        function d = get(this) % retrieve value
            d = this.api.getRange(2);
        end
        
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function set(this, dDest) % set new destination and move to it
            this.api.setRange(2, dDest);
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
   end
    
    
end
