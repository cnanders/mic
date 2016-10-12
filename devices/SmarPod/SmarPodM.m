classdef SmarPodM < MultipleAxesControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        
        
        cl
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = SmarPodM(clock)
              
            
            
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MultipleAxesControl( ...
                clock, ...
                'Smarpod-1', ...
                uint8([0, 1, 2, 3, 4, 5]), ...
                'Grating stage 6-axis control', ...
                {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'}, ...
                {'hio', 'hio', 'hio', 'hio', 'hio', 'hio'}, ...
                'met5-pixis.dhcp.lbl.gov'); 
                        
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
    
    end 
    
    
end