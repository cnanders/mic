classdef ClockTest < HandlePlus
%CLOCKTEST Test class for the Clock class    
% usage:
%   cl = Clock('test clock')
%   ct = ClockTest('clock test', cl)
%
% See also CLOCK
    
    % cl
    
    properties (SetAccess = private) 
        cl      % clock
        cName   % name identifier
    end
    
    properties (Access = private)
	end
    
    properties            
    end
    
    events
	end
    
    methods
        
        function this = ClockTest(cName, cl)
        %CLOCKTEST Class constructor
        %   ct = ClockTest('name', clock)
            this.cName = cName;
            this.cl = cl;
            this.add();
        end
        
        function add(this)
        %ADD Adds three task to the clock    
            this.cl.add(@this.handleClock, [class(this), ':', this.cName, '.handleClock()a'], 5/1000);
            this.cl.add(@this.handleClock, [class(this), ':', this.cName, '.handleClock()b'], 5/1000);
            this.cl.add(@this.handleClock, [class(this), ':', this.cName, '.handleClock()c'], 5/1000);
        end
        
        function remove(this)
        %REMOVE Removes task a from the clock tasklist.
            this.cl.remove([class(this), ':', this.cName, '.handleClock()a']);
        end
        
        
        function handleClock(this)
        %HANDLECLOCK Callback executed by the clock
            this.msg(sprintf('ClockTest.handleTic() %s', this.cName));
        end
        
        function delete(this)
        %DELETE Class destructor
            this.cl.remove([class(this), ':', this.cName, '.handleClock()a']);
            this.cl.remove([class(this), ':', this.cName, '.handleClock()b']);
            this.cl.remove([class(this), ':', this.cName, '.handleClock()c']);
        end
                
    end
end