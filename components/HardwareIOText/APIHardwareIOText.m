classdef APIHardwareIOText < InterfaceAPIHardwareIOText

    % apiv

    properties (Access = private)
        cVal = '...';
    end


    properties

    end
            
    methods
        
        function this = APIHardwareIOText()

        end

        function c = get(this)
            c = this.cVal;
        end

        function set(this, cVal)
            this.cVal = cVal;
        end 

    end %methods
end %class
    

            
            
            
        