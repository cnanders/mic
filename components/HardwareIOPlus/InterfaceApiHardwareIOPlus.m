classdef InterfaceApiHardwareIOPlus < HandlePlus

    methods (Abstract)
        
       d = get(this) % retrieve value
       l = isReady(this) % true when stopped or at its target
       set(this, dDest) % set new destination and move to it
       stop(this) % stop motion to destination
       index(this) % index
        
    end
    
end
        
