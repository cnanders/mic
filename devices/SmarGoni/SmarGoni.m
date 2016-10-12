classdef SmarGoni < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
       
        hioRx
        hioRy
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = SmarGoni(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'SmaractMCS-1', ...
                uint8([0, 1, 0]), ...
                'CCD Angle Controller', ...
                {'Rx', 'Ry'}, ...
                 {'hio', 'hio'}, ...
                'met5-pixis.dhcp.lbl.gov'); 
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioRx = this.cehio{1};
            this.hioRy = this.cehio{2};
                        
%             this.hioX.setup.uieStepRaw.setVal(100e-6);
%             this.hioY.setup.uieStepRaw.setVal(100e-6);
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end