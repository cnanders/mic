classdef ApiHardwareIOTextFromKeithley6482 < InterfaceApiHardwareIOText

    properties (Access = private)
        
        % {< InterfaceKeithley6482 1x1} 
        api
        
        % {char 1xm} identifies what property we want exposed
        cProp
        
        % {uint8 1x1} channel
        u8Channel
    end
    
    methods

        function this = ApiHardwareIOTextFromKeithley6482(api, cProp, u8Channel) 
            this.api = api;
            this.cProp = cProp;
            this.u8Channel = u8Channel;
        end
        
        function c = get(this) % retrieve value
            switch this.cProp
                case 'avg-filt-state'
                    c = this.api.getAverageState(this.u8Channel);
                case 'avg-filt-type'
                    c = this.api.getAverageType(this.u8Channel);
                case 'avg-filt-mode'
                    c = this.api.getAverageMode(this.u8Channel);
                case 'auto-range-state'
                    c = this.api.getAutoRangeState(this.u8Channel);
                case 'med-filt-state'
                    c = this.api.getMedianState(this.u8Channel);
                otherwise
                    cMsg = sprintf('WARNING: ApiHardwareIOTextFromKeithley does not support prop %s', this.cProp);
                    disp(cMsg);
                
            end
        end
    
        function set(this, cVal) % set new destination and move to it
            switch this.cProp
                case 'avg-filt-state'
                    this.api.setAverageState(this.u8Channel, cVal);
                case 'avg-filt-type'
                    this.api.setAverageType(this.u8Channel, cVal);
                case 'avg-filt-mode'
                    this.api.setAverageMode(this.u8Channel, cVal);
                case 'auto-range-state'
                    this.api.setAutoRangeState(this.u8Channel, cVal);
                case 'med-filt-state'
                    this.api.setMedianState(this.u8Channel, cVal);
                
                    
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

