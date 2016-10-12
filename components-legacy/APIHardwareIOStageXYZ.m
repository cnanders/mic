classdef APIHardwareIOStageXYZ < HandlePlus
    
    % See hungarian.m for help on APIHardwareIO* classes
    
    properties (Access = private)        
        
        cProp
        parent
    end
    

    methods

        function this = APIHardwareIOStageXYZ(parent, cProp)
            
            % cProp:
            % x, y, z           
            
            this.parent = parent; % instance of ReticleCoarseStage
            this.cProp = cProp;
        end
        

        function dReturn = get(this)
            switch this.cProp
                case 'x'
                    dReturn = this.parent.get('x');
                case 'y'
                    dReturn = this.parent.get('y');
                case 'z'
                    dReturn = this.parent.get('z');
                
            end

        end


        function set(this, dDest)
            switch this.cProp
                case 'x'
                    this.parent.set('x', dDest);
                case 'y'
                    this.parent.set('y', dDest);
                case 'z'
                    this.parent.set('z', dDest);

            end
        end 

        function stop(this)
            switch this.cProp
                case 'x'
                    this.parent.stop('x');
                case 'y'
                    this.parent.stop('y');
                case 'z'
                    this.parent.stop('z');

            end            
        end

    end
    
end

