classdef APIWago < HandlePlus
    
    % See hungarian.m for help on APIHardwareIO* classes
    
    properties (Access = private)        
        
        dIndex
        parent
    end
    

    methods

        function this = APIWago(parent, dIndex)
            
            % dIndex:  Double   1, 2, 3, 4 ... index of the Java array + 1
            
            this.parent = parent; 
            this.dIndex = dIndex;
        end

        function dReturn = get(this)
            dReturn = this.parent.get(this.dIndex);            
        end

        function set(this, dDest)
            this.parent.set(this.dIndex, dDest);            
        end 

    end
    
end

