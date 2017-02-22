classdef Clock < mic.Base
%Clock A Class that allows for a coherent dispatching of task 
% over an ensemble of procedures
%   cl = Clock('name') creates a Clock instance called 'name'
%
%   example of use:
%    cl = Clock('my Clock');
%    ax = Axis('my Axis', cl);
%    ax.build(h,0,0);
%
% See also CLOCKTEST

% Try using event listeners instead of passing the function handle and
% storing it.  This is taking too much time

% addlistener(this.cl, 'e20ms', @this.handleUI);
% addlistener(this.cl, 'e30ms', @this.handleUI);

% There are two ways to do this.  One way is to have the clock dispatch
% different types of events based on the interval that has gone by. The
% other way is to just have it always dispatch the 'tic' event and have
% all of the listeners have logic to execute or not
    
    
    %TODO add pause

    % cl = Clock(cName)
    
    %{
    Notes:
    
    PROBLEM DESCRIPTION (NEVER DELETE THIS DISCUSSION)
    
    When building Clock, we found out that adding / removing tasks was
    slow.  Upon investigation we realized why.  For adding, we had to push
    an additional function handle to the cell array of function handles
    (ceTaskFcn).  When the cell didn't have enough memory allocated to
    store the additional function handle, Matlab would (behind the scenes)
    create an entire new cell allocated with just enough memory and then
    delete the old cell.  This 'create a new one with more memory and
    delete the old one' took lots of time, and the time increased as the
    number of items in the cell increased.  For example, adding the 50th
    task would take 300 ms (!!)
    
    Oddly enough, this super long assignment does not happen when the cell
    is not a property of a handle class.  For example, the code below which
    copies this.ceTaskFcn to a local variable and pushes a new function
    handle to the cell is blazing fast and the execution time is not
    dependent on the number of itesm in this.ceTaskFcn (I only tested up to
    60 items, but there was no difference in execution time as the number
    of items in this.ceTaskFcn increased)
    
    // Code
    tic;
    ceTaskFcn = this.ceTaskFcn;
    toc;

    this.msg('append new fh to copy');
    tic;
    ceTaskFcn{dCount} = fhTmp;
    toc;
    
    // Output
    copy this.ceTaskFcn
    Elapsed time is 0.000017 seconds.
    append new fh to copy
    Elapsed time is 0.000081 seconds.
    
    
    This means there is definitely additional overhead involved with
    dealing with cell arrays of function handles as properties of a handle
    class, specifically with assignment to the cell and deletion of items
    in the cell (I explain the delete issue below)
    
    
    On the delete side, something similar happened but I don't think it had
    to do with memory, per-se.  When I remove a task I would do a
    this.ceTaskFcn(lItems) = []; to purge those items from the cell.
    Deleting an item that is not at the end required a rearrangement of the
    indicies of many of the items in the cell and this was also slow.  I'm
    not sure if matlab does the delete, and create new thing here as well
    but this was a slow process.  With 30 HardwareIO instances (roughly 30
    tasks), doing a remove took took about 92 ms to remove the function
    handle from the cell as shown below.  As a rule, removing a
    function_handle takes very long, removing a char takes 100s of us,
    and removing a double takes 30 us
    
    this.ceTaskFcn(lItems) = []
    Elapsed time is 0.096125 seconds.
    this.ceTaskName(lItems) = []
    Elapsed time is 0.000117 seconds.
    this.ceTaskPeriod(lItems) = []
    Elapsed time is 0.000030 seconds.
    
    With twice the number of the items in the cell (60 HardwareIO instances
    built as compared to 30 before), it takes twice as long to remove a
    function_handle from the cell but removing the double and char still
    takes the same length of time
    
    this.ceTaskFcn(lItems) = []
    Elapsed time is 0.179634 seconds.
    this.ceTaskName(lItems) = []
    Elapsed time is 0.000054 seconds.
    this.ceTaskPeriod(lItems) = []
    Elapsed time is 0.000027 seconds.
    
    
    SOLUTIONS
    
    The solution to the "add" problem is to pre-allocate ceTaskFcn with a
    enough memory that whenever we add a task to it, there is enough memory
    allocated that it never does the 'delete + create new' process in the
    background.
    
    Unfortunately, there is not a good way to pre-allocate memory to the
    cell array, other than filling it with actual function_handle
    instances.  This really sucks and could be bad news for our list of
    tasks since now ceTaskFcn would have a bunch of 'fake' function_handles
    in it and each clock cycle they would exeucte.  Luckily the way I
    structured things makes this problem go away.

    I use:
    (cefh == cell of function_handle)
    (ced == cell of double)
    (cec == cell of char)
    
    cell (1 x m) of functional_handle to store the function_handle of each task
    cell (1 x m) of char to store the name of each task
    double (1 x m) to store the period of each task

    
    if I don't push an item to the period or name cells when I pre-allocate
    items to cefh, then I can use ced and cec to search for tasks that need
    to be executed, rather than looking through cefh
    
    To make the delete process fast, I'm going to store a fourth piece of
    information:
    
    logical (1 x m) to store if a particular task is active.  The idea here
    is that removing a task just means setting lTaskActive(index) = false.
    This doesn't actually purge the task from dTaskPeriod or ceTaskFcn, it
    just says that if index = find(lTaskActive == false), then
    dTaskPeriod(index) and ceTaskFcn(index) can be overwritten with new
    tasks.  This is similar to how things are deleted in a hard drive - the
    bits are not re-set to zero, there is just a pointer that says "hey
    the bits at these addresses are free to be overwritten if needed". 
 
    When I add a task, I will first check to see if there any available
    spaces to put the new task.  If not, it will be appended to the end of
    the list
    
    This means that at any time ceTaskFcn, dTaskPeriod, and ceTaskName will
    contain tasks that are not active anymore.  This is nothing wrong with
    this, we just need to be aware of it.  
    
    With these strategies, Clock can be blazing fast becauase we will
    never need to increase the memory allocated to ceTaskFcn or re-arrange
    the items in ceTaskFcn (memory/time intensive).    
    %}
    
    
    
    
    
    %% Properties
    
	properties
        cName % name ('identifier') of the Clock
    end
    
    properties (SetAccess = private)
        dPeriod       % Clock period
    end
    
    properties (Access = private)
        lBusy = false;
        lEcho = false;                      % Print statements
        t                                   % Timer
        
        
        
        %{ 
        --- DEPRECATED
        
        % Store tasks as an array of structures
        
        % Initialize 0x0 struct array with fields:
        %       fhFcn
        %       cName
        %       dPeriod
        %       dLastExecution
        %       lRemove
        
        
        % Although most MATLAB fundamental data types support
        % multidimensional arrays, function handles must be scalars (single
        % elements). However, you can store multiple function handles using
        % a cell array or structure array. The most common approach is to
        % use a cell array, such as
    
        % stTasks:struct (1x1) with the following properties:
        %   ceTaskFcn:cell of type function_handle          (1xm)
        %   ceTaskName:cell of type char                    (1xm)
        %   dPeriod:double                              (1xm)
        %   lRemove:logical                             (1xm)
 
        % stTasks = struct('ceTaskFcn', {}, 'ceTaskName', {}, 'dPeriod', [], 'lRemove', [])

        --- END DEPRECATED
       
        %}
        
        
        %0x0 cell
        ceTaskFcn       = {};       % list of actions to perform
        %0x0 cell
        ceTaskName      = {};       % list of task names
        %0x0 double
        dTaskPeriod     = [];       % list of task periods
        %0x0 logical
        lTaskActive     = true(0);  % mask of active task
        
        % ceTaskName, dTaskPeriod, and lTaskActive will always be the same size
        
        dTicks = 0;             % 
        
        
            
    end
    
    events
    end
    
    methods
