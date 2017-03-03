classdef StateScan < HandlePlus
    
    % Event-based class that scans a system through a list of states.  One
    % constraint is that the scan must use the the same units for every
    % state.
    %
    % You can imagine passing in a list of states that looks like this
    % (assumes two degrees of control, x and y) (JSON):
    %
    %   [
    %       {
    %           "x": {
    %               "value": 1,
    %               "unit": "mm"
    %           },
    %           "y": {
    %               "value": 1,
    %               "unit": "mm"
    %           }
    %       },
    %       {
    %           "x": {
    %               "value": 2,
    %               "unit": "mm"
    %           },
    %           "y": {
    %               "value": 1,
    %               "unit": "mm"
    %           }
    %       }
    %   ]
    %
    % where the unit is stored along with the val of every property of
    % every state.  This would be OK, but it is easier to read if instead
    % the units are declared at the top and the states only contain the
    % values.  This also implicitly constrains the scan to not changing
    % units midway which is a good thing (imagine plotting a scan result
    % where the units changed midway).  Here is an example.
    %
    %   {
    %       "unit": {
    %           "x": "mm",
    %           "y": "mm"
    %       },
    %       "values": [
    %           {
    %               "x": 1,
    %               "y": 1
    %           },    
    %           {
    %               "x": 2,
    %               "y": 1
    %           }
    %       ]
    %   }
    %
    % this will be referred to as a "recipe" for the scan.  It defines the
    % unit structure and a list of state value structures
    %
    % The parent that instantiantes this StateScan instance produces and
    % consumes the recipe, including the unit definition and each state definition.
    % provid.  recipe.unit and recipe.states[n] will be passed to each call
    % to setState() isAtState().
    %
    % RECIPE must only contain two properties: "unit" {struct} and "values"
    % {cell of struct}
    
    
    
    properties (Constant)
        dHeight = 30;
    end
    
    properties
        
        
 
    end
    
    properties (SetAccess = private)
       
       u8Index  % index of the state list that is currently executing
       ceValues % {cell of struct} list of value structures that define each state
       stUnit
        
    end
    
    properties (Access = private)
       
       dDelay = 0.02;   % how often isThere() is called
       
       cl
       fhSetState % see constructor
       fhIsAtState % see constructor
       fhAcquire % see constructor
       fhIsAcquired
       fhOnComplete
       fhOnAbort
       lPaused = false;
       
    end
    
    
    events
      eNewStateStart
      eNewStateCheck
      eNewStateEnd
      eAcquireStart
      eAcquireEnd
      eScanComplete
      
    end
    
    
    methods
        
       % constructor
       
        function this= StateScan( ....
                cl , ...
                stRecipe, ...
                fhSetState, ...
                fhIsAtState, ...
                fhAcquire, ...
                fhIsAcquired, ...
                fhOnComplete, ...
                fhOnAbort)
          
        %   @param {clock} cl - the clock
        %   @param {struct} stRecipe - see below
        %       @prop {struct} unit - defines the unit of
        %           every degree of freedom that will be controlled.  See notes
        %           at the top of this class for more explanation.
        %       @prop {cell of any} values - list of value structures that
        %           define each state. 
        %   @param {function_handle} fhSetState(stUnit, stState) - function to update the
        %        N-dimensional (N-motor / N-degree-of-freedom) destination 
        %        of the system and tell the system to go to the destination.
        %        The consumer of this function is responsible for handling
        %        any order of operations, etc. to bring the system to the
        %        state. 
        %        @param {struct} stUnit - the unit definition structure 
        %        @param {struct} stState - the state
        %    @param {function_handle} fhIsAtState(stUnit, stState) - function that receives a
        %        state and returns a logical to indicate if they system is
        %        at that state
        %        @param {struct} stUnit - the unit definition structure 
        %        @param {struct} stState - the state
        %        @returns {logical} - true if the system is at the state
        %    @param {function_handle} fhAcquire - function that performs a
        %        measurement
        %    @param {function_handle} fhIsAcquired - return true if the
        %       acquire process for the current state is complete.
        %    @param {function_handle} fhOnComplete - function to call when
        %       scan has completed successfully.
        %    @param {function_handle} fhOnAbort - function to call when scan
        %       was stopped prematurely
       
            this.cl = cl;
            this.stUnit = stRecipe.unit;
            this.ceValues = stRecipe.values;
            this.fhSetState = fhSetState;
            this.fhIsAtState = fhIsAtState;
            this.fhAcquire = fhAcquire;
            this.fhIsAcquired = fhIsAcquired;
            this.fhOnComplete = fhOnComplete;
            this.fhOnAbort = fhOnAbort;
            
        end
       
        function start(this) 
        %START start the scan 
            this.u8Index = 1;
            this.go();
            
        end

        function pause(this) 
        %PAUSE pause the scan
        
            % If StateScan is paused while the system is settling to a new
            % state, the clock task that is asking the system if it has
            % settled is removed and u8Index remains the same.  If motors
            % need to be stopped, it is assumed that the parent class takes
            % care of that.  When theS StateScan is unpaused, go() is
            % called which restarts the scan at the u8Index item of
            % ceValues
            % 
            % If StateScan is paused while the system is in the middle of
            % acquiring, StateScan waits for isAcquired to return true,
            % increments u8Index but then does not call go() to begin the
            % the set-wait-acquire process for the next state.
            
            if (~this.lPaused)
               this.lPaused = true; 
            else
               this.msg('Already paused'); 
            end
                        
        end

        function resume(this) 
        %PAUSE resume the scan
            if (this.lPaused)
                this.lPaused = false;
                this.go();
            else
               this.msg('Was not paused.'); 
            end
        end

        function stop(this)
        %STOP abort the scan, reset back to start index
        
            % 2017.02.02 Be advised that is is possible to call this in the
            % middle of an acquire.  Make sure that fhOnAbort doesn't
            % modify anything that would be unexpected in the middle of the
            % acquire.
            
             this.removeClockTask();
             % this.u8Index = 1;
             
             % notify(this,'eScanComplete');
             this.fhOnAbort(this.stUnit);

        end
       
       
    end
    
    methods (Access = protected)
        
        function go(this)
        %GO call fhSetState with state at u8Index of the list, wait for the
        %system to get to the state, call fhAcquire, wait for acquire to
        %complete, which increments u8Index and calls go again
           
            this.fhSetState(this.stUnit, this.ceValues{this.u8Index});
            
            % Start checking the state
            this.cl.add(@this.handleClockIsAtState, this.id(), this.dDelay); 
            
        end
        
        
        function handleClockIsAtState(this)
            
            % this.msg('handleClockIsAtState');
            
            if (this.lPaused)
                this.removeClockTask();
                return;
            end
            
            if (this.fhIsAtState(this.stUnit, this.ceValues{this.u8Index}))
             
                this.removeClockTask();
                
                % Call acuire, passing in units
                this.fhAcquire(this.stUnit);
                
                % Start checking for acquire complete
                this.cl.add(@this.handleClockIsAcquired, this.id(), this.dDelay);
                                
            end
            
        end
        
        
        function handleClockIsAcquired(this)
            
            % this.msg('handleClockIsAcquired');
            
            if (this.fhIsAcquired())
             
                % Remove the clock task
                this.removeClockTask();
                
                if (this.u8Index < length(this.ceValues))
                    
                   this.u8Index = this.u8Index + 1;
                   
                   if (~this.lPaused)
                        this.go();
                   end
                    
                else
                    
                    % No more values.  Done
                    this.fhOnComplete(this.stUnit);

                end
                
                                
            end
            
        end
        
        function removeClockTask(this)
            
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end 
            
        end
        
        function delete(this)
            
            this.removeClockTask();
            
        end
        
    end

end
