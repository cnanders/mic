classdef InterfaceAPIHardwareIOToggle < HandlePlus

    methods (Abstract)
        
       % Get the state of the toggle
       % @param {logical 1x1} lVal
       % @return {logical 1x1}
       l = get(this)
       
       % Set the state of the toggle
       % @param {logical 1x1} lVal
       set(this, lVal)
        
    end
    
end
        
