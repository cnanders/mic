classdef HardwareOPlus < HardwareIOPlus
    

    
    % Hungarian: hop

    properties (Constant)
        
        
    end

    properties      
        
    end

    properties (SetAccess = private)
        
    end

    properties (Access = protected)
        
        
        
    end
    

    events
        
        
    end

    
    methods       
        
        function this = HardwareOPlus(varargin)  
        % This is a HardwareIOPlus with several optional features disabled.  
        % See HardwareIOPlus for required inputs.  This is the lazy
        % approach but I think it is a decent one.
             
            % Add the lDisableI property to varargin. Varargin is {cell
            % 1xm} whose contents alternate prop, value, prop, value.
            % "prop" elements are type char, "value" elments have mixed
            % type
            varargin{length(varargin) + 1} = 'lDisableI';
            varargin{length(varargin) + 1} = true;
            
            % Initialize the object for each superclass within the subclass constructor
            % http://www.mathworks.com/help/matlab/matlab_oop/creating-subclasses--syntax-and-techniques.html

            % The trick to passing varargin through is to not pass varargin
            % directly, because this is equivalent to only passing in one argument.
            % The trick is to use varargin{:} which somehow works.
            
            this@HardwareIOPlus(varargin{:});
            
        end
 

    end %methods
    
    methods (Access = protected)
            

    end

end %class
