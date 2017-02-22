classdef TestGetSetText < mic.Base
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        ui
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        config                    
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestGetSetText()
              
            this.clock = mic.Clock('master');
            this.config = mic.config.GetSetText();
            this.ui = mic.ui.device.GetSetText(...
                'cName', 'abc', ...
                'cLabel', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'dWidthName', 100, ...
                'lShowStores', true ...
            );
            %  this.hio = HardwareIOPlus();
       
            % For development, set real Api to virtual
%             cName = sprintf('%s-real', this.hio.cName);
%             apiv = ApivHardwareIOPlus(cName, 0, this.clock);
%             this.hio.setApi(apiv);
            
        end
                
        function build(this, hParent, dLeft, dTop)
           this.ui.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.ui);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end