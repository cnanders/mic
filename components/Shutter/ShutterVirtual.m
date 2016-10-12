classdef ShutterVirtual < HandlePlus
%SHUTTERVIRTUAL Class that simulates the behavious of a shutter
%   sv = ShutterVirtual('name', clock)
%   See also SHUTTER, AXISVIRTUAL, DIODEVIRTUAL
    
    
    properties    
        cName;          % name identifier
        lOpen = false   % boolean that tells whether the virtual sh is open  
    end
    
    properties (Access = private)
       cl       % clock
       dRemainingClockCycles = 0; % number of remaining cycles
    end
    
    methods
        
    % Pre-clock, ShutterVirtual had a timer with ExecutionMode ==
    % 'singleShot'.  Start delay was set to the number of seconds and
    % the timer would be started.  Now I'm going to piggy-back off of
    % the clock so resolution will be limited to the resolution of the
    % master clock.

    % The goal of this method is after the open() call, set lOpen =
    % true for an amount of time. 
        
        function this = ShutterVirtual(cName, cl)
        %SHUTTERVIRTUAL Class constructor
        %   sv = ShutterVirtual('name', clock)
        %
        % See also INIT, BUILD, DELETE
            
            this.cName = cName;
            this.cl = cl;
             
            %{
            this.t = timer( ...
                'TimerFcn', @this.cb, ...
                'Period', 0.2, ...
                'ExecutionMode', 'singleShot', ...
                'Name', sprintf('ShutterVirtual (%s)', this.cName) ...
                );
            %}         
        end
        
            
        function open(this, nMilliSeconds)
        %OPEN Opens a virtual shutter for a certain mount of time in ms
        %   ShutterVirtual.open(nMiliseconds)
        %
        % See also ISOPEN, CLOSE
            
            this.lOpen = true;
            
            % 2013.07.09 CNA
            % Figure out the number of clock cycles in nMilliSeconds and
            % add a task with the period of the clock
            
            this.dRemainingClockCycles = ceil(nMilliSeconds/1000/this.cl.dPeriod);
            %AW2013-7-22 : Problem in the scanning loop; add a conditional:
            %conflict with Shutter.open who opens it a multiple time
            if ~this.cl.has(this.id())
                this.cl.add(@this.handleClock, this.id(), this.cl.dPeriod);
            end
            
            %{
            % Legacy
            set(this.t, 'StartDelay', nMilliSeconds/1000);
            start(this.t);
            %}
        end
        
        function lReturn = isOpen(this)
        %ISOPEN Tells whether the virtual shutter is open or not
        %   lIsOpen = ShutterVirtual.IsOpen()
        %
        % See also OPEN, CLOSE
            lReturn = this.lOpen;
        end

        
        function close(this)
        %CLOSE Closes the virtual shutter
        %   ShutterVirtual.close()
        %
        %   See also OPEN, ISOPEN
        
            if this.cl.has(this.id())
                this.cl.remove(this.id());
            end
            
            this.dRemainingClockCycles = 0;
            this.lOpen = false;
        end
                
        
        function delete(this)
        %DELETE Class destructor
        %   ShutterVirtual.delete()
        %
        % See also SHUTTERVIRTUAL, INIT
            
            % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end
            
            
            %{
            if isvalid(this.t)
                % stop timer and delete
                if strcmp(this.t.Running, 'on')
                    stop(this.t);
                end
                delete(this.t);
            end
            %}
            
        end
                
    end
    
    
    methods(Hidden)
                
        function handleClock(this)
        %HANDLECLOCK Callback triggered by the clock
        %   ShutterVirtual.HandleClock()
        %   updates the status of the virtual shutter
        
        %FIXME : the clock might be too slow to handle is....    
        % Decrease dClockCycles by 1 until they reaches 0, then remove
        % the clock task and set lOpen = false
            
            if(this.dRemainingClockCycles > 0)
                this.dRemainingClockCycles = this.dRemainingClockCycles - 1;
            else
                if this.cl.has(this.id())
                    this.cl.remove(this.id());
                end
                this.lOpen = false;
            end
        end
        
        
	%% Legacy
       %{      
        function cb(this, src, evt)
            %FIXME seems to be unused
            this.lOpen = false;
        end
        
                
        function enable(this)
            this.msg('ShutterVirtual.enable()');
            
        end
        
        function disable(this)
            this.msg('ShutterVirtual.disable()');
        end
        
        function close(this)
            try
                if isvalid(this.t)
                    
                    if strcmp(this.t.Running, 'on')
                        stop(this.t);
                    end
                    this.lOpen = false;
                end
            catch err
                this.msg(getReport(err));
            end
        end
        %}
    end
        
end
    

            
            
            
        