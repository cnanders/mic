classdef AxisVirtual < HandlePlus
%AXISVIRTUAL Class that simulates the behavious of an axis
%
% See also AXIS, DIODEVIRTUAL

    properties
        cName       % name identifier
        dPos        % current position
        dDest       % current target position
        dPath       % folder path
    end

    properties (Access = private)
        cl                      % clock
        dPathCycles = 100;      % number of task periods to move through path
        dPathCycle = 1;         % resets every move
        dPeriod = 100/1000;
    end

    methods       

        function this = AxisVirtual(cName, dPos, cl)
        %AXISVIRTUAL Class Constructor
        % av  AxisVirtual('name',dInitialPosition , clock)
        
            this.cName = cName;
            this.dPos = dPos;
            this.dDest = dPos;  
            this.cl = cl;

            %{
            this.t = timer( ...
                'TimerFcn', @this.cb, ...
                'Period', 0.2, ...
                'ExecutionMode', 'fixedRate', ...
                'Name', sprintf('AxisVirtual (%s)', this.cName) ...
            );
            %}
            

        end

        
        function dReturn = getPosition(this)
        %GETPOSITION Returns the absolute virtual axis current positon
        %   dPositionAbsolute = AxisVirtual.getPosition()
        %
        % See also MOVEABSOLUTE, STOPMOVE, ISSTOPPED
        
            dReturn = this.dPos;
        end


        function i8Return = moveAbsolute(this, dDest)
        %MOVEABSOLUTE Moves to stage to a specified position
        %   isOK = AxisVirtual.moveAbsolute(dDestAbs)
        %
        % See also GETPOSITION, ISSTOPPED, GETPOSITION
            
            % 2013.07.08 CNA
            % Adding support for Clock
            this.dDest = dDest;
            this.dPath = linspace(this.dPos, this.dDest, 20);
            this.dPathCycle = 1;

            % this.msg(sprintf('%s.moveAbsolute() calling this.c1.add()', this.id()));
            if ~this.cl.has(this.id())
                this.cl.add(@this.handleClock, this.id(), this.dPeriod);
            else
                this.msg('AxisVirtual.moveAbsolute() NOT adding clock task');
            end

            % stop(this.t);
            % start(this.t);

            i8Return = int8(0);
        end 

        
        function i8Return = stopMove(this)
        %STOPMOVE Stops the virtual motion and removes the task from clock
        %   AxisVirtual.stopMove()
        %
        % See also MOVEABSOLUTE, ISSTOPPED, GETPOSITION
        
            % stop(this.t);
            this.cl.remove(this.id());
            i8Return = int8(0);
        end
        
        
        function lReturn = isStopped(this)
        %GETPOSITION Returns the absolute virtual axis current positon
        %   lIsStopped = AxisVirtual.isStopped()
        %
        % See also GETPOSITION, MOVEABSOLUTE, STOPMOVE
        
            if this.dDest == this.dPos
                lReturn = true;
            else
                lReturn = false;
            end
        end

        
        function enable(this)
        %ENABLE [Not implemented...] Enables the virtual axis (=motorOn)
        %   AxisVirtual.enable()
        %
        % see also DISABLE
        
            this.msg('AxisVirtual.enable()');
        end

        function disable(this)
        %DISABLE [Not implemented...] Disables the virtual axis (=motorOff)
        %   AxisVirtual.disable()
        %
        % see also ENABLE
        
            this.msg('AxisVirtual.disable()');
        end

        function delete(this)
        %DELETE Class destructor
        %   AxisVirtual.delete()
        %   Removes the axisVirtual from the clock tasklist

            %this.msg('AxisVirtual.delete()');
            % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end

        end
        
        
    end
    
    methods(Hidden)
        function handleClock(this)
        %HANDLECLOCK Callback triggered by the clock
        %   AxisVirtual.HandleClock()
        %   causes the virtual axis to move and update

            try
                % Update pos
                this.dPos = this.dPath(this.dPathCycle);

                % Do we need to stop the timer?
                if this.dPos == this.dDest
                    this.cl.remove(this.id());                
                end

            catch err
                this.msg(getReport(err));
            end

            % Update counter
            if this.dPathCycle < this.dPathCycles
                this.dPathCycle = this.dPathCycle + 1;
            end

        end
        
    end %methods
end %class
    

            
            
            
        