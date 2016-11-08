classdef Scan < HandlePlus
    %SCAN is a class dedicated to provide motion/acquisition function
    %   It is capable of varying any kind of parameter and launch an
    %   acquition for every iteration, in an asynchronous manner
    %   (ScanTest provides a few examples of implementation)
    %
    %     scan = Scan(cName, clock, fhMoveFcn, fhSettleFcn, fhAcqFcn)
    %       where :
    %           - cName is the name of the scan (scans mus have different id's)
    %           - clock is a Clock instance that controls the scan
    %           - @fhMoveFcn{(position)} is a function handle to a moving
    %                   procedure (it can be whateever increment instruction)
    %           - {bIsSettled =} @fhSettleFcn{()} is a function handle that checks
    %                   the data point is ready to acquire
    %           - {xData = }@fhAcqFunction{()} is a funtion that reads data
    %      (examples of function handles are provided in the ScanTest class)
    %
    %     commonly used methods :
    %       Scan.start() starts the scan, when scan params are populated
    %       Scan.pause()/Scan.resume() pauses/resumes the scan
    %       Scan.stop() stops the scan
    %       cePostion = Scan.cePosition outputs the scan positions
    %       ceData    = Scan.ceData outputs the scan positions
    %       Scan.build(fig_handle, top_position, left_position)
    %           builds the uielement associated to the scan
    %       Scan.delete() deletes the scan
    %
    %       example of use :
    %           sc = Scan('scan example', clock, ...
    %               @fhMoveFcn, @fhSettleFcn, @fhAcqFcn)
    %           sc.uieMin.setVal(dMin);
    %           sc.uieStep.setVal(dStep);
    %           sc.uieMax.setVal(dMax);
    %               scan.build(gcf, 0, 0); %builds the uielement in the
    %           sc.start;
    %               scan.pause;     %pauses the scan
    %               scan.resume;    %resumes the scan
    %
    %           x = sc.cePositions
    %           y = sc.ceData;
    %
    
    %TODO add to this :  save and recall previous scans
    %TODO add stage/hardwareIO - sensor/HardwareI simple constructor
    
    
    %% Properties
    
    properties (Constant)
        dWidth  = 300   % width
        dHeight = 36    % height
    end
    
    properties (Dependent = true)
        nStep           % number of steps for the scan
        cePositions     % scan positions for output as a cell
    end
    
    properties
        dPollingPeriod  % clock polling period in sec
        
        %function handles for the scanning procedure
        fhScanStartFcn = @()[]; % function called when scan starts
        fhMoveFcn       % moving or stepping function
        fhSettleFcn     % ready to acquire
        fhAcqFcn        % acquisition function
        fhPosFcn        % get position
        
        %data collection variables
        ceData          % data
        cePreviousSscans% a cell containing previous scans
        dScale = 1;     % scale between the reading and the position
        
        %info containers
        
        lRevert = false;
        
        uie_filename% container for the filename where the scan should be written
        lIsDependent = false;% boolean to deactivate the controls (chained)
    end
    
    properties (SetAccess = private)
        cl      % clock instance for scan trigger
        cName   % name of the scan instance
        
        uieMin      % container for the value of the starting point of the scan
        uieStep     % container for the value of the step size of the scan
        uieMax      % container for the value of last point of the scan
        
        %UI handles
        hParent     % handle to the parent for building the uielement
        hUI         % handle to the uielement panel
        hAxes       % axis for plotting the data
        
        dInitial_position;
        
        %where is located the class; how the scan is named
        cFolder     % file management
        cSaveFolder = 'C:\Documents and Settings\awojdyla\My Documents\MATLAB\MET\met5gui\classes\savetest\'%FIXME give a real folder
        cTaskName   % name to the scan in the clock tasklist
        
        bIsEnabled  %TODO : deactivate scans
        
        %scanning status
        bIsActive = false   % checks/checked whether the scan is active
        bIsCompleted = false; % checks whether the scan has completed
        bIsPaused = false   % checks/checked whether the scan is paused
    end
    
    properties (Access = private)
        cDir        % current directory
        uib_run     % scan//Pause//Resume button
        uib_stop    % stop button
        uib_save    % save button
        
        u16Cursor  % cursor for data point collection
        dPositions %
        
        scanTic  % for time estimation; independant from clock
        
        %images for UIElements
        img_Scan
        img_Pause
        img_Resume
        img_Stop
        img_Save
    end
    
    events
        eScanStarted
        eScanCompleted
        eAcquire
    end
    %%
    
    methods
        %% Constructor
        function this = Scan(cName, cl, fhMoveFcn, fhSettleFcn, fhAcqFcn)
            % SCAN Creates a Scan instance
            %   Scan(cName, clock, fhMoveFcn, @fhSettleFcn, @fhAcqFcn)
            %   where :
            %	- @fhMoveFcn{(position)} is a function handle to a moving
            %	 procedure (it can be whateever increment instruction)
            %	- {bIsSettled =} @fhSettleFcn{()} is a function handle that checks
            %	 the data point is ready to acquire
            %	- {xData = }@fhAcqFunction{()} is a funtion that reads data
            %
            % See also BUILD, INIT, DELETE
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            
            this.cName = cName;
            this.cl = cl;
            
            if nargin>2
                this.fhMoveFcn = fhMoveFcn;
                this.fhSettleFcn = fhSettleFcn;
                this.fhAcqFcn = fhAcqFcn;
            end
            
            this.init();
        end
        
        function init(this)
            %INIT Initializes the scan class
            %   Scan.init() is mainly there to be called by the constructor
            %
            % See also BUILD, DELETE
            
            this.uieMin   = UIEdit('Start','d');
            this.uieStep  = UIEdit('Step', 'd');
            this.uieMax   = UIEdit('Stop', 'd');
            
            this.dPollingPeriod = 200e-3; %TODO Add a setter
            
            this.uie_filename = UIEdit('filename', 'c');
        end
        
        function set_range(this,arg1,step,stop)
        %SET_RANGE
        %   Scan.set_range(start,step,stop)
        %   Scan.set_range(array)
        
            if nargin == 2
                dMin  = arg1(1);
                dStep = arg2(1)-arg1(2);
                dMax  = arg1(end);
            elseif nargin ==4
                dMin  = arg1;
                dStep = step;
                dMax  = stop;
            else
                error('Not enough or too many arguments')
            end
            
            this.setup(dMin,dStep,dMax)            
        end
        
        function setup(this,dMin,dStep,dMax)
        %SETUP Sets the scanning parameters [for debugging purposes]
        %   Scan.setup(dMin,dStep,dMax)
            
            this.uieMin.setVal(dMin)
            this.uieStep.setVal(dStep)
            this.uieMax.setVal(dMax)
        end
        
        
        function start(this)
        %START Starts the scan by setting the first position and adding
        % the acquisition procedure to the clock task list
        %   Scan.start()
        %
        % See also STOP,PAUSE,RESUME
       
        % Call scan start function
        this.fhScanStartFcn();
        
            %getting the initial position (for end of scan return)
            if ~isempty(this.fhPosFcn)
                this.dInitial_position = this.fhPosFcn();
            end
            
            try
                if this.isRangeValid()
                    this.dPositions = this.setPositions();
                    this.ceData = cell(1,this.nStep); %allocating data
                    
                    this.u16Cursor = 1;
                    this.cTaskName = sprintf('%s:Acquisition',this.cName);
                    this.cl.add(@this.acquire, this.cTaskName, this.dPollingPeriod)
                    this.fhMoveFcn(this.dPositions(this.u16Cursor))
                    this.msg(...
                        sprintf('%s:going to its first position',this.cName), 3) %TODO remove when finalized
                    this.scanTic = cputime;
                    if ~isempty(this.uib_run)
                        set(this.uib_run,'CData',this.img_Pause)
                        drawnow
                    end
                    this.bIsActive = true;
                    this.bIsPaused = false;
                    this.bIsCompleted = false;
                else
                    msgbox(sprintf('Invalid Range for scan %s',this.cName));
                end
            catch err
                this.msg(sprintf('%s:start failed\n',this.cName), 2)
                this.stop;
                rethrow(err)
            end
        end
        
        
        function acquire(this)
        % ACQUIRE Acquires the data in an asynchronous manner (non blocking)
        %   Scan.acquire() *should not be used all by itself*.
        %
        % See START
            
            try
                %make sure the procedure hasn't been switched off
                if this.bIsActive
                    %not at the last scan point yet
                    if this.u16Cursor <= this.nStep
                        %if paused, do nothing
                        if ~this.bIsPaused
                            %is the measurement ready for aq?
                            if this.fhSettleFcn()
                                %Acquire !
                                this.msg(sprintf('%s: reading',this.cName), 4)
                                if ~isa(this.fhAcqFcn, 'cell')
                                    this.ceData{this.u16Cursor} = this.fhAcqFcn();
                                else
                                    for i_acq = 1:length(this.fhAcqFcn)
                                        this.ceData{this.u16Cursor}(:,i_acq) =...
                                            this.fhAcqFcn{i_acq}();
                                    end
                                end
                                    
                                notify(this,'eAcquire')
                                if ~isempty(this.fhPosFcn)
                                    this.dPositions(this.u16Cursor) = this.fhPosFcn();
                                end
                                %increasing the cursor
                                this.u16Cursor = this.u16Cursor+1;
                                %and moving to the next step if needed
                                if this.u16Cursor <=this.nStep
                                    %FIXME what if it is a blocking function?
                                    this.fhMoveFcn(this.dPositions(this.u16Cursor));
                                    this.msg(sprintf('%s: moving',this.cName), 3) %TODO remove when finalized
                                end
                            end
                        else
                            this.msg(sprintf(' ''%s''.acquire : Paused : do nothing\n',this.cName), 6);
                        end
                    else
                        this.msg(sprintf(' ''%s''.acquire : just finished scannning\n',this.cName), 6); %TODO remove when finalized
                        this.bIsCompleted = true;
                        notify(this,'eScanCompleted')
                        this.revert()
                        this.stop();
                    end
                end
            catch err
                %this.stop() %FIXME
                rethrow(err);
            end
        end
        
        
        function stop(this)
        %STOP Stops the current scan
        %   Scan.stop() ;
        %
        % See also START, PAUSE, RESUME
            
            if this.cl.has(this.cTaskName)
                this.cl.remove(this.cTaskName)
            end
            if this.bIsActive
                if ~isempty(this.uib_run)
                    %this.uib_run.setU8Img(this.img_Scan);
                    set(this.uib_run,'CData',this.img_Scan)
                end
                this.bIsActive = false;
            end
        end
        
        
        function pause(this)
        %PAUSE Pauses the scanning procedure
        %   Scan.pause()
        %
        % See also RESUME, START, STOP
            
            this.bIsPaused = true;
            if ~isempty(this.uib_run)
                
                %this.uib_run.setU8Img(this.img_Resume);
                set(this.uib_run,'CData',this.img_Resume)
                drawnow
            end
        end
        
        
        function resume(this)
        %RESUME Resumes the scanning procedure
        %   Scan.resume();
        %
        % See also PAUSE, START, STOP
        
            this.bIsPaused = false;
            if ~isempty(this.uib_run)
                %this.uib_run.setU8Img(this.img_Pause)
                set(this.uib_run,'CData',this.img_Pause)
                drawnow
            end
        end
        
        %     function saveToFile(this)
        %         if ~isempty(this.scans)
        %             filename = strcat(get(this.uieSave,'String'),'.txt');
        %             i = 1;
        %             while exist(filename, 'file')
        %                 filename = strcat(get(this.uieSave,'String'),'_',num2str(i),'.txt');
        %                 i = i+1;
        %             end
        %             buffer(:,1) = double(this.scans{1,end});
        %             buffer(:,2) = double(this.scans{2,end});
        %             save(filename,'buffer','-ascii','-double');
        %         else
        %             msgbox('Impossible to save data : not data has been collected...')
        %         end
        %     end
        
        function revert(this)
        %REVERT Come back to the pre-scan position
        
            if ~isempty(this.dInitial_position) && this.lRevert
                this.fhMoveFcn(this.dInitial_position)
            elseif ~this.lRevert
                %nothing
            else
                this.msg(sprintf('scan cannot revert to initial position\n'), 2)
            end
        end
       
        function bIsValid = isRangeValid(this)
        %ISRANGEVALID Checks whether the scanning range is valid (i.e. non-zero)
        %   bIsValid = Scan.isRangeValid()
        %
        % See also SETPOSITIONS
            if (~isempty(this.uieMin) && ~isempty(this.uieStep) && ~isempty(this.uieMax)&& ...
                    abs(this.uieStep.val())>0 && ... this.uieMin.val() ~= this.uieMax.val() && ...
                    (abs(this.uieMin.val()-this.uieMax.val())>=this.uieStep.val() ...
                    || this.uieMin.val() == this.uieMax.val())...
                    )
                
                bIsValid = true;
            else
                bIsValid = false;
            end
        end
        
        
        function dPositions = setPositions(this)
        %SETPOSITIONS Sets the scan 'positions'
        %   dPositions = Scan.setPositions()
        %
        % See also ISRANGEVALID
            
            if (this.uieMax.val()-this.uieMin.val())>=0 %ascending start-stop
                if this.uieStep.val()>0 %go forward
                    dPositions = this.uieMin.val():this.uieStep.val():this.uieMax.val();
                else
                    dPositions = this.uieMax.val():this.uieStep.val():this.uieMin.val();
                end
            else %descending start-stop
                if this.uieStep.val()>0
                    dPositions = this.uieMin.val():-this.uieStep.val():this.uieMax.val();
                else
                    dPositions = this.uieMax.val():-this.uieStep.val():this.uieMin.val();
                end
            end
            dPositions = dPositions.*this.dScale;
            
        end
        
        
        function ET = elapsedTime(this)
        % ELAPSEDTIME Gives the elapsed time since the beginning of the scan
        %   ET = Scan.elapsedTime()
        %
        % See also ESTIMATEDTIMEBEFORECOMPLETION
            
            ET = (cputime-this.scanTic);
        end
        
        function ETBC = estimatedTimeBeforeCompletion(this)
        % ESTIMATEDTIMEBEFORECOMPLETION Estimates the time before completion.
        %   In the case of a cascaded scan procedure, results may vary
        %   ETBC = Scan.estimatedTimeBeforeCompletion()
        %
        % See also ELAPSEDTIME
        
            if this.bIsActive
                ETBC = (cputime-this.scanTic)*double(this.nStep-this.u16Cursor)/double(this.nStep);
            end
        end
        
        %% User interface
        
        function saveToFile(this, varargin)
        %SAVETOFILE Saves the data collected to a file
        %   Scan.saveToFile() saves the data using the filename provided
        %   the the edit box
        %   Scan.saveToFile(filename) saves the data in the file  'filename'
        %   (w/o extension)

            if nargin == 1 %get the filename from the filename UIEdit
                filename = this.uie_filename.val();
                if strcmp(filename,'')
                    error('%s:save : no filename has been entered' ,this.cName)
                end
            elseif nargin == 2 %get the filename from command line
                filename = varargin{1};
            end
            
            try
                if ~isempty(this.ceData)
                    full_filename = sprintf('%s%s.txt', this.cSaveFolder,filename);
                    if exist(full_filename, 'file')
                        i = 1;
                        full_filename = sprintf('%s%s_%i.txt', this.cSaveFolder,filename,i);
                        while exist(filename, 'file')
                            full_filename = sprintf('%s%s_%i.txt', this.cSaveFolder,filename,i);
                            i = i+1;
                        end
                    end
                    buffer(:,1) = double(cell2mat(this.cePositions));
                    buffer(:,2) = double(cell2mat(this.ceData));
                    save(full_filename,'buffer','-ascii','-double');
                else
                    msgbox('Impossible to save data : no data has been collected...')
                end
            catch err
                rethrow(err)
            end
            
        end
        
        function plot(this,varargin)
        %PLOT Tries to plot the data (works if they are 2D and scalar)
        %   Scan.plot() plots the data in a new figure
        %   Scan.plot(hAxes) plots the data in the the hAxes axes handle
            
            %argument collection
            if nargin == 1
                hFig = figure;
                this.hAxes = axes;
            elseif nargin == 2
                this.hAxes = varargin{1};
            end
            
            try
                dPos    = cell2mat(this.cePositions);
                dData   = cell2mat(this.ceData);
                plot(this.hAxes, dPos, dData);
            catch err
                fprintf('%s couldn''t plot the data, probably due to data complexity\nDetails :%s\n',this.cName, err.message)
            end
        end
        
        
        function build(this,hParent,dTop,dLeft)
        %BUILD Builds the uielement controls associated with the scan
        %   Scan.build(hParent, dTop, dLeft) builds the scan uielement
        %
        % See also INIT, DELETE
            
            this.hParent = hParent;
            this.hUI = uipanel( 'Parent', this.hParent,...%'Title', this.cName,...
                'FontWeight', 'Bold',...
                'BorderType','none',...
                'Clipping', 'on',...
                'Units', 'pixels',...
                'Position', Utils.lt2lb([dTop dLeft Scan.dWidth Scan.dHeight], this.hParent));
            drawnow;
            
            %reading the labelling images
            this.img_Scan   = imread(sprintf('%s../assets/axis-play.png', this.cDir));
            this.img_Pause  = imread(sprintf('%s../assets/axis-pause.png', this.cDir));
            this.img_Resume = imread(sprintf('%s../assets/scan-resume.png', this.cDir));
            this.img_Stop   = imread(sprintf('%s../assets/scan-stop.png', this.cDir));
            this.img_Save   = imread(sprintf('%s../assets/scan-save.png', this.cDir));
            
            posx = 56; %TODO : action
            posy = 0;
            dWidth_box = 30;
            dHeight_box = 22;
            
            uicontrol('Parent', this.hUI,...
                'Style', 'text',...
                'String',sprintf('Scan\n%s',this.cName),...
                'Units','pixels',...
                'Position',Utils.lt2lb([0 posy 56 36],this.hUI),...
                'Callback',@this.handleUI);
            
            this.uieMin.build(this.hUI,posx,posy+1,dWidth_box,dHeight_box);
            this.uieStep.build(this.hUI,posx+dWidth_box,posy+1,dWidth_box,dHeight_box);
            this.uieMax.build(this.hUI,posx+dWidth_box+dWidth_box,posy+1,dWidth_box,dHeight_box);
            
            this.uib_run = uicontrol('Parent', this.hUI,...
                'Style', 'pushbutton',...
                'String','',...
                'CData', this.img_Scan,...
                'Units','pixels',...
                'Position',Utils.lt2lb([posx+3*dWidth_box posy 36 36],this.hUI),...
                'Callback',@this.handleUI);
            
            this.uib_stop = uicontrol('Parent', this.hUI,...
                'Style', 'pushbutton',...
                'String','',...
                'CData', this.img_Stop,...
                'Units','pixels',...
                'Position',Utils.lt2lb([posx+3*dWidth_box+36 posy 36 36],this.hUI),...
                'Callback',@this.handleUI);
            
            
            this.uie_filename.build(this.hUI,posx+3*dWidth_box+36+36+36,posy,47,dHeight_box);
            
            this.uib_save = uicontrol('Parent', this.hUI,...
                'Style', 'pushbutton',...
                'String','',...
                'CData', this.img_Save,...
                'Units','pixels',...
                'Position',Utils.lt2lb([posx+3*dWidth_box+36+36 posy 36 36],this.hUI),...
                'Callback',@this.handleUI);
            
            %this.uib_save.build(this.hUI,posx+120,posy+dHeight+30,120,36);
            %this.uib_run.build(this.hUI,posx+3*dWidth,posy, 120,36);
            %this.uib_stop.build(this.hUI,posx+3*dWidth,posy+30,120,36);
        end
        
        %     function dialog(this)
        %
        %     end
        
        %     function plot2d(this)
        %
        %     end
        
        %     function fhStepFcnTemplate(this, axis)
        %     end
        %
        %     function reading = fhAcqFcnTemplate(this, diode)
        %     end
        
        %TODO implement the recall function
        %     function recall(this, iNumber)
        %         %recalls a previous scan
        %     end
        
        %% Event handlers
        function handleUI(this, src, ~)
            %HANDLEUI Handles user interactions (not to be used outside the class)
            
            %scan//pause//resume
            if ~this.lIsDependent
                if  src == this.uib_run
                    if ~this.bIsActive
                        this.start();
                    else %a scan is
                        if this.bIsPaused
                            this.resume();
                        else
                            this.pause();
                        end
                    end
                    % stop
                elseif  src == this.uib_stop
                    if this.bIsActive
                        this.stop();
                    end
                    % save
                elseif src == this.uib_save
                    this.saveToFile();
                end
            end %isDepenant
        end
        
        
        %% Modifiers
        function nStep = get.nStep(this)
        %computes the number of steps involved in the scan
        %   nStep = Scan.nStep;
            nStep = length(this.setPositions());
        end
        
        function cePos = get.cePositions(this)
        %outputs the positions of the scan in cell format
        %   cePos = Scan.cePositions;
            cePos = num2cell(this.dPositions);
        end
        
        % do not work : nargin/out must be inside the function definition
        % we might consider nargoutchk function, but it will actually test the func
        %
        %     function set.fhMoveFcn(this, value)
        %     %setter for the Move Function (make sure the fh accepts a value)
        %         if nargin(value) == 1;
        %             this.fhMoveFcn = value;
        %         else
        %             error('%s : the provided Move function is not valid',this.cName)
        %         end
        %     end
        %
        %     function set.fhSettleFcn(this, value)
        % 	%setter for the Sttle Function (make sure it returns a value)
        %         if nargout(value) == 1;
        %             this.fhSettleFcn = value;
        %         else
        %             error('%s : the provided Settle function is not valid',this.cName)
        %         end
        %     end
        %
        %     function set.fhAcqFcn(this, value)
        %         if nargout(value) == 1;
        %             this.fhAcqFcn = value;
        %         else
        %             error('%s : the provided Acquisition function is not valid',this.cName)
        %         end
        %     end
        
        
        %% Destructor
        function delete(this)
        %DELETE Destructior of the Scan class
        %   Scan.delete()
        %
        % See also BUILD, INIT
            if ~isempty(this.cTaskName)
                if this.cl.has(this.cTaskName)
                    this.cl.remove(this.cTaskName)
                end
            end
            
            if ~isempty(this.uieMin)
                delete(this.uieMin)
            end
            if ~isempty(this.uieStep)
                delete(this.uieStep)
            end
            if ~isempty(this.uieMax)
                delete(this.uieMax)
            end
            if ~isempty(this.uie_filename)
                delete(this.uie_filename)
            end
        end
        
    end %methods
    
    methods (Static)
        
    end
end %classdef