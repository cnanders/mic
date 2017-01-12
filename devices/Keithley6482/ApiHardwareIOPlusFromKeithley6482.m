classdef ApiHardwareIOPlusFromKeithley6482 < InterfaceApiHardwareIOPlus

    properties (Access = private)
        
        % {< InterfaceKeithley6482 1x1} 
        api
        
        % {char 1xm} identifies what property we want exposed
        cProp
        
        % {uint8 1x1} channel
        u8Channel
    end
    
    methods

        function this = ApiHardwareIOPlusFromKeithley6482(api, cProp, u8Channel) 
            this.api = api;
            this.cProp = cProp;
            this.u8Channel = u8Channel;
        end
        
        function d = get(this) 
            switch this.cProp
                case 'adc-period'
                    d = this.api.getIntegrationPeriod();
                case 'avg-filt-size'
                    d = this.api.getAverageCount(this.u8Channel);
                case 'med-filt-rank'
                    d = this.api.getMedianRank(this.u8Channel);
                case 'range'
                    d = this.api.getRange(this.u8Channel);
                otherwise
                    cMsg = sprintf('WARNING: ApiHardwareIOPlusFromKeithley does not support prop %s', this.cProp);
                    disp(cMsg);
                    
            end
        end
    
        function set(this, dDest) % set new destination and move to it
            switch this.cProp
                case 'adc-period'
                    this.api.setIntegrationPeriod(dDest);
                case 'avg-filt-size'
                    this.api.setAverageCount(this.u8Channel, uint8(dDest))
                case 'med-filt-rank'
                    this.api.setMedianRank(this.u8Channel, uint8(dDest))
                case 'range'
                    this.api.setRange(this.u8Channel, dDest);
                
            end
        end
        
        function l = isReady(this) % true when stopped or at its target
            l = true;
        end
        
        function stop(this) % stop motion to destination
        end
        
        
        function index(this) % index
        end
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
    end
    
end

