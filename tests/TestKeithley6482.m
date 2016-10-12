classdef TestKeithley6482 < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        keithley
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestKeithley6482()
              
            this.clock = Clock('master');
            %{
            cPathConfig = fullfile(...
                pwd, ...
                'config', ...
                'hiop', ...
                'test.json' ...
            );
            config = Config(cPathConfig);
            %}
            this.keithley = Keithley6482(struct(...
                'cName', 'Keithley 6482 A', ...
                'clock', this.clock ...
           ));            
            
        end
        
        
        
        function build(this, hParent, dLeft, dTop)
           this.keithley.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.keithley);
            delete(this.clock);
        end
        
        
        
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end