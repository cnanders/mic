classdef APIHardwareIOPixis < HandlePlus
        
    
    properties (Access = private)        
        cProp
        parent          % nPoint instance
    end

    methods

        function this = APIHardwareIOPixis(parent, cProp)
            
            % cProp:
            % temperature
            this.parent     = parent;
            this.cProp      = cProp;
        end
        

        function dReturn = get(this)
            switch this.cProp
                case 'temperature'
                    dReturn = this.parent.getTmp();
                case 'temperature-setpoint'
                    dReturn = this.parent.getTmpSetpoint();              
            end

        end


        function set(this, dVal)
            switch this.cProp
                case 'temperature-setpoint'
                    this.parent.setTmpSetpoint(dVal);
                case 'ch1-gain-d'
                    this.parent.setGain(1, 'd', dVal);
                case 'ch2-gain-p'
                    this.parent.setGain(2, 'p', dVal);
                case 'ch2-gain-i'
                    this.parent.setGain(2, 'i', dVal);
                case 'ch2-gain-d'
                    this.parent.setGain(2, 'd', dVal);                
            end
        end 

        function stop(this)
            
            % Do nothing for nPoint 
            
        end

    end
    
end

