classdef Edit < mic.Base
%% Edit Class for MET5 Software
% This class is meant to supersede uicontrol 'text' style
% It can only handle one kind of data type (defined when instantiated)
% and performs various checks wheteher the entered value is compatible with
% this data type.
% It allows the definition of min/max boundaries and, when the type is
% numeric, to perform some calculation ('1+2','2*3','2^5-1 and '3e5' are valid expression)
% More complex procedures or arrrays are currently prohibited, but they can be
% implemented
% An export method 'exportValue' is defined so that a numerical value can
% be retrieved instead of a string (the type is the same as textbox allowed type)
%

% Antoine Wojdyla, April 3rd, 2013    
   
        %% properties
    properties (Constant, Access = private)
        dHeight = 18;
    end
    

    properties

        cData = ''  %this is what the textbox contains. feel free to access it directly...
        

        % val is not a property because it can be several different types.
        % We use val() and setVal() methods that force the correct type
    end


    properties (Access = private)
        cType = 'c';
        cHorizontalAlignment = 'left'
        lShowLabel = true;
        hLabel
        hUI % made private 2013.06.11 % made setAccess private 3013/06/20
        cTooltip = 'Tooltip: set me!';
        cKeyPressLast = '';
        % {logical 1x1} - used to wrap all calls to notify to allow
        % temporary disabling of notify
        lNotify = true;
    end


    properties (SetAccess = private)
        
        % hUI was here but we cannot have SetAccess = private properties
        % because load tries to set them
        
        xVal    % mixed type to store typecast version of cData
        xMin 
        xMax
        cLabel = 'Fix Me'
        dColorBg = [.94 .94 .94]; % MATLAB default
    end


    events
      eChange  
      eEnter
    end

    %%
    methods
        
        %% constructor
        % cLabel, cType, lShowLabel, cHorizontalAlignment
        function this = Edit(varargin)

            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
           switch this.cType
               case 'c'
                   this.cData = '';
               otherwise
                   this.cData = '0';
           end

        end

        %% Build
        function build(this, hParent, dLeft, dTop, dWidth, dHeight)

            if this.lShowLabel
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'BackgroundColor', this.dColorBg, ...
                    'HorizontalAlignment', 'left' ...
                );

                %'BackgroundColor', [1 1 1] ...
            
                dTop = dTop + 13;
            end
                
            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', [1 1 1], ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'edit', ...
                'String', this.cData, ...
                'KeyPressFcn',@this.uie_keyPressFcn, ... % 'KeyReleaseFcn', @this.onKeyRelease, ...
                'Callback', @this.cb, ...
                'TooltipString', this.cTooltip, ...
                'ButtonDownFcn',@this.uie_ButtonDownFcn, ...
                'HorizontalAlignment', this.cHorizontalAlignment ...
            );
        
            %'BackgroundColor', [1 1 1] ...

           
        end

        %% event handlers
        function cb(this, src, evt)

            switch src
                case this.hUI
                    this.cData = get(src, 'String');
            end  
            
            if uint8(this.cKeyPressLast) == 13
                if (this.lNotify)
                    notify(this, 'eEnter');
                end
            end
        end


        %% modifiers

        %%%%%% Setting the allowed data type
        function set.cType(this, cInputType)

            if ischar(cInputType)
                if (strcmp(cInputType,'c') ...
                   || strcmp(cInputType,'s') ...
                   || strcmp(cInputType,'d') ...
                   || strcmp(cInputType,'i8') ...
                   || strcmp(cInputType,'i16') ...
                   || strcmp(cInputType,'i32') ...
                   || strcmp(cInputType,'i64') ...
                   || strcmp(cInputType,'u8') ...
                   || strcmp(cInputType,'u16') ...
                   || strcmp(cInputType,'u32') ...
                   || strcmp(cInputType,'u64'))  

                    this.cType= cInputType;
                    %Force to type bounds
                    [xMinType xMaxType] = this.getTypeBounds();
                    this.xMin = xMinType;
                    this.xMax = xMaxType;
                end
            end
        end

        %%%%%% Forcing the range to match data type
        function [xMin xMax] = getTypeBounds(this)

            switch this.cType
                case 'u8'
                        xMin = 0;
                        xMax = 2^8-1;
                case 'u16'
                        xMin = 0;
                        xMax = 2^16-1;
                case 'u32'
                        xMin = 0;
                        xMax = 2^32-1;
                case 'u64'
                        xMin = 0;
                        xMax = 2^64-1;
                case 'i8'
                        xMin = -2^7;
                        xMax =  2^7-1;
                case 'i16'
                        xMin = -2^15;
                        xMax =  2^15-1;
                 case 'i32'
                        xMin = -2^31;
                        xMax =  2^31-1;
                 case 'i64'
                        xMin = -2^63;
                        xMax =  2^63;
                 case 's'
                        xMin = -realmax('single');
                        xMax = realmax('single');
                 case 'd'
                        xMin = -realmax('double');
                        xMax = realmax('double');
                otherwise

                    % 2013.05.15 CNA char because this method was issuing
                    % an error for type 'c' because nothing was being
                    % returned

                    % 2013.05.21 CNA getting rid of this.  Have clue why I
                    % added it.  But it is causing errors when using Ryans'
                    % save/load framework on Edits that are of type 'c'
                    % (char) because it would try to compare the min/max
                    % values of 0/1 to the character array and issue an
                    % error

                    % 2013.05.21 CNA realized I do need to assign them

                    xMin = [];
                    xMax = [];
            end
        end

        %%%%%%% Setting Min and Max values
        function setMin(this, xMin)
        % @param {mixed 1x1} the maximum value

            [xMinType xMaxType] = this.getTypeBounds();

            % 2013.05.21 CNA
            % Does not make sense to have xMin and xMax on Edits of type
            % 'c' (character array).  Eventually we may want to be able to
            % restrict the length of the string but for now I'm going to
            % return out of this method immediately if the instance is a
            % type 'c'

            if strcmp(this.cType, 'c')
                return;
            end

            % is xMin greater than min value supported by type
                if (isnumeric(xMin)) %format test
                    %make sure that the current editbox value is not
                    %smaller than the new minimum
                    if (~isempty(this.cData))
                        % the entered value have been checked once before, so
                        % that val should return a valid number
                        if (this.val() >= xMin)
                            this.xMin = xMin;
                            %force to type bounds

                            if xMin <= xMinType
                                this.xMin = xMinType;
                            end
                        else
                            cMsg = sprintf('Edit.set.xMin() in <%s> informs you that\nthe min value you are trying to set : %1.2f\nis bigger than the current value of the edit box :%1.2f.\nAutomatically setting xMin to the lower bound supported by the type : %1.2e', ...
                                this.cLabel, ...
                                xMin, ...
                                this.val(), ...
                                xMinType ...
                                );
                            cTitle = 'Edit.set.xMin() error';
                            msgbox(cMsg, cTitle, 'warn')                        


                        end
                    end
                    if isempty(this.xMin)
                        this.xMin = xMinType;
                    end
                end
                %that would be a very bad idea : this.forceToTypeBounds();
        end




        function setMax(this, xMax)
        % @param {mixed 1x1} the maximum value
        
            % 2013.05.21 CNA
            % Does not make sense to have xMin and xMax on Edits of type
            % 'c' (character array).  Eventually we may want to be able to
            % restrict the length of the string but for now I'm going to
            % return out of this method immediately if the instance is a
            % type 'c'


            if strcmp(this.cType, 'c')
                return;
            end

           [xMinType xMaxType] = this.getTypeBounds();

           if isnumeric(xMax)
               %make sure that the current editbox value is not
               %smaller than the new minimum
               if (~isempty(this.cData))
                    if (this.val() <= xMax)
                        this.xMax = xMax;
                        if xMax >xMaxType;
                            this.xMax = xMaxType;
                        end
                    else


                        cMsg = sprintf('Edit.set.xMax() in <%s> informs you that\nthe max value you are trying to set : %1.2f\nis smaller than the current value of the edit box :%1.2f.\nAutomatically setting xMax to the upper bound supported by the type : %1.2e', ...
                            this.cLabel, ...
                            xMax, ...
                            this.val(), ...
                            xMaxType ...
                            );
                        cTitle = 'Edit.set.xMax() error';

                        msgbox(cMsg, cTitle, 'warn')


                    end
               end
                if isempty(this.xMax)
                    this.xMax = xMaxType;
                end
           end

        end

        %%%%%%% Validating data
        function set.cData(this, cInputData)
            % properties
            if this.cType == 'c' %general case #implement parsing ?
                this.cData = cInputData;
            else %No chars in the string ?
                try
                    dInputData = eval(cInputData);
                    if (isequal(size(dInputData),[1 1]) ... 
                        && isempty(regexp(cInputData,':','ONCE')) ... 
                        && (isempty(this.xMin) || dInputData>=this.xMin) ...
                        && (isempty(this.xMax) || dInputData<=this.xMax )) %within boundaries ?

                        % 2012.04.18 CNA
                        % When this.xMin = [], there is no min bound (this
                        % can only happen for type double).  Likewise, when
                        % this.xMax = [], there is no max bound (again,
                        % this can only happen for type double)

                        %allow simple inbox calculations then reformat result
                        if (~isempty(regexp(cInputData,'[-+*/^eE]','ONCE')) && isempty(regexp(cInputData,'e[+-]','ONCE')))
                            this.cData = num2str(eval(cInputData));
                        elseif isempty(regexp(cInputData,'[a-df-z]','ONCE')) %can be removed if we want to allow complex calculations
                            this.cData = cInputData;
                        end
                    else

                       % 2012.04.22 CNA
                       % Adding message when trying to enter a value
                       % outside of the limtis

                       cMsg = sprintf('The val you are trying to set (%s) not between the limits: low = %1.2e, high = %1.2e.  Restoring last good value.', ...
                            cInputData, ...
                            this.xMin, ...
                            this.xMax ...
                            );
                        cTitle = 'Edit.set.cData() error';
                        msgbox(cMsg, cTitle, 'warn') 


                    end
                catch err
                    
                    %{
                    if (strcmp(err.identifier,'MATLAB:UndefinedFunction'))
                        msgbox({'Not a regular expression entered in the eval()','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                    elseif (strcmp(err.identifier,'MATLAB:m_unexpected_sep'))
                        msgbox({'no default value','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                    elseif (strcmp(err.identifier,'MATLAB:minrhs'))
                        msgbox({'You have tried to use a buitin function, without argument. Builtin functions are not supported','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                    elseif (strcmp(err.identifier,'MATLAB:m_unbalanced_parens'))
                        msgbox({'You have tried to use a built-in function, without proper parenthesis. Besides, built-in functions are not supported','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                    else
                        msgbox({'set.cData reported an exception of type :',err.identifier,'that is not yet supported','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                        %rethrow(err);
                    end
                    %}
                    rethrow(err);
                end
            end

            % ui
            if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'String', this.cData);
            end

        %             fprintf('Edit.set.cData(%s) this.cLabel = %s\n', ...
        %                 this.cData, ...
        %                 this.cLabel);


            %{
            2013.08.07 CNA 
            Store a typecast version of cData so the val() function can quickly
            retrieve it.  Why? val() is called in all of the timercb functions and
            is called more than any other function so we need it to be blazing
            fast.
            %}

            switch this.cType
                case 'c'
                    this.xVal = this.cData;
                case 's'
                    this.xVal = single(eval(this.cData));
                case 'd'
                    this.xVal = double(eval(this.cData));
                case 'i8'
                    this.xVal = int8(eval(this.cData));
                case 'i16'
                    this.xVal = int16(eval(this.cData));
                case 'i32'
                    this.xVal = int32(eval(this.cData));
                case 'i64'
                    this.xVal = int64(eval(this.cData));
                case 'u8'
                    this.xVal = uint8(eval(this.cData));
                case 'u16'
                    this.xVal = uint16(eval(this.cData));
                case 'u32'
                    this.xVal = uint32(eval(this.cData));
                case 'u64'
                    this.xVal = uint64(eval(this.cData));
            end

            if this.lNotify
                notify(this,'eChange');
            end

        end

        function xValue = val(this)
            xValue = this.xVal;
        end

        function setMinMaxVal(this, xMin, xMax, xVal)

            % this method allows us to set max, min, and value
            % simultaneously.  This is useful when we need to switch the
            % units of a Edit instance (i.e., the one in the axis
            % controller).  You can't change value, then max, then min
            % because the unit change may make any of those properties not
            % validate due to range issues

           % temporarily set xMax, xMin to the max allowed by the type so
           % when we set the value, it will be within the limits.  By
           % setting them to empty, the setter calls forceToTypeLimits on
           % both, which will set them to their limiting cases


           [xMinType xMaxType] = this.getTypeBounds();
           this.xMin = xMinType;
           this.xMax = xMaxType;

           this.setVal(xVal);
           this.xMin = xMin;
           this.xMax = xMax;           

        end


        function show(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end

            if ishandle(this.hLabel)
                set(this.hLabel, 'Visible', 'on');
            end


        end

        function hide(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end

            if ishandle(this.hLabel)
                set(this.hLabel, 'Visible', 'off');
            end


        end
        
        function styleDefault(this)
            
            % Make it look vanilla
           
            if ishandle(this.hUI)
                set(this.hUI, 'BackgroundColor', mic.Utils.dColorEditBgDefault);
            end

            if ishandle(this.hLabel)
                set(this.hLabel, 'BackgroundColor', mic.Utils.dColorTextBgDefault);
            end
           
            
        end
        
        function styleVerified(this)
            
            % Make it look vanilla
           
            if ishandle(this.hUI)
                set(this.hUI, 'BackgroundColor', mic.Utils.dColorEditBgVerified);
            end

            if ishandle(this.hLabel)
                set(this.hLabel, 'BackgroundColor', mic.Utils.dColorTextBgVerified);
            end
            
        end

        function setValWithoutNotify(this, xVal)
            this.lNotify = false;
            this.setVal(xVal);
            this.lNotify = true;
        end
        function setVal(this, xVal)
           % @parameter {mixed 1x1} xVal: can be any type the Edit supports

           % This method validates that xVal is of the type that this
           % instance is cast as (u8, u16, char, ...).  If validation
           % passses, it updates the cData property to the string
           % equivalent

           if (strcmp(this.cType, 's')  && isa(xVal, 'single') || ...
               strcmp(this.cType, 'd')  && isa(xVal, 'double') || ...
               strcmp(this.cType, 'i8') && isa(xVal, 'int8') || ...
               strcmp(this.cType, 'i16')&& isa(xVal, 'int16') || ...
               strcmp(this.cType, 'i32')&& isa(xVal, 'int32') || ...
               strcmp(this.cType, 'i64')&& isa(xVal, 'int64') || ...
               strcmp(this.cType, 'u8') && isa(xVal, 'uint8') || ...
               strcmp(this.cType, 'u16')&& isa(xVal, 'uint16') || ...
               strcmp(this.cType, 'u32')&& isa(xVal, 'uint32') || ...
               strcmp(this.cType, 'u64')&& isa(xVal, 'uint64'))

               this.cData = num2str(xVal);
           elseif (strcmp(this.cType, 'c') && ischar(xVal))

               this.cData = xVal;
           else
               cMsg = sprintf(...
                   '%s ERROR: cType = %s.  You passed a %s', ...
                   this.id(), ...
                   this.cType, ...
                   class(xVal)...
               );
               this.msg(cMsg);
               msgbox(cMsg, 'Edit.setVal() invalid type', 'error');
           end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%PROTOTYPING ZONE%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %nothing

         function onKeyPress(this, src, evt)
            
             % The KeyPress function is evoked before the 
             % Callback function is evoked.  This is problematic because
             % the value returned by
             % get(src, 'String') inside of the KeyPress handler is not equal
             % to the newly entered string until after the callback is
             % executed.  SO DUMB. 
             %
             % The CALLBACK function is evoked if the user presses enter in
             % the edit box however there is no way to know if the callback
             % was evoked from an enter press or from the user clicking 
             % another component.
             %
             % A workaround is to always store the last key pressed
             % and then check this.cKeyPressLast inside of the callback.
             % If the callback is evoked from an enter press, first this
             % function evokes (updating cKeyPressLast) so that it can
             % trigger a notify('eEnter') inside of the CALLBACK
             
             this.cKeyPressLast = evt.Character;
         end
         
         function onKeyRelease(this, src, evt)
             if uint8(evt.Character') == 13
                 if this.lNotify
                    notify(this, 'eEnter');
                 end
             end
         end
         function uie_keyPressFcn(this, src, evt)
        %      switch evt.Key
        %          case {'uparrow', 'i'}
        %              disp('going up !');
        %          case {'downarrow', 'k'}
        %              disp('going down !')
        %          case {'leftarrow','j'}
        %              disp('going left !')
        %          case {'rightarrow', 'l'}
        %              disp('going right !')
        %this.hUI
        
            
            this.onKeyPress(src, evt);
            mic.Utils.keyboard_navigation(src, evt)
        %      end
        
            
            
         end

        function uie_ButtonDownFcn(this, src, evt)
            %this.hUI
        end

           %% Save & Load 
            %                                 vv
            %                      vvv^^^^vvvvv
            %                  vvvvvvvvv^^vvvvvv^^vvvvv
            %         vvvvvvvvvvv^^^^^^^^^^^^^vvvvv^^^vvvvv
            %     vvvvvvv^^^^^^^^^vvv^^^^^^^vvvvvvvvvvv^^^vvv
            %   vvvv^^^^^^vvvvv^^^^^^^vv^^^^^^^vvvv^^^vvvvvv
            %  vv^^^^^^^^vvv^^^^^vv^^^^vvvvvvvvvvvv^^^^^^vv^
            %  vvv^^^^^vvvv^^^^^^vvvvv^^vvvvvvvvv^^^^^^vvvvv^
            %   vvvvvvvvvv^^^v^^^vvvvvv^^vvvvvvvvvv^^^vvvvvvvvv
            %    ^vv^^^vvvvvvv^^vvvvv^^^^^^^^vvvvvvvvv^^^^^^vvvvvv
            %      ^vvvvvvvvv^^^^vvvvvv^^^^^^vvvvvvvv^^^vvvvvvvvvv^v
            %         ^^^^^^vvvv^^vvvvv^vvvv^^^v^^^^^^vvvvvv^^^^vvvvv
            %  vvvv^^vvv^^^vvvvvvvvvv^vvvvv^vvvvvv^^^vvvvvvv^^vvvvv^
            % vvv^vvvvv^^vvvvvvv^^vvvvvvv^^vvvvv^v##vvv^vvvv^^vvvvv^v
            %  ^vvvvvv^^vvvvvvvv^vv^vvv^^^^^^_____##^^^vvvvvvvv^^^^
            %     ^^vvvvvvv^^vvvvvvvvvv^^^^/\@@@@@@\#vvvv^^^
            %          ^^vvvvvv^^^^^^vvvvv/__\@@@@@@\^vvvv^v
            %              ;^^vvvvvvvvvvv/____\@@@@@@\vvvvvvv
            %              ;      \_  ^\|[  -:] ||--| | _/^^
            %              ;        \   |[   :] ||_/| |/
            %              ;         \\ ||___:]______/
            %              ;          \   ;=; /
            %              ;           |  ;=;|
            %              ;          ()  ;=;|
            %             (()          || ;=;|
            %                         / / \;=;\ 

        %% Destructor ?
        function delete(this)
            
            cMsg = sprintf('delete() %s', this.cLabel);
            % this.msg(cMsg);
            
        %     if ~isempty(this.hUI)
        %         delete(this.hUI);
        %     end
        end

        function l = isVisible(this)

            if ishandle(this.hUI)
                cVal = get(this.hUI, 'Visible');
                switch (cVal)
                   case 'on'
                       l = true;
                   otherwise
                       l = false;
                end
            else
                l = false;
            end
        end
        
        
        function enable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'on');
            end
        end
        
        function disable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'off');
            end
            
        end
        
        function setTooltip(this, cText)
        %SETTOOLTIP
        %   @param {char 1xm} cText - the text of the tooltip
        
            this.cTooltip = cText;
            if ishandle(this.hUI)        
                set(this.hUI, 'TooltipString', this.cTooltip);
            end
            
        end

    end
end