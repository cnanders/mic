classdef APIHardwareIOStageXYZRxRy < HandlePlus
    
    % See hungarian.m for help on APIHardwareIO* classes
    
    properties (Access = private)        
        
        cProp
        parent
    end
    

    methods

        function this = APIHardwareIOStageXYZRxRy(parent, cProp)
            
            % cProp:
            % x, y, z, rx, ry           
            
            this.parent = parent; 
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
                case 'rx'
                    dReturn = this.parent.get('rx');
                case 'ry'
                    dReturn = this.parent.get('ry');
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
                case 'rx'
                    this.parent.set('rx', dDest);
                case 'ry'
                    this.parent.set('ry', dDest);
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
                case 'rx'
                    this.parent.stop('rx');
                case 'ry'
                    this.parent.stop('ry');
            end            
        end

    end
    
end

