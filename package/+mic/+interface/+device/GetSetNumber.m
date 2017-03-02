classdef GetSetNumber < mic.Base

    methods (Abstract)
        
       d = get(this) % retrieve value
       l = isReady(this) % true when stopped or at its target
       set(this, dDest) % set new destination and move to it
       stop(this) % stop motion to destination
       index(this) % index
       
       % Command the device to initialize.
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
    end
    
end
        
