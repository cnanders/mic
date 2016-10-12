classdef SmarPod < MotionControl
    
    % rcs
    
    properties (Constant)

    end
    
	properties
        
        hioX
        hioY
        hioZ
        hioRx
        hioRy
        hioRz
        
        cl
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = SmarPod(clock)
              
            
            
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'Smarpod-1', ...
                uint8([0, 1, 2, 3, 4, 5]), ...
                'Grating stage 6-axis control', ...
                {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'}, ...
                {'hio', 'hio', 'hio', 'hio', 'hio', 'hio'}, ...
                'met5-pixis.dhcp.lbl.gov'); 
                        
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioX = this.cehio{1};
            this.hioY = this.cehio{2};
            this.hioZ = this.cehio{3};
            this.hioRx = this.cehio{4};
            this.hioRy = this.cehio{5};
            this.hioRz = this.cehio{6};
                        
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
    
    end 
    
    
end