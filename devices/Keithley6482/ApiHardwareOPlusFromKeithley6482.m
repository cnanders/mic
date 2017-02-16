classdef ApiHardwareOPlusFromKeithley6482 < InterfaceApiHardwareOPlus

    properties (Access = private)
        
        % {< InterfaceKeithley6482 1x1} 
        api
        
        % {char 1xm} identifies what property we want exposed
        cProp
        
        % {uint8 1x1} channel
        u8Channel
    end
    
    methods

        function this = ApiHardwareOPlusFromKeithley6482(api, cProp, u8Channel) 
            this.api = api;
            this.cProp = cProp;
            this.u8Channel = u8Channel;
        end
        
        function d = get(this) % retrieve value
            switch this.cProp
                case 'data'
                    d = this.api.read(this.u8Channel);
                otherwise
                    cMsg = sprintf('WARNING: ApiHardwareOPlusFromKeithley does not support prop %s', this.cProp);
                    disp(cMsg);
            end
        end
        
        function l = isInitialized(this)
            l = true;
        end
    end
    
end

