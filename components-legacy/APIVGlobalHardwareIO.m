% This virtual API services the global hardware IO found in the
% MultipleAxesControl class.  It is a little different from the hardware IO
% APIV in that it requires a handle back to the parent in order to access
% the uietext fields of the individual hardwareIO objects.
classdef APIVGlobalHardwareIO < HandlePlus

    % apiv

    properties (Access = private)
        cl                      % Clock
        dPathCycles = 100;      % Number of task periods to move through path
        dPathCycle = 1;         % Resets every move
        dPeriod = 100/1000;
    end


    properties
        parent
        cName
        dPos
        dDest
        dPath 
        dNumIOs

    end

            
    methods
        
        function this = APIVGlobalHardwareIO(parent, cName, dPos, cl)
            this.parent  = parent;
            this.cName   = cName;
            this.dPos    = dPos;
            this.dDest   = dPos;  
            this.cl      = cl; 
            this.dNumIOs = length(dPos); 

        end

        function dReturn = get(this)
            dReturn = this.dPos;
        end
        
        function lIsReady = isReady(this)
            lIsReady = this.parent.areChildrenReady();
        end


        function set(this)

            % Reset dPath and dPathCycle and make sure the clock is calling
            % handleClock().  handleClock() advances dPathCycle, updating
            % dDest as dPath(dPathCycle).
            
            this.dDest      = this.parent.getChildrenDest();
            dNumSteps       = 20;
            for k = 1:this.dNumIOs
                this.dPath(k,1:dNumSteps) = linspace(this.dPos(k), this.dDest(k), dNumSteps);
            end
            this.dPathCycle = 1;

            % 2013.07.08 CNA
            % Adding support for Clock

            % this.msg(sprintf('%s.moveAbsolute() calling this.c1.add()', this.id()));

            if ~this.cl.has(this.id())
                this.cl.add(@this.handleClock, this.id(), this.dPeriod);
            else
                this.msg(sprintf('set() not adding %s', this.id()));
            end

            % stop(this.t);
            % start(this.t);

        end 

        function stop(this)
            % stop(this.t);

            this.cl.remove(this.id());
        end

        
        
        
        
       
        function handleClock(this)

            try

                % Update pos
                if (this.dPathCycle <= size(this.dPath, 2))
                    this.dPos = this.dPath(:,this.dPathCycle)';
                end
                
                % RM: when we set this virtual API position, it needs to propagate
                % to the virtual apis of the constituent axes
                this.parent.setChildrenAPIVPos(this.dPos);
                this.parent.setChildrenAPIVDest(this.dDest);
                
                

                % Remove timer when we are finished moving
                if this.isReady()
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

        function delete(this)

            this.msg('delete()');

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

    end %methods
end %class
    

            
            
            
        