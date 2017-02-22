classdef GetSetLogical < mic.interface.device.GetSetLogical

    % apiv

    properties (Access = private)
        lVal = false
    end


    properties
        
    end

            
    methods
        
        function this = GetSetLogical(varargin)
        
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
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
    

            
            
            
        