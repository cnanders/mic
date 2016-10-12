classdef HardwareOPlus < HardwareIOPlus
    

    
    % Hungarian: hop

    properties (Constant)
        
        
    end

    properties      
        
    end

    properties (SetAccess = private)
        
    end

    properties (Access = protected)
        
        
        
    end
    

    events
        
        
    end

    
    methods       
        
        function this = HardwareOPlus(stParams)  
        % This is a HardwareIOPlus with several optional features disabled.  
        % See HardwareIOPlus for required inputs.  This is the lazy
        % approach but I think it is a decent one.
        
            stDefault = struct();
            stDefault.lDisableI = true;
            
            % Merge struct but make stDefault the master and stParams the
            % slave
            
            stParams = mergestruct(stParams, stDefault);
            
            % Initialize the object for each superclass within the subclass constructor
            % http://www.mathworks.com/help/matlab/matlab_oop/creating-subclasses--syntax-and-techniques.html

            this@HardwareIOPlus(stParams);
            
        end
 

    end %methods
    
    methods (Access = protected)
            

    end

end %class
