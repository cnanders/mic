classdef Axis < HandlePlus
%AXIS Class that creates the controls to drive a stage along an axis
%
% ax = Axis('name',clock) creates an Axis with a name 'name'
% ax = Axis('name',clock,'display name') will do the same, but
%       display a different name'
%
% ax.build(parent,top, left) build the UI equivalent for the class
%
% See also AXISSETUP, AXISVIRTUAL, AXISAPIGENERIC, HARDWAREIO

    properties (Constant)
        dWidth = 300; % width of the UIElement
        dHeight = 36; % height of the UIElement
    end
    
	properties (Dependent = true)
        lCal
    end

    properties
        asSetup       % AxisSetup
        avVirtual     % AxisVirtual
        api           % API
    end

    properties (SetAccess = private)
        % AW-3013/06/20 made private set since there is no setters available;-) 
        cName       % name identifier
        uieDest     % UIEdit boc that contains the target value
        cl          % Clock
    end

    properties (Access = protected)      
        uitActive %made private 6/20/13 (AW)
        uitCal
        uibSetup
        uibIndex
        uitPlay
        uibStepPos
        uibStepNeg        
        uitxPos
        uitxLabel
        cDir
        cDispName
        %t       % Timer
        
    end
    

    events
    end

    
    methods        

        function this = Axis(cName, cl, cDispName)
        %AXIS Class constructor
        %
        % ax = Axis('name', clock) creates an instance of an Axis class,
        %   where clock is a Clock instance
        % ax = Axis('name', clock, 'display name) does the same as 
        % Axis('name', clock) but allows for a different name to be displayed.
            
            % 2013.07.25 CNA
            % Adding cDispName as input so the name that shows up in the
            % controller can be short while we use a long specific name for
            % the device name (cName) to allow AxisAPI to differentiate all
            % of the devices
            if exist('cDispName', 'var') ~= 1
                cDispName = cName; % ms
            end


            %this.msg('Axis.constructor()'); %TODO remove when finalized
            this.cName = cName;
            this.cDispName = cDispName;
            %if nargin<2
            %    this.cl = Clock(sprintf('Axis %s internal clock',cName));
            %else
                this.cl = cl;
            %end

            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));

            this.init();

        end

        function init(this)
        %INIT Initializes the Axis
        %   Axis.init()
        %   primarily meant to be called by the class constructor
            
            %this.msg('Axis.init()');

            % AxisSetup
            this.asSetup = AxisSetup(this.cName);
            addlistener(this.asSetup, 'eLowLimitChange', @this.handleLowLimitChange);
            addlistener(this.asSetup, 'eHighLimitChange', @this.handleHighLimitChange);
            addlistener(this.asSetup, 'eCalibrationChange', @this.handleCalibrationChange);

            %activity ribbon on the right
            this.uitActive = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                imread(sprintf('%s../assets/controllernotactive.png', this.cDir)), ...
                imread(sprintf('%s../assets/controlleractive.png', this.cDir)), ...
                true, ...
                'Are you sure you want to change axis status?' ...
                );

            %calibration toggle button
            this.uitCal = UIToggle( ...
                'raw', ...  % (off) showing raw
                'cal', ...  % (on) showing cal
                true, ...
                imread(sprintf('%s../assets/mcRAW.png', this.cDir)), ...
                imread(sprintf('%s../assets/mcCAL.png', this.cDir)) ...
                );

            %set index toggle button
            this.uibIndex = UIButton( ...
                'Index', ...
                true, ...
                imread(sprintf('%s../assets/mcindex.png', this.cDir)), ...
                true, ...
                'Are you sure you want to index the axis?' ...
                );

            %setup toggle button
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(sprintf('%s../assets/mcsetup.png', this.cDir)) ...
                );

            %GoTo button
            this.uitPlay = UIToggle( ...
                'play', ... % stopped
                'stop', ... % moving
                true, ...
                imread(sprintf('%s../assets/axis-play.png', this.cDir)), ...
                imread(sprintf('%s../assets/axis-pause.png', this.cDir)) ...
                );

        %             imread(sprintf('%s../assets/movingoff.png', this.cDir)), ...
        %             imread(sprintf('%s../assets/movingon.png', this.cDir)) ...           

            %Jog+ button
            this.uibStepPos = UIButton( ...
                '+', ...
                true, ...
                imread(sprintf('%s../assets/axis-plus.png', this.cDir)) ...
                );

            %Jog- button
            this.uibStepNeg = UIButton( ...
                '-', ...
                true, ...
                imread(sprintf('%s../assets/axis-minus.png', this.cDir)) ...
                );

            %Editbox to enter the destination
            this.uieDest = UIEdit(sprintf('%s Dest', this.cName), 'd', false);

            %position reading
            this.uitxPos = UIText('Pos', 'right');

            %Axis Box name (on the left)
            this.uitxLabel = UIText(this.cDispName);

            this.avVirtual = AxisVirtual(this.cName, 0, this.cl);

            %AW(5/24/13) : populating the destination
            this.uieDest.setVal(this.avVirtual.getPosition());

            % 2013.07.08 CNA
            % Using clock instead of timer
            this.cl.add(@this.handleClock, [class(this),':',this.cName], this.asSetup.uieDelay.val());


        %     this.t =  timer( ...
        %         'TimerFcn', @this.tcb, ...
        %         'Period', this.setup.uieDelay.val(), ...
        %         'ExecutionMode', 'fixedRate', ...
        %         'Name', sprintf('Axis (%s)', this.cName) ...
        %         );
        %     start(this.t);



            % event listeners
            addlistener(this.uitCal,    'eChange', @this.handleUI);
            addlistener(this.uitPlay,   'eChange', @this.handleUI);

            addlistener(this.uibStepPos,'eChange', @this.handleUI);
            addlistener(this.uibStepNeg,'eChange', @this.handleUI);
            addlistener(this.uibIndex,  'eChange', @this.handleUI);
            addlistener(this.uibSetup,  'eChange', @this.handleUI);

        end

        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UIElement correspondng to the Axis class
        %   Axis.build(hParent, dLeft, dTop)

            %FIXME we should refactor with thid.dWidth everywhere

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'BorderWidth',0,... 'BackgroundColor',[0 0 0],...
                'Position', Utils.lt2lb([dLeft dTop Axis.dWidth Axis.dHeight], hParent) ...
                );
            drawnow

            y_rel=-1;
            this.uitActive.build(hPanel, this.dWidth-12, 0+y_rel, 12, 36);

            this.uitCal.build(  hPanel, this.dWidth-12-36, 0+y_rel, 36, 12);
            this.uibSetup.build(hPanel, this.dWidth-12-36, 12+y_rel, 36, 12);
            this.uibIndex.build(hPanel, this.dWidth-12-36, 24+y_rel, 36, 12);

            this.uitPlay.build(hPanel, this.dWidth-12-36-36, 0+y_rel, 36, 36);

            this.uibStepPos.build(hPanel, this.dWidth-12-36-36-18, 0+y_rel, 18, 18);
            this.uibStepNeg.build(hPanel, this.dWidth-12-36-36-18, 18+y_rel, 18, 18);

            this.uieDest.build(hPanel, this.dWidth-12-36-36-18-75, 0+y_rel, 75, 36);
            this.uitxPos.build(hPanel, this.dWidth-12-36-36-18-75-75-6, 12+y_rel, 75, 18);
            this.uitxLabel.build(hPanel, 3, 12+y_rel, this.dWidth-12-36-36-18-75-75, 18);

            ch = get(hPanel,'Children');

            try
                set(hPanel,'BackgroundColor',([0 0 0]+1)*0.90);
                for i=1:length(ch)
                    if ~strcmp(get(ch(i),'Style'),'edit')
                        set(ch(i),'BackgroundColor',([0 0 0]+1)*0.90);
                    end
                end
            catch err
                fprintf('Axis %s::build - error while changing the bg color\n%s',...
                    this.cName,err.identifier)
            end

            % Make sure current character is not set on "Enter"
            %FIXME --remove the next few lines
        %     try
        %         set(hParent, 'CurrentCharacter', char(12))
        %     catch err
        %         % AW(5/24/13) : added a try/catch, since this part was causing
        %         % error. hParent is not a public property in the general case. 
        %         % It is a bad idea to use the child to modify the parent.
        %         if (strcmp(err.identifier,'MATLAB:class:InvalidProperty'))
        %             %msgbox({'Tried to set Axis.hParent CurrentCharacter, but it failed','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
        %             this.msg('[non-critical] in Axis.Build : Failed to set hParent ''CurrentCharacter'' property')
        %         else
        %             rethrow(err)
        %         end
        %     end

        end
               
        function setDestCal(this, dCal)
        %SETDESTCAL Changes the destination (cal) inside the dest UIEdit
        %   Axis.setDestCal(dest)
        %   useful for command line control 
        %       (shorthand for hio.uieDest.setVal(value))
            if this.uitCal.lVal
                this.uieDest.setVal(dCal);
            else
                this.uieDest.setVal(this.asSetup.cal2raw(dCal));
            end


        end

        function setDestRaw(this, dRaw)
        %SETDESTRAW Changes the destination (cal) inside the dest UIEdit
        %   Axis.setDestRaw(dest)
            if this.uitCal.lVal
                this.uieDest.setVal(this.asSetup.raw2cal(dRaw));
            else
                this.uieDest.setVal(dRaw);
            end
        end

        function stepPos(this)
        %STEPPOS Performs a positive step motion
        %   Axis.stepPos()
        
            % update destination
            if this.uitCal.lVal
                this.uieDest.setVal(this.uieDest.val() + this.asSetup.uieStepCal.val());
            else
                this.uieDest.setVal(this.uieDest.val() + this.asSetup.uieStepRaw.val());
            end

            % move
            this.moveToDest();

        end

        function stepNeg(this)
        %STEPNEG Performs a positive step motion
        %   Axis.stepNeg()
        
            % update destination
            if this.uitCal.lVal
                this.uieDest.setVal(this.uieDest.val() - this.asSetup.uieStepCal.val());
            else
                this.uieDest.setVal(this.uieDest.val() - this.asSetup.uieStepRaw.val());
            end


            % move
            this.moveToDest();           
        end
       
        function moveToDest(this)
        %MOVETODEST Performs the Axis motion to the destination
        %   Axis.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW
        
            if this.uitActive.lVal
                % API
                if this.uitCal.lVal
                    this.api.moveAbsolute(this.cName, this.asSetup.cal2raw(this.uieDest.val()));
                else
                    this.api.moveAbsolute(this.cName, this.uieDest.val());
                end
            else
                % Virtual
                if this.uitCal.lVal
                    this.avVirtual.moveAbsolute(this.asSetup.cal2raw(this.uieDest.val()));
                else
                    this.avVirtual.moveAbsolute(this.uieDest.val());
                end
            end             
        end
        
        %AW2013-7-17 : added this method to programmatically change the
        %position. It was not possible to refactor moveToDest, 
        %since we need the data validation it provides.
        function move(this, value)
        %MOVE Moves the Axis to the desired position and updates the dest
        %   Axis.move(value)
        
            this.uieDest.setVal(value)
            this.moveToDest();
        end

        
        function stopMove(this)
        %STOPMOVE Aborts the current motion
        %   Axis.stopMove()
        
            if this.uitActive.lVal
                this.api.stopMove(this.cName);
            else
                this.avVirtual.stopMove();
            end 
        end

        function index(this)
        %INDEX Moves the Axis to the index position
        %   Axis.index()
            if this.uitActive.lVal
                this.api.index(this.cName);
            else
                this.avVirtual.index();
            end 
        end      
        
        function set.lCal(this, value)
            this.uitCal.lVal = value;
        end
        
        function out = get.lCal(this)
            out = this.uitCal.lVal;
        end

        %TODO remove when there will bo no more Axis Virtual
        function set.avVirtual(this, value)
            if ~isempty(this.avVirtual)
                delete(this.avVirtual);
            end

            this.avVirtual = value;
            try
                this.uieDest.setVal(this.avVirtual.getPosition());
            catch err
                this.uieDest.setVal(0);
            end
        end

        function delete(this)
        %DELETE Class destructor
        %   Axis.delete
        
            %clears the memory for all the subclasses instantiated
            %by the Axis

            %this.msg('Axis.delete()'); %TODO remove when finalized

           % Clean up clock tasks
           
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.cl.remove(this.id());
            end


            %{
            if isvalid(this.t)
                if strcmp(this.t.Running, 'on')
                     stop(this.t);
                end
                delete(this.t)
            end
            %}


            % av.  Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.avVirtual)
                 delete(this.avVirtual);
            end

            % delete(this.asSetup);
            % setup ?

            if ~isempty(this.uitActive)
                delete(this.uitActive)
            end
            if ~isempty(this.uitCal)
            delete(this.uitCal)
            end
            if ~isempty(this.uibSetup)
            delete(this.uibSetup)
            end
            if ~isempty(this.uibIndex)
            delete(this.uibIndex)
            end
            if ~isempty(this.uitPlay)
            delete(this.uitPlay)
            end
            if ~isempty(this.uibStepPos)
            delete(this.uibStepPos)
            end
            if ~isempty(this.uibStepNeg)
            delete(this.uibStepNeg)
            end
            if ~isempty(this.uieDest)
            delete(this.uieDest)
            end
            if ~isempty(this.uitxPos)
            delete(this.uitxPos)
            end
            if ~isempty(this.uitxLabel)
            delete(this.uitxLabel)
            end
        end
        
    end %methods
    
    methods(Hidden)
        
        function handleClock(this)
        %HANDLECLOCK Callback triggered by the clock
        %   Axis.HandleClock()
        %   updates the position reading and the Axis status (=/~moving)
            try
                if this.uitActive.lVal
                    dPosRaw = this.api.getPosition(this.cName);
                else
                    dPosRaw = this.avVirtual.getPosition();
                end
                % update uitxPos
                if this.uitCal.lVal
                    % cal
                    this.uitxPos.cVal = sprintf('%.3f', this.asSetup.raw2cal(dPosRaw)); %num2str(this.asSetup.raw2cal(dPosRaw));                    
                else
                    % raw
                    this.uitxPos.cVal = sprintf('%.3f', dPosRaw); % num2str(dPosRaw);
                end
                % if it is showing playing and should show stopped, flip the
                % play/pause button
                if (this.destRaw() == dPosRaw) && this.uitPlay.lVal
                    % switch toggle off (show play button)
                    this.uitPlay.lVal = false;
                end
        %             if (this.destRaw() ~= dPosRaw) && ~this.uitPlay.lVal 
        %                 % switch toggle on (show pause button)
        %                 this.uitPlay.lVal = true;
        %             end

            catch err
                this.msg(getReport(err));
        %         %AW(5/24/13) : Added a timer stop when the axis instance has been
        %         %deleted
        %         if (strcmp(err.identifier,'MATLAB:class:InvalidHandle'))
        %                 %msgbox({'Axis Timer has been stopped','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
        %                 stop(this.t);
        %         else
        %             this.msg(getReport(err));
        %         end
                rethrow(err)
            end %try/catch
        end
        
        
        function handleUI(this, src, ~)
        %HANDLEUI Callback for the User interface (uicontrols etc.)
        %   Axis.handleUI(src,~)
            
        % modified to allow backward compatibility (Matlab 2011a)    
        %     switch src
        %         
        %         case this.uibStepPos
        %             this.stepPos();
        %             
        %         case this.uibStepNeg
        %             this.stepNeg();
        %             
        %         case this.uieDest
        %             % if there is an enter key press, move to destination
        %             if uint8(get(this.hParent,'CurrentCharacter')) == 13
        %                 this.moveToDest();
        %             end
        %             
        %         case this.uitPlay
        %             if this.uitPlay.lVal
        %                 this.moveToDest();
        %             else
        %                 this.stopMove();
        %             end
        %             
        %         case this.uibSetup
        %             this.as.build();
        %             
        %         case this.uitCal
        %             this.updateDestUnits();
        %             % uitxPos will automatically change the next time the
        %             % value is refreshed
        %         case this.uibIndex
        %             this.index();
        %             
        %     end


            if (src==this.uibStepPos)
                this.stepPos();
            elseif (src==this.uibStepNeg)
                this.stepNeg();

            elseif (src==this.uieDest)
                % if there is an enter key press, move to destination
                if uint8(get(this.hParent,'CurrentCharacter')) == 13
                    this.moveToDest();
                end

            elseif (src==this.uitPlay)
                if this.uitPlay.lVal
                    this.moveToDest();
                else
                    this.stopMove();
                end

            elseif (src==this.uibSetup)
                this.asSetup.build();

            elseif (src==this.uitCal)
                this.updateDestUnits();
                % uitxPos will automatically change the next time the
                % value is refreshed
            elseif (src==this.uibIndex)
                this.index();
            end
        end

        %FIXME : Can the three following callbacks be refactored?
        function handleCalibrationChange(this, ~, ~)
        %HANDLECALIBRATIONCHANGE Callback to handle change in RAW/Cal mode

            %this.msg('Axis.handleCalibrationChange()'); %TODO remove when finalized
            if this.uitCal.lVal

                % cal

                % need to update dMin, dMax, and val of uieDest since
                % raw2cal has changed.  For dest pos, set to motor pos set
                % dest to motor pos since there is no way to compute the
                % previous dest from current cal dest since cal2raw has
                % changed (slope has changed).

                if this.uitActive.lVal
                    dPos = this.api.getPosition(this.cName);
                else
                    dPos = this.avVirtual.getPosition();
                end

                % AxisSetup dispatches eCalibrationChange before updating
                % lowLimitCal and highLimitCal.  The reason is that when we
                % change units of uieDest, we need to set the new val, min,
                % and max at the same time.  If we set limits, then tried
                % to set value, dMax may be less than val and/or dMin may
                % be larger than dMin.  To get the calibrated limits,
                % convert lowLimitRaw to cal with raw2cal (raw2cal will use
                % updated slope and offset).  If you use lowLimitCal, this
                % will not have been updated.

                this.uieDest.setMinMaxVal( ...
                    this.asSetup.raw2cal(this.asSetup.uieLowLimitRaw.val()), ...
                    this.asSetup.raw2cal(this.asSetup.uieHighLimitRaw.val()), ...
                    this.asSetup.raw2cal(dPos) ...
                    );
            else
                % raw

                % do not need to update anything since raw values are not
                % affected by slope and offset
            end
        end

        function handleLowLimitChange(this, ~, ~)
        %HANDLELOWLIMITCHANGE Callback to deal with RAW/Cal mode
            
            %this.msg('Axis.handleLowLimitChange()'); %TODO remove when finalized
            % update dMin of uieDest
            if this.uitCal.lVal
                this.uieDest.setMin(this.asSetup.uieLowLimitCal.val());
            else
                this.uieDest.setMin(this.asSetup.uieLowLimitRaw.val());
            end  
        end

        
        function handleHighLimitChange(this, ~, ~)
        %HANDLEHIGHLIMITCHANGE Callback to deal with RAW/Cal mode
            
            %this.msg('Axis.handleHighLimitChange()'); %TODO remove when finalized
            % update dMax of uieDest
            if this.uitCal.lVal
                this.uieDest.setMax(this.asSetup.uieHighLimitCal.val());
            else
                this.uieDest.setMax(this.asSetup.uieHighLimitRaw.val());
            end   
        end

        function updateDestUnits(this)
        %UPDATEDESTUNITS Updates the position of the destination cal/raw
        
            if this.uitCal.lVal
                % was raw, should now be cal
                this.uieDest.setMinMaxVal( ...
                    this.asSetup.uieLowLimitCal.val(), ...
                    this.asSetup.uieHighLimitCal.val(), ...
                    this.asSetup.raw2cal(this.uieDest.val()) ...
                    );
            else
                % was cal, should now be raw
                this.uieDest.setMinMaxVal( ...
                    this.asSetup.uieLowLimitRaw.val(), ...
                    this.asSetup.uieHighLimitRaw.val(), ...
                    this.asSetup.cal2raw(this.uieDest.val()) ...
                    );
            end
        end

            % Because Axis can toggle units between cal and raw, uieDest.val()
            % can take on cal units or raw units.  If you want to set a
            % destination, you may want to do it in calibrated or raw units.  I
            % will build access for setting and retrieving cal or raw values


        function dOut = destCal(this)
        %DESTCAL Converts the dest position into cal units, if required
        %   Axis.destCal()  
        
            if this.uitCal.lVal
                dOut = this.uieDest.val();
            else
                dOut = this.asSetup.raw2cal(this.uieDest.val());
            end
        end

        
        function dOut = destRaw(this)
        %DESTRAW Converts the dest position into RAW units, if required
        %   Axis.destRAW()  
        
            if this.uitCal.lVal
                dOut = this.asSetup.cal2raw(this.uieDest.val());
            else
                dOut = this.uieDest.val();
            end

        end
        
        
    end

end %class