%% Methods
        function this = Clock(cName, dPeriod)
        %CLOCK Creates an instance of a clock class
        %   cl = Clock('name')
        %
        % See also INIT, BUILD, DELETE
            
            if nargin == 1
                dPeriod = 50/1000;
            end
            
            this.dPeriod = dPeriod;
            this.cName = cName;
            this.init();
        end
        
        function dReturn = getPeriod(this)
            dReturn = this.dPeriod;
        end
        
        function init(this)
        %INIT Initializes the clock
        %   cl.init()
        %   It is primarily meant to be called by the constructor
        %
        % See also CLOCK, BUILD, DELETE
              
            % Pre-fill ceTaskFcn
            
            % this.msg('Clock.init() pre-assignment of ceTaskFcn');
            % tic;
            ceTmp = {};
            for n = 1:100 % make this num larger if needed
                % tic;
                ceTmp{n} = @this.nothing;
                % toc;
            end
            
            % tic;
            this.ceTaskFcn = ceTmp;
            % toc;
            % toc;
            
            
            % timer
            this.t =  timer( ...
                'TimerFcn', @this.timerFcn, ...
                'Period', this.dPeriod, ...
                'ExecutionMode', 'fixedRate', ...
                'Name', sprintf('Clock (%s)', this.cName) ...
                );
            start(this.t);

        end
        
        function lReturn = has(this, cName)
        %HAS Checks whether a task is already in the clock queue
        % lReturn = clock.has('task name')
            
            % Clock.has(cName)  check if the task 'cName' is in the tasklist
            % and that it is active
            %
            %   cName:char         name of task (must be unique)
            %   lReturn:logical    true if the task is on the list, false otherwise

            % Note on strcmp() function: strcmp(char, cell) returns a
            % logical array.  FALSE for every element not equal to cName,
            % TRUE for every element equal to cName.
            % use & (not &&) to do a logical AND operation between the return from strcmp()
            % and this.lTaskActive.  The result of this operation returns a
            % type logical array.
            % any() operating on a lotical array returns a logical true if
            % any are true and false otherwise
                        
            if isempty(this.ceTaskName)
                lReturn = false;
                return;
            end
            
            if any(strcmp(cName, this.ceTaskName) & this.lTaskActive)
                lReturn = true;
            else
                lReturn = false;
            end            
            
        end
        
        function dReturn = nextIndex(this)
        %NEXTINDEX Gives the next avaible slot in the clock tasklist
        %   dReturn = Clock.nextIndex()
            
            %{
            This will return the index of the next available slot in
            dTaskPeriod, ceTaskName, and ceTaskFcn.  First it will check
            this.lTaskActive to see if there are any inactive tasks (these
            can be overwritten).  If there are no inactive tasks, it
            computes the length of this.dTaskPeriod (don't use
            this.dTaskName b/c computing the length of a cell takes longer
            than computing the length of a double) and return the length
            incremented by 1
            %}
            
            dIndex = find(~this.lTaskActive);
            
            if ~isempty(dIndex)
                dReturn = dIndex(1);
                return;
            end
            
            dReturn = length(this.dTaskPeriod) + 1;
            
            
        end
        
        function add(this, fhFcn, cName, dPeriod)
            
        %ADD Adds a task to the clock tasklist
        % Clock.add(fhFcncName, cName, dPeriod) adds the task fhFcn to
        % the tasklist, naming it cName
        %   
        % fhFcn:function_handle;     function to call 
        % cName:char;                name of task (must be unique)
        % dPeriod:double;            execution period in seconds
        %
        % See also HAS, REMOVE, LISTTASKS
        
            %{
            If cName is not unique, throw an error. Uniqueness is required 
            because cName is the property that is used to remove tasks from 
            the list (because comparing function_handles does not work)
            %}
            
            
            % this.msg(sprintf('%s', cName));

            if this.has(cName)
                err = MException( ...
                    'Clock:add', ...
                    sprintf('cName of %s already exists.  It must be unique.', cName) ...
                );
                throw(err)
            end
            
            %{
            2013.07.31 CNA 
            Round dPeriod to nearest multiple of clock period.  This
            makes it easier to check if the task needs to be executed in
            the timer handler
            %}
            
            if dPeriod < this.dPeriod
                dPeriod = this.dPeriod;
            else
                dPeriod = round(dPeriod/this.dPeriod)*this.dPeriod;
            end
            
            this.lBusy = true;
            
            
            %{
            
            Below you will find some of the code I used when I was
            debugging the speed problem with adding tasks.  I'm leaving the
            code for legacy purposes incase we ever need to revisit this.
            Perhaps future releases of Matlab will have better ways of
            dealing with assignment to cell of function_handle types
            
            
            
            dCount = length(this.dTaskPeriod) + 1;

            
            fhTmp = fhFcn;
            
            this.msg('copy this.ceTaskFcn');
            tic;
            ceTaskFcn = this.ceTaskFcn;
            toc;
            
            this.msg('append new fh to copy');
            tic;
            ceTaskFcn{dCount} = fhTmp;
            toc;
            
            this.msg('this.ceTaskFcn = {}');
            tic;
            this.ceTaskFcn = {};
            toc;
            
            this.msg('this.ceTaskFcn = updated copy');
            tic;
            this.ceTaskFcn = ceTaskFcn;
            toc;
            
            
            % Another thing I tried
            
            tic;
            ce_tmp = {};
            for n = 1:dCount
                ce_tmp{n} = fhFcn;
            end
            toc;
            tic;
            this.ceTest = ceTaskFcn;
            toc;
            
            
            %}
            
            
            dIndex = this.nextIndex();
            
            % this.msg('this.ceTaskFcn{dCount} = fhFcn');
            this.ceTaskFcn{dIndex}      = fhFcn;
            this.ceTaskName{dIndex}     = cName;
            this.dTaskPeriod(dIndex)    = dPeriod;
            this.lTaskActive(dIndex)    = true;
            
            
            if this.lEcho
                cMsg = sprintf( ...
                    'Clock.add() %s', ...
                    this.ceTaskName{dIndex} ...
                );

                this.msg(cMsg);
            end
            
            this.lBusy = false;

        end
        
        
        function remove(this, cName)
        %REMOVE Removes a task from the clock tasklist
        %   Clock.remove('task name')
        %
        % See also ADD, HAS, LISTTASKS
                        
            % Originally, the plan was to pass in a function handle and
            % then compare it to the stored function handles in stTasks but
            % this doesn't work.  Two handles to the same method of a class
            % instance are not the same.  
            
            % Instead, I'm passing in a unique cName to identify which task
            % we want to remove
            
            % Loop through and compare function handles in task list to the
            % function handle passed in
            
            %{
            if this.lEcho
                cMsg = sprintf( ...
                    'Clock.remove() flagging %s for removal', ...
                    cName ...
                );
                this.msg(cMsg);
            end
            %}
            
            this.lBusy = true;
            
            lItems = strcmp(cName, this.ceTaskName) & this.lTaskActive;
            
            if any(lItems)
                
                
                
                %{
                
                Below you will find the original remove method where we
                literally purged items from ceTaskFcn, dTaskPeriod and
                ceTaskName.  Now we just set the lTaskActive flag to false.
                I am leaving this code here for legacy purposes.  As you
                can read in the comments at the top of this class, the
                first block of code below tooka long time to execute, which
                is why we now use the flat method
                
                this.msg('this.ceTaskFcn(lItems) = []');
                tic
                this.ceTaskFcn(lItems)      = [];
                toc
                
                this.msg('this.ceTaskName(lItems) = []');
                tic
                this.ceTaskName(lItems)     = [];
                toc
                
                this.msg('this.ceTaskPeriod(lItems) = []');
                tic
                this.dTaskPeriod(lItems)    = [];
                toc
                
                %}
                
                
                if this.lEcho
                    cMsg = sprintf(...
                        'Clock.remove() de-activating: %s() ', ...
                        this.ceTaskName{lItems} ...
                    );
                    this.msg(cMsg);
                end
                
                this.lTaskActive(lItems) = false;
                
                
                
                
            end
            
            this.lBusy = false;
            
            
            % this.lRemove(strcmp(cName, this.ceTaskName)) = true; 
            
            this.listTasks();
                      
        end 
        
        function listTasks(this)
        %LISTTASKS Lists the tasks in the clock tasklist in the command wdw
        %   Clock.listTasks()
        % See also HAS, ADD, REMOVE
            
            ceTaskNameActive = this.ceTaskName(this.lTaskActive); % returns a cell
            dTaskPeriodActive = this.dTaskPeriod(this.lTaskActive);
            if isempty(ceTaskNameActive)
                cStr = 'No task running\n';
            else
                cStr = 'List of running tasks :\n';
                for n = 1:length(ceTaskNameActive)
                    cStr = sprintf(...
                        '%s\t %1.0f. %s (%1.3f sec) \n', ...
                        cStr, ...
                        n, ...
                        ceTaskNameActive{n}, ...
                        dTaskPeriodActive(n) ...
                    );
                end
            end
            fprintf(cStr);
        end
        
        function start(this)
        %START Starts/restarts the clock
        %   Clock.start()
        %
        % See also STOP
            if isvalid(this) && ...
                    isvalid(this.t)
                
                if strcmp(this.t.Running, 'off')
                    start(this.t);
                end
            end
        end
        
        function stop(this)
        %STOP stops the Clock
        %   Clock.stop()
        %
        % See also START
            if isvalid(this) && ...
                    isvalid(this.t)
                
                if strcmp(this.t.Running, 'on')
                    stop(this.t);
                end
            end
        end
        
      
        
        function timerFcn(this, src, evt)
        %TIMERFCN Callback used by the clock to trigger the task executions
        %   Clock.timerFcn(src, evt)
            
            if this.lBusy
                if this.lEcho
                    this.msg('Clock.timerFcn() busy');
                end
                return
            end
            
            
            %{
            if  ~isvalid(this) || ...
                ~isvalid(this.t)
                return
            end
            %}
            

            % dElapsedTime = this.t.TasksExecuted*this.dPeriod;
            dElapsedTime = this.dTicks*this.dPeriod;
                       
            
            
            % Purge tasks that have been flagged for removal
            
            %{
            lItems = this.lRemove;
            
            if any(lItems)
                
                this.ceTaskFcn(lItems)      = [];
                this.ceTaskName(lItems)     = [];
                this.dPeriod(lItems)    = [];
                this.lRemove(lItems)    = [];
                
                if this.lEcho
                    cMsg = sprintf(...
                        'Clock.timerFcn() purging: %s() ', ...
                        this.ceTaskName{lItems} ...
                    );
                    this.msg(cMsg);
                end
            end
            %}

            % Execute tasks whose period can evenly divide the elapsed time 
            
            lItems = (mod(dElapsedTime, this.dTaskPeriod) == 0) & this.lTaskActive;
            
            % lItems = mod(dElapsedTime, this.dTaskPeriod) == 0;
            ceTaskFcnToDo = this.ceTaskFcn(lItems);
            ceTaskNameToDo = this.ceTaskName(lItems);
                       
            
            if this.lEcho
                 cMsg = sprintf( ...
                    'Clock.timerFcn() @ %1.3f with %1.0f tasks (%1.0f active).  Executing %1.0f', ...
                    dElapsedTime, ...
                    length(this.ceTaskName), ...
                    sum(this.lTaskActive), ...
                    sum(lItems) ...
                );
                this.msg(cMsg);
            end
            
            for n = 1:length(ceTaskFcnToDo)
                
