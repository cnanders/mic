classdef Msg
    
    properties (Constant)
        
      
    end
    
    methods (Static)
        
        function print(cMsg)
            
            % similar to disp() except that channeling every fprintf or
            % disp through this method lets us easily eliminate all print
            % or only show certain ones.  I've found it really helpful in
            % other projects to do something like this.  Especially
            % event-based projects.  Also, if you make the message prefixed
            % with the class name, you can put logic in here to only echo
            
            fprintf('%s\n', cMsg);
                        
        end
        
            
    end % Static
end

