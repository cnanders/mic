classdef TestHardwareIOText < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        hiotx
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        config                    
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestHardwareIOText()
              
            this.clock = Clock('master');
           
            cPathConfig = fullfile(...
                MicUtils.pathConfig(), ...
                'hiotx', ...
                'default.json' ...
            );
                    
            this.config = ConfigHardwareIOText(cPathConfig);
                
            this.hiotx = HardwareIOText(...
                'cName', 'abc', ...
                'cLabel', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', true ...
            );
            %  this.hio = HardwareIOPlus();
       
            % For development, set real Api to virtual
%             cName = sprintf('%s-real', this.hio.cName);
%             apiv = ApivHardwareIOPlus(cName, 0, this.clock);
%             this.hio.setApi(apiv);
            
        end
                
        function build(this, hParent, dLeft, dTop)
           this.hiotx.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.hiotx);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end