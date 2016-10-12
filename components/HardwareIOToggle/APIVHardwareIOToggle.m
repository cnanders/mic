classdef APIVHardwareIOToggle < InterfaceAPIHardwareIOToggle

    % apiv

    properties (Access = private)
        
        lVal = false
        
    end


    properties

        cName
        
    end

            
    methods
        
        function this = APIVHardwareIOToggle(stParams)
        % @param {struct 1x1} stParams - config
        % @param {cell 1xm} stParams.cName - unique name
        
            % Assign params to properties
            ceNames = fieldnames(stParams);
            for k = 1:length(ceNames)
                this.(ceNames{k}) = stParams.(ceNames{k});
            end

        end

        function lReturn = get(this)
            
            % this.msg(sprintf('get() = %1.0f', this.lVal));
            lReturn = this.lVal;
        end


        function set(this, lVal)
            % this.msg(sprintf('set(%1.0f)', lVal));
            this.lVal = lVal;
        end 


    end %methods
end %class
    

            
            
            
        