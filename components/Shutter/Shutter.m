classdef Shutter < HandlePlus
%SHUTTER Class that allows to to trigger exposure measurements
%   sh = Shutter(cName, clock) creates an instance of a Shutter
%
% See also SHUTTERVIRTUAL, AXIS, DIODE, HARDWAREIO, HARDWAREO

% hungarian notation : sh 
          
    properties (Constant)
        dHeight = 36;   % height of the UIElement
        dWidth = 290;   % width of the UIElement
    end
    
    properties     
        cName   % name identifier
        uieExposureTime         % UIEdit that sets the exposure time
        apiv                    % APIVShutter instance
        api                     % API instance
        lOpen = false
    end
    
	properties (SetAccess = private)
    end
    
    properties (Access = private)
        cDir            % current directory
        dExposureQueue  % n-minute exposures are broken into n 1-min exposures
        cl              % clock
        dPeriod = 100/100   % period
        uitxLabel               % UI element label 
        uitOpen                 % UIToggle that command the opening of the shutter
        dExposureTimePartial    % partial exposure time
        hQueueListener          % queue listenter
        uitActive               % UIToggle that allows to activate the control
    end
    
    events
        eShutterClosed
    end
    
    methods
        
        function this = Shutter(cName, cl)
        %SHUTTER Class constructor
        %   sh = SHUTTER('name', clock)   
        %
        % See also INIT, BUILD, DELETE
        
            this.cName = cName;
            this.cl = cl;
          
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            
            this.init();
        end
        
        function init(this)
        %INIT Initializes the instance
        %   Shutter.init()
        %
        % See also SHUTTER, BUILD, DELETE
            
            % toggle active
            this.uitActive = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                imread(sprintf('%s../assets/controllernotactive.png', this.cDir)), ...
                imread(sprintf('%s../assets/controlleractive.png', this.cDir)), ...
                true, ...
                'Are you sure you want to change axis status?' ...
                );
            
            % toggle open/closed
            this.uitOpen = UIToggle( ...
                'trigger', ...   % (off) not active
                'close' ...  % (on) active
                );
            
            % edit exposure time
            this.uieExposureTime = UIEdit('Exposure Time (ms)', 'd', false);
            
