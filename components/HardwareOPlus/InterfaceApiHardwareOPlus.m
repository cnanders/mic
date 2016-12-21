classdef InterfaceApiHardwareOPlus < HandlePlus

    methods (Abstract)
        
       get(this) % retrieve value
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