%                 if ~isvalid(ceTaskFcnToDo{n})
%                     continue
%                 end
                % Execute
                try
                    
                    % if this.lEcho
                        cMsg = sprintf(...
                            'Clock.timerFcn() executing %1.0f of %1.0f: %s() ', ...
                            n, ...
                            sum(lItems), ...
                            ceTaskNameToDo{n} ...
                        );
                        this.msg(cMsg, 6);
                    % end
                    
                    
                    ceTaskFcnToDo{n}();                     

                catch err
                    this.msg(getReport(err), 1);
                    rethrow(err);
                end
            end
            
            
            this.dTicks = this.dTicks + 1;
            
            % Once dElapsedTime is larger than max(dTaskPeriod), we can
            % reset dTicks so we are not dealing with large numbers.  It
            % may be worthwhile to do this check each time through the
            % loop.  It will add a small amount of overead once per clock,
            % but my thought is that the extra overhead of large numbers.
            % At 1kHz operation, it will tick 1000 ticks/s * 60 s/min * 60
            % min/h * 24 h/day = 86e6 ticks.  I wonder.  
            
            % I did a test today and  mod is blazing fast.  Doing mod(243,
            % 53453453453453) take around 4 us.  I'm not worried about this
            % effect so we never need to reset dTicks
            
        end
        
        
        function save(this)
        %SAVE Unimplemented yet
        %TODO implement
        %
        % See also LOAD
        end
        
        function load(this)
        %LOAD Unimplemented yet
        %TODO implement
        %
        % See also SAVE
        end
        
        function build(this,hParent,dTop,dLeft)
        %BUILD [Unimplemented] Builds the UIElement corresponding to the cl
        %   Clock.build(hParent,dTop,dLeft)
        %
        % See also
        
        %TODO : implement
        end
        
%% Destructor
        function delete(this)
        %DELETE Destructor for the clock 
        %   Clock.delete()
        %
        % See also CLOCK, INIT, BUILD
            this.msg('delete()', 8);         
            try
                if isvalid(this.t)
                
                    if strcmp(this.t.Running, 'on')
                        stop(this.t);
                    end
                    
                    this.msg('delete() deleting timer');

                    set(this.t, 'TimerFcn', '');
                    delete(this.t);
                end
                
            catch err
                this.msg(getReport(err));
            end
                
            
        end
        
        function nothing(this)
        end
        
    end
    
    
end