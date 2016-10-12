classdef Utils
%UTILS is a static class that contains a set of method useful for
%   dealing with graphical user interface.

    
%% Constant Properties
    properties (Constant)
        bDispLoadSave       = 0;
        dEDITHEIGHT         = 30;
        dLABELHEIGHT        = 15;
        dTEXTHEIGHT         = 15;
        dEditPad            = 10;
        dPanelTopPad        = 20;
        dPanelBotPad        = 10;
        dColorPre           = [0.8 0.8 0.8];
        dColorActive        = [0.9 0.9 0.9];
        dColorPost          = [0.07 0.38 0.07];
                
        dColorEditBgVerified    = [0.07 0.38 0.07];
        dColorTextBgVerified    = [0.07 0.38 0.07];
         
        cUpDir = sprintf('..%s', filesep)
    end

    %% Static Methods
    methods (Static)

        
        function c = pathAssets()
            [cPath, cName, cExt] = fileparts(mfilename('fullpath'));

            % Add core
            c = fullfile(cPath, sprintf('..%s', filesep), 'assets');
            
        end
        
        function c = pathConfig()
            [cPath, cName, cExt] = fileparts(mfilename('fullpath'));

            % Add core
            c = fullfile(cPath, sprintf('..%s', filesep), 'config');
            
        end
        
        
        function ok = checkNum(varargin)
        % CHECKNUM Is to be used on any edit box in a GUI where someone inputs a number
        %   This method is to be used on any edit box in a GUI where someone inputs
        %   a number.  It checks to make sure the user input falls within spec.  
        %   The order goes:
        %       *Is there a number in the box?
        %       *If it is required to be an integer is it an integer?
        %       *If there is a range is it in the allowed range?
        %
        % OK = Utils.checkNum(ARGUMENTS)
        % Inputs - two min, four max
        %   *input 1 = num from edit (use str2num)
        %   *input 2 = intFlag
        %   *input 3 (optional) = minVal
        %   *input 4 (optional) = maxVal
        %
        % See also ISPROP, ISMETHOD

            ok = 0;    % disp('(checkNum)');

            switch nargin
                case 1
                    beep;
                    error('The function checkNumber needs at least string and intFlag inputs')
                    return;

                case 2
                    val = varargin{1};
                    intFlag = varargin{2};
                    rangeCheck = 0;

                case 3
                    beep;
                    error('The function checkNumber requires a maxVal if you supply a minVal')
                    return;

                case 4
                    val = varargin{1};
                    intFlag = varargin{2};
                    minVal = varargin{3};
                    maxVal = varargin{4};
                    rangeCheck = 1;
            end

            % Is there a number in the box?
            if isempty(val)
                if rangeCheck & intFlag
                    msgString = sprintf('Please input an integer between %1.0f and %1.0f into the current field', minVal, maxVal);
                elseif rangeCheck & ~intFlag
                    msgString = sprintf('Please input a value between %1.1f and %1.1f into the current field', minVal, maxVal);
                elseif intFlag
                    msgString = sprintf('Please input an integer into the current field.');
                else
                    msgString = sprintf('Please input a value into the current field.');
                end
                beep;
                msgbox(msgString,'Invalid Entry','warn')
                return;
            end

            % If it is required to be an integer is it an integer?
            if intFlag
                if val ~= round(val)
                    if rangeCheck
                        msgString = sprintf('Please input an integer between %1.0f and %1.0f into the current field', minVal, maxVal);
                    else
                        msgString = sprintf('Please input an integer into the current field.');
                    end
                    beep;
                    msgbox([msgString,' Attempted entry = ',num2str(val)],'Invalid Entry','warn')
                    return;
                end
            end

            % If there is a range is it in the aloud range?
            if rangeCheck
                if val > maxVal | val < minVal
                    beep;
                    if intFlag
                        msgString = sprintf('Please input an integer between %1.0f and %1.0f into the current field', minVal, maxVal);
                    else
                        msgString = sprintf('Please input a value between %1.1f and %1.1f into the current field', minVal, maxVal);
                    end
                    msgbox([msgString,' Attempted entry = ',num2str(val)],...
                        'Invalid Entry',...
                        'warn')
                    return;
                end
            end

            ok = 1;
        end




        function out = isProp(oThis,sProperty)
        %ISPROP Checks if sProperty:String is a property of oThis:Object
        %
        %   EVENTUALLY THIS SHOULD BE DEPRECATED AND INSTEAD WE SHOULD USE 
        %   oMetaProperty = findprop(class,'property'); since
        %   meta.property objects have all of the meta associated with
        %   the property
        %
        % out = Utils.isProp(oThis,sProperty)
        %
        % See also CHECKNUM, ISMETHOD
        

            caProp = properties(oThis);
            if(~isempty(strmatch(sProperty,caProp,'exact')))
                out = 1;
            else
                out = 0;
            end
        end

        function out = isMethod(oThis,sMethod)
        %ISMETHOD Checks if sMethod:String is a method of oThis:Object
        % out = Utils.isMethod(oThis,sMethod)
        %
        % See also CHECKNUM, ISPROP
            if(~isempty(strmatch(sMethod,methods(oThis),'exact')))
                out = 1;
            else
                out = 0;
            end
        end



        function out = uicontrolY(nHeightFromTopOfParent,hParent,nUicontrolHeight)
        %UICONTROLY Gets the position of the uicontrol relative to its
        % parent sarting bottom left
        %     Matlab uses the bottom left corner rather the top left for
        %     positioning which makes laying out a GUI a total pain.
        %     This method will let me specify the y position of
        %     elements as the distance from the top of their parent, which
        %     is the most intuitive way to do it.
        %
        % Y_POSITION = uicontrolY(nHeightFromTopOfParent,hParent,nUicontrolHeight)
        %     @parameter nHeightFromTopOfParent (Number)
        %     @parameter hParent (Handle)
        %     @parameter nUicontrolHeight (Number)
        %
        % See also PANELHEIGHT, UIH, UIW, UD, LT2LB


            This will return the distance from the bottom of the
            parent to the bottom of the UIcontrol

            vnParentPosition = get(hParent,'Position');
            nParentHeight = vnParentPosition(4);
            out = nParentHeight - nHeightFromTopOfParent - nUicontrolHeight;

        end

        function out = lt2lb(dLTWH, hParent)
        %LT2LB Allows to set the position of a uielement from the bottom
        %
        %     Matlab uses the bottom left corner rather the top left for
        %     positioning which makes laying out a GUI a total pain. This
        %     method will let me specify the position of UI elements as
        %     [left top width height], which is the most intuitive way to
        %     do it.  It returns [left bottom width height]
        %
        % out = Utils.lt2lb(dLTWH, hParent)
        %   where  :
        %     dLTWH (double [1x4]) [left top width height] of UI element
        %     hParent (handle) UI parent (usually a panel or figure)
        %
        % See also PANELHEIGHT, UIH, UIW, UD, UICONTROLY
        
            try %FIXME // 2013-11-08 AW : added a try/catch because the element won't draw on a gcf
                dParentPosition = get(hParent,'Position');
                dParentHeight = dParentPosition(4);
                dBottom = dParentHeight - dLTWH(2) - dLTWH(4);

                out = dLTWH;
                out(2) = dBottom;
            catch err
                disp('Utils::lt2lb unable to draw the element to the specified position')
                out = dLTWH
            end
        end


        function whileDisplay(sLocation)
        %WHILEDISPLAY Allows to print where one is located in a while loop
        %   Utils.whileDisplay(sLocation)
            disp(sprintf('In while loop at: %s',sLocation));
        end

        function out = uih(hUI)
        %UIH Returns the height of UI element
        %   HEIGHT = Utils.uih(HANDLE)
        %
        % See also PANELHEIGHT, UIW, UT, LT2LB, UICONTROLY
        
            dPos = get(hUI, 'Position'); % [1x4] Double LBHW
            out = dPos(4);

        end

        function out = uiw(hUI)
        % UIW Returns the  width of UI element
        %   WIDTH = Utils.uih(HANDLE)
        %
        % See also PANELHEIGHT, UIH, UT, LT2LB, UICONTROLY
        
            dPos = get(hUI, 'Position'); % [1x4] Double LBHW
            out = dPos(3);
        end

        function out = ut(hUIChild, hUIParent)
        %UT 'update top' and it is used for positioning uielements
        %   OUT = Utils.ut(hUIChild, hUIParent)
        %
        % See also PANELHEIGHT, UIH, UIW, LT2LB, UICONTROLY
                
            % return child.top + child.height + padding
            dPosParent = get(hUIParent, 'Position');  % [1x4] Double LBHW
            dPosChild = get(hUIChild, 'Position');        % [1x4] Double LBHW
            % child.top = parent.height - child.bottom - child.height
            % child.top + child.height = parent.height - child.bottom
            out = dPosParent(4) - dPosChild(2) + 10;

        end


        function out = panelHeight(u8Edits)
        % PANELHEIGHT 
        %   out = Utils.panelHeight(u8Edits)
        %       u8Edits: number of stacked edits in panel
        %
        % See also UIH, UIW, UT, LT2LB, UICONTROLY
            out = Utils.dPanelTopPad + ...
                Utils.dPanelBotPad + ...
                u8Edits*(Utils.dEDITHEIGHT + Utils.dLABELHEIGHT) + ...
                (u8Edits-1)*Utils.dEditPad;
        end

        function absolute_position = get_screenPos(h)
        % GET_SCREENPOS Gets the absolute position of the handle
        %   position = Utils.get_screenPos(handle), where position is a
        %   vector containing horizontal and vertical position, width and height
        %
        % See also GET_EDITABLE, GET_NEXTEDIT, SCROLL_INCREMENT


            %making sure the format is good !
            if ~ishandle(h)
                error('UTILS.get_screenPos argument is not an handle !')
            end

            if  ~isequal(size(h),[1 1])
                error('UTILS.get_screenPos does not accept vectors of handle as argument')
            end

            %we get the position of the element relative to his parent
            pos = get(h,'Position');
            if length(pos) == 4 %if the element is "square" (has height and width)
                current_handle = h;
                %   let's go up in the hierarchy and summ all the positions
                % We eventually end up on the super-parent who has an absolute
                % position
                while(get(current_handle,'Parent')~=0)
                    current_handle = get(current_handle,'Parent');
                    pos = pos + get(current_handle,'Position');
                end
            end

            %let's output the absolute position for the 2 first rows
            absolute_position(1:2) = pos(1:2);
            % and fill the rest with width and height
            hw = get(h,'Position');
            absolute_position(3:4) =  hw(3:4);
        end

        function editable_handle = get_editable(handle, mouse_position)
        %GET_EDITABLE Returns the handle to an editbox that is located
        % under the mouse pointer, if any.
        %   This method is primarily meant to allow Mousescroll interaction
        %
        % editable_handle = get_editable(handle, mouse_position)
        %
        % See also GET_SCREENPOS, GET_NEXTEDIT, SCROLL_INCREMENT

            %in case there is no editable box, let's output a null vector
            editable_handle = [];

            %get the mouse position 
            xy = mouse_position;
            %find all the edit boxes there are
            eboxes = findall(handle,'Style','edit');      
            for i=1:length(eboxes)
                %get the absolute position for each editbox
                xyi = Utils.get_screenPos(eboxes(i));
                %if the editbox lies under the mouse pointer, select and output the
                %handle !
                if (xyi(1)<xy(1) && xyi(1)+xyi(3)>xy(1) && xyi(2)+xyi(4)>xy(2) && xyi(2)<xy(2))
                    editable_handle = eboxes(i);
                end
            end
        end
        
        function keyboard_navigation(src, evt)
        %KEYBOARD_NAVIGATION Is a cb that allows to navigate between eboxes
        % In order to use it, the parent figure must have its callback set:
        %     set(gcf,'KeyPressFcn', @keyPress)
        %
        % See also GET_SCREENPOS, GET_EDITABLE, GET_NEXTEDIT, SCROLL_INCREMENT
            if (strcmp(evt.Modifier,'control') == 1)
                switch evt.Key
                    case 'i'
                        direction = 'up';
                        Utils.get_nextEdit(src, direction);
                    case 'k'
                        direction = 'down';
                        Utils.get_nextEdit(src, direction);
                    case 'j'
                        direction = 'left';
                        Utils.get_nextEdit(src, direction);
                    case 'l'
                        direction = 'right';
                        Utils.get_nextEdit(src, direction);
                end

            %elseif (strcmp(evt.Modifier,'control') == 1)
            end 
        end

        function next_handle = get_nextEdit(edit_handle, direction)
        %GET_NEXTEDIT Gives you the handle to the closes edit box in the
        % said direction.
        %
        % next_handle = get_nextEdit(edit_handle, direction)
        %   edit_handle is a handle to an edit box
        %   direction = {'up','down','left','right'}
        %
        % See also GET_SCREENPOS, GET_EDITABLE, SCROLL_INCREMENT, KEYBOARD_NAVIGATION

            %get to the master handle
            master_handle = edit_handle;
            while(get(master_handle,'Parent')~=0)
                master_handle = get(master_handle,'Parent');
            end
            eboxes = findall(master_handle,'Style','edit');

            mypos = Utils.get_screenPos(edit_handle);
            mycenter(1) = mypos(1)+mypos(3)/2;
            mycenter(2) = mypos(2)-mypos(4)/2;

            dist = zeros(2,length(eboxes));
            for i = 1:length(eboxes)
                epos = Utils.get_screenPos(eboxes(i));
                ecenter(1) = epos(1)+epos(3)/2;
                ecenter(2) = epos(2)-epos(4)/2;
                if(isequal(eboxes(i),edit_handle)) %self-distance
                    dist(1:2,i) = 0;
                else
                    dist(1,i) = sin(atan2(ecenter(2)-mycenter(2),ecenter(1)-mycenter(1)))...
                        ./norm(ecenter-mycenter);
                    dist(2,i) = cos(atan2(ecenter(2)-mycenter(2),ecenter(1)-mycenter(1)))...
                        ./(norm(ecenter-mycenter));
                end
            end

            switch direction
                case 'up'
                    [~,idx] = max(dist(1,:));
                case 'down'
                    [~,idx] = max(-dist(1,:));
                case 'left'
                    [~,idx] = max(-dist(2,:));
                case 'right'
                    [~,idx] = max(dist(2,:));
            end

            next_handle = eboxes(idx);
            if nargout == 0
                uicontrol(next_handle);
            end
        end

        %% Event handlers

        %   set(gcf,'WindowScrollWheelFcn',@Utils.scroll_increment)
        function scroll_increment( src, evt )
        %SCROLL_INCREMENT Is a cb function designed to increment an editbox
        %
        % It can be used this way :
        %   set(gcf,'WindowScrollWheelFcn',@Utils.scroll_increment)
        %
        % See also GET_SCREENPOS, GET_EDITABLE, GET_NEXTEDIT, KEYBOARD_NAVIGATION

            %find the edit box located under the mouse pointer
            edit_handle = Utils.get_editable(src, get(src,'CurrentPoint'));
            %get the direction of the scroll
            delta = -sign(evt.VerticalScrollCount);

            %format check
            if ~isempty(edit_handle) && ishandle(edit_handle)
                %get the string of the edit box
                edit_string = get(edit_handle,'String');
                try %tricky, because there is no typecheck on the box so far %FIXME to change
                    incremented_string = num2str(str2double(edit_string)+delta);
                    set(edit_handle,'String',incremented_string);
                    %validate the change in the textbox
                    callbackCell = get(edit_handle,'Callback');
                    callbackCell(edit_handle)
                catch err
                    disp('Utils.scroll_increment : an error occured !')
                end
            end
        end
        
        function deleteChildren(h)
            
            % This is a utility to delete all children of an axes, hggroup,
            % or hgtransform instance
            
            if ~ishandle(h)
                return
            end
            
            hChildren = get(h, 'Children');
            for k = 1:length(hChildren)
                if ishandle(hChildren(k))
                    delete(hChildren(k));
                end
            end
        end
        
        %{
        function cReturn = saveAs(cTempName, cPath)
            
            % Open an input dialogue pre-filled with a name prompt.  Return
            % a nonempty char (String) if the string the user submits is
            % not already a file in cPath, return an empty if they cancel
            % out.  If the user tries a name that is already a saved file,
            % it gives them a chance to pick a different name.
                        
            % Prompt user for a save name. inputdlg returns type cell
            ceName = inputdlg({'Save As:'}, 'Save', [1 100], {cTempName});

            % Check to see if the user hit the cancel button; inputdlg
            % returns an empty cell on cancel.  Also make sure the user
            % input something

            if ~isempty(ceName)

                % Didn't hit cancel
                % Make sure the string is not empty

                if ~strcmp(ceName{1}, '')

                    % Not empty
                    % Check to see if this file already exists
                    
                    if exist(fullfile(cPath, [ceName{1}, '.mat']), 'file') ~= 0

                        % The save name already exists, ask the user if
                        % they want to overwrite

                        cAns = questdlg( ...
                            'This file already exists, do you want to overwrite it with the current file?', ...
                            'Warning', ...
                            'Yes', ...
                            'Cancel', ...
                            'Cancel' ...
                        );

                        switch cAns
                            case 'Yes'

                                % Save
                                cReturn = ceName{1};

                            otherwise

                                % Return empty
                                % cReturn = '';
                                cReturn = Utils.saveAs(cName, cPath);
                        end
                    
                    
                    else

                        % The name the user typed is not in the existing
                        % list of names. Save.

                        cReturn = ceName{1};
                         
                    end
                else

                    % Empty - did not type anything
                    % Throw a warning box and recursively call

                    h = msgbox( ...
                        'Oops! I think you forgot to type something.  Click OK below to try again.', ...
                        'Empty name', ...
                        'warn', ...
                        'modal' ...
                        );

                    % wait for them to close the message
                    uiwait(h);

                    % recursively call
                    cReturn = Utils.saveAs(cName, cPath);

                end


            else
                % hit cancel do nothing
                cReturn = '';
            end
            
        end
        
        %}
        
        
        function cReturn = listSaveAs(cName, ceOptions)
          
            % @parameter    (char)          prompt for save as
            % @parameter    (cell of char)  list of options to compare against   
            % @return       (char)          the string the user submits.  '' if
            % they cancel out
            
            % Open an input dialogue pre-filled with a name prompt.  Return
            % a nonempty char (String) if the string the user submits is
            % not already an option on the list, return an empty if they
            % cancel out.  If the user tries a name that is on the list, it
            % gives them a chance to pick a different name.

            % Had considered using uiputfile but decided against it
            % [FileName,PathName,FilterIndex] = uiputfile(FilterSpec,DialogTitle,DefaultName)
            
            % Prompt the user for the save name with the suggestion as
            % the default

            % Prompt user for a save name. inputdlg returns type cell
            ceName = inputdlg({'Save As:'}, 'Save', [1 100], {cName});

            % Check to see if the user hit the cancel button; inputdlg
            % returns an empty cell on cancel.  Also make sure the user
            % input something

            if ~isempty(ceName)

                % Didn't hit cancel
                % Make sure the string is not empty

                if ~strcmp(ceName{1}, '')

                    % Not empty
                    % Check to see if this string already exists

                    if isempty(strmatch(ceName{1}, ceOptions, 'exact'))

                        % The name the user typed is not in the existing
                        % list of names. Save.

                        cReturn = ceName{1};

                    else

                        % The save name already exists, ask the user if
                        % they want to overwrite

                        cAns = questdlg( ...
                            'This name already exists, do you want to overwrite it with the current data?', ...
                            'Warning', ...
                            'Yes', ...
                            'Cancel', ...
                            'Cancel' ...
                        );

                        switch cAns
                            case 'Yes'

                                % Save
                                cReturn = ceName{1};


                            otherwise

                                % Return empty
                                % cReturn = '';
                                cReturn = Utils.listSaveAs(cName, ceOptions);
                        end 
                    end
                else

                    % Empty - did not type anything
                    % Throw a warning box and recursively call

                    h = msgbox( ...
                        'Oops! I think you forgot to type something.  Click OK below to try again.', ...
                        'Empty name', ...
                        'warn', ...
                        'modal' ...
                        );

                    % wait for them to close the message
                    uiwait(h);

                    % recursively call
                    cReturn = Utils.listSaveAs(cName, ceOptions);

                end


            else
                % hit cancel do nothing
                cReturn = '';
            end
           
            
        end
        
        
        function ceReturn = dir2cell(cPath, cSortBy, cSortMode, cFilter)
            
            % cPath         char    dir path without trailing slash
            % cSortBy       char    date, name
            % cSortMode     char    descend, ascend
            % cFilter       char    '*.mat', '*', etc
                        
            if exist('cSortBy', 'var') ~= 1
                cSortBy = 'date';
            end
            
            if exist('cSortMode', 'var') ~= 1
                cSortBy = 'descend';
            end
            
            if exist('cFilter', 'var') ~= 1
                cFilter = '*.mat';
            end
            
                                        
            % Get a structure (size n x 1) for each .mat file.  Each structure
            % contains: name, date, bytes, isdir, datenum
            
            stFiles = dir(sprintf('%s/%s', cPath, cFilter));
            
                    
            % [stFiles.datenum] generates a 1 x m double of Unix
            % timestamps
            %
            % {stFiles.name} generates a 1 x m cell of char of each
            % filename
            
            % When you want to sort by name, you have to do sort on the
            % cell of strings.  Unfortunately,  when you use sort on a cell
            % array of strings, the 'mode' parameter (ascending,
            % descending) does not work.  It will default to ascending and
            % you have to flip afterward if you want descending
            %
            % If you want to sort by date, we can use the datenum property
            % of the structure and can directly use the mode property of
            % the sort function
                                   
            switch (cSortBy)
                
                case 'date'    
            
                    [ceDate, dIndex] = sort([stFiles.datenum], cSortMode);
                    
                case 'name'
                    
                    [ceDate, dIndex] = sort({stFiles.name});

                    switch cSortMode
                        case 'ascend'
                        
                        case 'descend'
                            dIndex = fliplr(dIndex);     
                    end
            end
              
            
            stSortedFiles = stFiles(dIndex);
            ceReturn = {stSortedFiles.name};
                    
            if(isempty(ceReturn))
                ceReturn = cell(1, 0);
            end
            
        end
        
        function hideOtherHandles(h, ceh)
            
            % h     handle          the handle you want to keep visible
            % ceh   cell of handle  all other handles you want to hide
                                   
            for n = 1:length(ceh)            
                                
                if ishandle(ceh{n}) & ...
                   strcmp(get(ceh{n}, 'Visible'), 'on') & ...
                   (isempty(h) | ceh{n} ~= h)
                    % this.uipType.ceOptions{uint8(n)}));
                    set(ceh{n}, 'Visible', 'off');
                end
                
            end
            
            if ishandle(h)
                set(h, 'Visible', 'on');
            end
            
        end


    end % Static
end