%             this.uitPlay = UIToggle( ...
%                 'play', ... % stopped
%                 'stop', ... % moving
%                 true, ...
%                 imread(sprintf('%s../assets/play.png', this.cDir)), ...
%                 imread(sprintf('%s../assets/pause.png', this.cDir)) ...
%                 );
           
            this.uitxLabel = UIText(this.cName);
            
            % shutter virtual
            this.apiv = APIVShutter(this.cName, this.cl);
            
            % clock
            this.cl.add(@this.handleClock, this.id(), this.dPeriod);
            
            %{
            % timer
            this.t =  timer( ...
                'TimerFcn', @this.tcb, ...
                'Period', 0.5, ...
                'ExecutionMode', 'fixedRate', ...
                'Name', sprintf('Shutter (%s)', this.cName) ...
                );
            start(this.t);
            %}
            
            % event listeners
            addlistener(this.uitOpen, 'eChange', @this.handleUI);
        end
        
        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the Shutter instance
        %   Shutter.build(hParent, dLeft, dTop)
        %
        % See also SHUTTER, INIT, DELETE
                       
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dLeft dTop this.dWidth 36], hParent) ...
                );
			drawnow;
             
            this.uitActive.build(hPanel, this.dWidth-12, 0, 12, 36);
            this.uitOpen.build(hPanel, this.dWidth-12-75, 0, 75, 36);            
            this.uieExposureTime.build(hPanel, this.dWidth-12-75-75, 0, 75, 36);
            this.uitxLabel.build(hPanel, 0, 12, this.dWidth-12-75-75, 12);
                                    
            % Make sure current character is not set on "Enter"
            % set(hParent, 'CurrentCharacter', char(12))

        end
        
        function open(this)
        %%OPEN Opens the shutter for the set amount of time
        %   Shutter.open()
        % 
        % See also OPENPARTIAL, CLOSE
            
        % With clock, it might be good to add a task here then remove
        % it when the queue is empty.  I can try that.

        % make sure toggle shows open (for calls to open that don't
        % originate with a button press)
            
        
            this.lOpen = true;
            
            if ~this.uitOpen.lVal
                this.uitOpen.lVal = true;
            end
            
            
            % n-minute exposures are broken into n 1-minute exposures and
            % one exposure less than one minute.  This is legacy but the
            % shutter drivers we had in the past would only support 2^16
            % counts and each count was 100 us or something like that.  It
            % ended up that 2 minutes was the longest exposure possible. 
            
            % Break into minutes and seconds
            nMin = floor(this.uieExposureTime.val()/1000/60);
            nSec = this.uieExposureTime.val()/1000-nMin*60; 
            
            sMessage = sprintf( ...
                'open() for %1d min and %1.3f sec', ...
                nMin, ...
                nSec ...
            );
            this.msg(sMessage);
            
            % flush existing queue
            this.dExposureQueue = [];
            
            % populate the queue with 1-min exposures
            for k = 1:nMin
                this.dExposureQueue(length(this.dExposureQueue)+1) = 60000;
            end
            
            % populate the remaining < 1-min exposure
            this.dExposureQueue(length(this.dExposureQueue)+1) = nSec*1000;
            
            % start processing the queue
            this.processQueue();
        end
        
                
        function openPartial(this)
        %OPENPARTIAL Opens the shutter 
        %   Shutter.openPartial()
        %
        % See also OPEN, CLOSE
            
            if this.uitActive.lVal
                this.api.open(this.dExposureTimePartial);
                %FIXME : there is no shutter API !
            else
                this.apiv.open(this.dExposureTimePartial);
            end
            
            % If the timer is off, start it so it can repeatedly ask
            % cwrapper if the shutter is closed.
            
            %{
            if strcmp(this.t.running, 'off')
                start(this.t);
            end
            %}
            
        end
        
        
        function close(this)
        %CLOSE Closes the shutter
        %   Shutter.close()
        %
        % See also OPEN, OPENPARTIAL
            
        % The order of the events below is important.  You need to
        % flush the queue before actually aborting so that the abort
        % doesn't trigger the event eShutterClosed before the queue is
        % flushed.
           
            % Delete queue listener if it exists
            delete(this.hQueueListener);
            
            % Flush exposure queue
            this.dExposureQueue = [];
            
            % Abort
            if this.uitActive.lVal
                % api
                this.api.close();
            else
                % virtual
                this.apiv.close();
            end
            
            if this.uitOpen.lVal
                this.uitOpen.lVal = false;
            end
        end
        
        function processQueue(this)
        %PROCESSQUEUE Processes the shutter queue
        %   Shutter.processQueue()
            
            %this.msg('Shutter.processQueue()');
            if(~isempty(this.dExposureQueue))
                
                cMsg = sprintf('processQueue() exposingPartial %1.0f ms',this.dExposureQueue(1));
                this.msg(cMsg);
                
                % Listen for the next partial exposure shutter close event
                
                this.hQueueListener = addlistener(this, 'eShutterClosed', @this.handleShutterClosed);
                
                % Update partial exposure time, and expose this exposure
                
                this.dExposureTimePartial = this.dExposureQueue(1);
                this.openPartial(); 
                
                % Remove this exposure from the queue
                this.dExposureQueue(1) = [];
                
            else
                
                %this.msg('Shutter.processQueue() dExposureQueue is empty.');
                
                if this.uitOpen.lVal
                    this.uitOpen.lVal = false;
                end
                
            end
         end
                     
        function delete(this)
        %DELETE Class destructor
        %   Shutter.delete()
        %
        % See also SHUTTER, INIT, BUILD
            
            this.msg('delete()');
            
            try
                
                % Clean up clock tasks
                if isvalid(this.cl) && ...
                   this.cl.has(this.id())
                    this.cl.remove(this.id());
                end
            
                    
                %{
                % timer
                if isvalid(this.t)
                    if strcmp(this.t.Running, 'on')
                        stop(this.t);
                    end
                    delete(this.t);
                end
                %}

                % av.  Need to delete because it has a timer that needs to be
                % stopped and deleted

                
                if ~isempty(this.apiv)
                    delete(this.apiv);
                end
            

                % delete(this.as);
                % av, as ?
                
            catch err
                this.msg(getReport(err));
            end
        end
        
    end %methods
        
    
    methods(Hidden)
        
        function handleClock(this)
        %HANDLECLOCK Callback triggered by the clock
        %   Shutter.HandleClock()
        %   updates the shutter status
        
            try
                
                % update lOpen property
                
                if this.uitActive.lVal
                    % api
                    this.lOpen = ShutterAPI.isOpen(this.cName);
                else
                    % virtual
                    this.lOpen = this.apiv.isOpen();
                end
                
                if ~this.lOpen && ...
                    this.uitOpen.lVal
                
                    % uitOpen.lVal is reset in processQueue() after the
                    % queue is empty
                
                    notify(this, 'eShutterClosed');  
                end
                
            catch err
                this.msg(getReport(err));
            end
        end
        
        
        function handleUI(this, src, ~)
            %HANDLEUI Callback for the User interface (uicontrols etc.)
            %   Shutter.handleUI(src,~)
            
            if isequal(src,this.uitOpen)
                if this.uitOpen.lVal
                    this.open();
                else
                    this.close();
                end
            else
                return
            end
            
            
        end
        
        
        function handleShutterClosed(this, ~, ~)
            % delete the listener that evoked
            delete(this.hQueueListener);
            % keep processing the queue
            this.processQueue();
        end
        
    end %methods hidden
    
%% Legacy
         %{
        function tcb(this, src, evt)
                      
            try
                
                if this.uitActive.lVal
                    % api
                    lOpen = ShutterAPI.isOpen(this.cName);
                else
                    % virtual
                    lOpen = this.apiv.isOpen();
                end
                
                if ~lOpen && ...
                    this.uitOpen.lVal
                    notify(this, 'eShutterClosed');
                end
                
            catch err
                this.msg(getReport(err));
            end
            
        end
        %}
end %classdef