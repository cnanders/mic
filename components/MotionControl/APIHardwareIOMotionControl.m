classdef APIHardwareIOMotionControl < HandlePlus
    
    % See hungarian.m for help on APIHardwareIO* classes
    
    properties (Access = private)        
        
        dIndex
        parent
    end
    

    methods

        function this = APIHardwareIOMotionControl(parent, dIndex)
            
            % dIndex:  Double   1, 2, 3, 4 ... index of the Java array + 1
            
            this.parent = parent; % Parent is MotionControl or MultipleAxesControl
            this.dIndex = dIndex;
        end

        function dReturn = get(this)
            dReturn = this.parent.get(this.dIndex);            
        end
        
        function lIsReady = isReady(this)
            lIsReady = this.parent.isReady(this.dIndex);
        end
        
        function set(this, dDest)
            this.parent.set(this.dIndex, dDest);   
           % fprintf('Setting index: %d\n', this.dIndex);
        end 

        function stop(this)
            this.parent.stop(this.dIndex);
        end

    end
    
end

