classdef TestHardwareIOPlus < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        hio
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        config                    
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestHardwareIOPlus()
              
            this.clock = Clock('master');   
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

            cPathConfig = fullfile(...
                cDirThis, ...
                'config-default-offset-invert.json' ...
            );

            this.config = ConfigHardwareIOPlus(cPathConfig);
            
            
             %'lShowLabels', false, ...
                %'lShowJog', false, ...
                % 'lShowZero', false, ...
                % 'lShowRel', false, ...
                
            this.hio = HardwareIOPlus(...
                'cName', 'abc', ...
                'cLabel', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowStores', true, ...
                'lShowUnit', true, ...
                'lShowInitButton', true, ...
                'lShowInitState', false, ...
                'lShowRange', true, ...
                'cConversion' , 'e', ... % exponential notaion
                'fhValidateDest', @this.validateDest ...
            );
            %  this.hio = HardwareIOPlus();
       
            % For development, set real Api to virtual
            cName = sprintf('%s-real', this.hio.cName);
            apiv = ApivHardwareIOPlus(cName, 0, this.clock);
            this.hio.setApi(apiv);
            
        end
        
        function lOut = validateDest(this)
                        
            if abs(this.hio.destCal(this.config.ceUnits{1}.name)) > 10
                
                
                cMsg = sprintf(...
                    'The destination %1.*f %s ABS (%1.*f %s REL) is not allowed.', ...
                    this.hio.unit().precision, ...
                    this.hio.destCal(this.hio.unit().name), ...
                    this.hio.unit().name, ...
                    this.hio.unit().precision, ...
                    this.hio.destCalDisplay(), ...
                    this.hio.unit().name ...
                );
                cTitle = sprintf('Position not allowed');
                msgbox(cMsg, cTitle, 'warn')
                
                                
                
                lOut = false;
            else 
                lOut = true;
            end
        end
        
        function build(this, hParent, dLeft, dTop)
           this.hio.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete()');
            
            delete(this.hio);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end