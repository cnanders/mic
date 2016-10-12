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
           
            cPathConfig = fullfile(...
                Utils.pathConfig(), ...
                'hiop', ...
                'default-stores.json' ...
            );
        
            this.config = Config(cPathConfig);
            
            
       
       
            stParams = struct(...
                'cName', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowPlay', true, ...
                'lShowDest', true, ...
                'lShowZero', true, ...
                'lShowRel', true, ...
                'lShowJog', true, ...
                'lShowLabels', true, ...
                'lShowAPI', true, ...
                'lShowStores', false, ...
                'fhValidateDest', @this.validateDest ...
           );
            
            this.hio = HardwareIOPlus(stParams);  
       
            % For development, set real API to virtual
            cName = sprintf('%s-real', this.hio.cName);
            apiv = APIVHardwareIO(cName, 0, this.clock);
            this.hio.setApi(apiv);
            
        end
        
        function lOut = validateDest(this)
                        
            if abs(this.hio.destCal(this.config.ceUnits{1}.name)) > 10
                
                
                cMsg = sprintf(...
                    'The destination %1.*f %s ABS (%1.*f %s REL) is now allowed.', ...
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
            this.msg('delete', 5);
            delete(this.hio);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end