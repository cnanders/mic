classdef APIVHardwareIO < InterfaceAPIHardwareIO

    % apiv

    properties (Access = private)
        cl                      % Clock

        dPathCycle = 1;         % Resets every move
        dPeriod = 20/1000;
    end


    properties

        cName;
        dPos
        dDest
        dPath 
        dPathCycles = 10;      % Number of task periods to move through path

    end

            
    methods
        
        function this = APIVHardwareIO(cName, dPos, cl)

            this.cName = cName;
            this.dPos = dPos;
            this.dDest = dPos;  
            this.cl = cl;            

        end

        function dReturn = get(this)
            dReturn = this.dPos;
        end


        function lIsReady = isReady(this)
            lIsReady = this.dPos == this.dDest;
        end
        
        
        function set(this, dDest)

            % Reset dPath and dPathCycle and make sure the clock is calling
            % handleClock().  handleClock() advances dPathCycle, updating
            % dDest as dPath(dPathCycle).
            
            this.dDest = dDest;
            this.dPath = linspace(this.dPos, this.dDest, this.dPathCycles);
            this.dPathCycle = 1;

            % 2013.07.08 CNA
            % Adding support for Clock

            % this.msg(sprintf('%s.moveAbsolute() calling this.c1.add()', this.id()));

            if ~this.cl.has(this.id())
                this.cl.add(@this.handleClock, this.id(), this.dPeriod);
            else
                this.msg(sprintf('set() not adding %s', this.id()), 5);
            end

            % stop(this.t);
            % start(this.t);

        end 

        function stop(this)
            % stop(this.t);

            % Set destination to current position so subsequent calls to
            % isReady() returns true
            this.dDest = this.dPos;
            this.cl.remove(this.id());
        end

       
        function handleClock(this)

            try


                % Update pos
                this.dPos = this.dPath(this.dPathCycle);
                
                this.msg(sprintf('handleClock() updating dPos to %1.3f', this.dPos), 5);

                % Do we need to stop the timer?
                if (this.dPos == this.dDest)
                    this.cl.remove(this.id());                
                end

            catch err
                this.msg(getReport(err), 2);
            end

            % Update counter
            if this.dPathCycle < this.dPathCycles
                this.dPathCycle = this.dPathCycle + 1;
            end

        end

        function delete(this)

            this.msg('delete()', 5);

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
                % set(this.t, 'TimerFcn', null);
                delete(this.t);
            end
            %}

        end
        
        function index(this)
            % Need to implement this
        end
        
        

    end %methods
end %class
    

            
            
            
        