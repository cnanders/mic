classdef APIHardwareIOnPoint < HandlePlus
        
    
    properties (Access = private)        
        cProp
        parent          % nPoint instance
    end

    methods

        function this = APIHardwareIOnPoint(parent, cProp)
            
            % cProp:
            % ch1-gain-p
            % ch1-gain-i
            % ch1-gain-d
            % ch2-gain-p
            % ch2-gain-i
            % ch2-gain-d            
            
            this.parent     = parent;
            this.cProp      = cProp;
        end
        

        function dReturn = get(this)
            switch this.cProp
                case 'ch1-gain-p'
                    dReturn = this.parent.getGain(1, 'p');
                case 'ch1-gain-i'
                    dReturn = this.parent.getGain(1, 'i');
                case 'ch1-gain-d'
                    dReturn = this.parent.getGain(1, 'd');
                case 'ch2-gain-p'
                    dReturn = this.parent.getGain(2, 'p');
                case 'ch2-gain-i'
                    dReturn = this.parent.getGain(2, 'i');
                case 'ch2-gain-d'
                    dReturn = this.parent.getGain(2, 'd');                
            end

        end


        function set(this, dDest)
            switch this.cProp
                case 'ch1-gain-p'
                    this.parent.setGain(1, 'p', dDest);
                case 'ch1-gain-i'
                    this.parent.setGain(1, 'i', dDest);
                case 'ch1-gain-d'
                    this.parent.setGain(1, 'd', dDest);
                case 'ch2-gain-p'
                    this.parent.setGain(2, 'p', dDest);
                case 'ch2-gain-i'
                    this.parent.setGain(2, 'i', dDest);
                case 'ch2-gain-d'
                    this.parent.setGain(2, 'd', dDest);                
            end
        end 

        function stop(this)
            
            % Do nothing for nPoint 
            
        end

    end
    
end

