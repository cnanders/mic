classdef GetSetText < mic.interface.device.GetSetText

    properties (Access = private)
        cVal = '...';
    end


    properties

    end
            
    methods
        
        function this = GetSetText()

        end

        function c = get(this)
            c = this.cVal;
        end

        function set(this, cVal)
            this.cVal = cVal;
        end 

    end %methods
end %class
    

            
            
            
        