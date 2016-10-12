classdef APIGlobalHardwareIO < HandlePlus
    
    % See hungarian.m for help on APIHardwareIO* classes
    
    % This is to be used for any piece of hardware that only has one
    % set/get property, like the temperature of a thermostat or something.

    
    properties (Access = private)      
        
        parent
        
    end
    

    methods

        function this = APIGlobalHardwareIO(parent)
            
            this.parent = parent; 
        end
        

        function lIsReady = isReady(this)
            lIsReady = this.parent.areChildrenReady();
        end


        function set(this)
       
            this.parent.setAll(); % will get positions from its HIOs

        end 

        function stop(this)
            
            this.parent.stop();
                     
        end

    end
    
end

