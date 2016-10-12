classdef InterfaceAPIHardwareIO < HandlePlus

    methods (Abstract)
        
       get(this) % retrieve value
       isReady(this) % true when stopped or at its target
       set(this, dDest) % set new destination and move to it
       stop(this) % stop motion to destination
       index(this) % index
        
    end
    
end
        
