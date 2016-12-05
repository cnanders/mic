classdef TestHardwareOPlus < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        ho
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        config                    
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestHardwareOPlus()
              
            this.clock = Clock('master');
            cPathConfig = fullfile(...
                MicUtils.pathConfig(), ...
                'hop', ...
                'default.json' ...
            );
            this.config = Config(cPathConfig);
            
                   
           
            
            this.ho = HardwareOPlus( ...
                'cName', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowZero', true, ...
                'lShowRel', true, ...
                'lShowLabels', false, ...
                'lShowApi', true ...
            );  
       
            % For development, set real Api to Apiv
            
            stParams = struct();
            stParams.cName = sprintf('%s-real', this.ho.cName);
            stParams.clock = this.clock;
            stParams.dPeriod = 0.1;
            stParams.dMean = 5;
            stParams.dSig = 0.5;
            
            apiv = ApivHardwareO(stParams);
            this.ho.setApi(apiv);
            
        end
                
        function build(this, hParent, dLeft, dTop)
           this.ho.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.ho);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end