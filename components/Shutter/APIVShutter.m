classdef APIVShutter < HandlePlus

    % apivho

    properties (Access = private)
        cl                      % Clock
        dRemainingClockCycles;
        lOpen = false
    end


    properties
        cName
    end

            
    methods
        
        function this = APIVShutter(cName, cl)

            this.cName = cName;
            this.cl = cl; 

        end
        
        function open(this, nMilliSeconds)
        
            this.lOpen = true;
            
            % 2013.07.09 CNA
            % Figure out the number of (master) clock cycles tht occur in
            % the trigger open time.  Each time we call handleClock,
            % decrement the number of remaining cycles by one until there
            % are no more remaining cycles, then update this.lOpen
            
            
            this.dRemainingClockCycles = ceil(nMilliSeconds/1000/this.cl.dPeriod);
            %AW2013-7-22 : Problem in the scanning loop; add a conditional:
            %conflict with Shutter.open who opens it a multiple time
            if ~this.cl.has(this.id())
                this.cl.add(@this.handleClock, this.id(), this.cl.dPeriod);
            end
            
        end
        
        
        function close(this)
        
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end
            
            this.dRemainingClockCycles = 0;
            this.lOpen = false;
        end
        
        function lReturn = isOpen(this)
            lReturn = this.lOpen;
        end
        
        function delete(this)
            
            % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end
                        
        end
                
    end
    
    
    methods(Hidden)
                
        function handleClock(this)
        
            
        %FIXME : the clock might be too slow to handle is....    
        % Decrease dClockCycles by 1 until they reaches 0, then remove
        % the clock task and set lOpen = false
            
            if(this.dRemainingClockCycles > 0)
                this.dRemainingClockCycles = this.dRemainingClockCycles - 1;
            else
                
                % No longer open, remove clock task
                
                if isvalid(this.cl) && ...
                   this.cl.has(this.id())
                    this.cl.remove(this.id());
                end                
                
                this.lOpen = false;
            end
        end
        	
    end
end %class
    

            
            
            
        