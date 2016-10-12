classdef UIPopupStruct < HandlePlus
    
    
    
    properties (Constant)
        dHeight = 30;
    end
    
    properties
        
        u8Selected      % get selected index (force uint8)
        % cSelected

    end
    
    properties (SetAccess = private)
        
        cName
    end
    
    properties (Access = private)
        
        hLabel
        hUI
        cLabel
        lShowLabel
        ceOptions       % 1xm cell array of struct
        cField
        cTooltip = 'Tooltip: set me!';
    end
    
    
    events
      eChange  
    end
    
    
    methods
        
       
               
       function this= UIPopupStruct(stParams)
       %UIPOPUPSTRUCT - Similar to UIPopup except that each item in the
       %pulldown represents a structure rather than a char.  The idea is
       %that calling val() returns a structure with extra information about
       %the system state that the pulldown represetns.  It is a convenient
       %way to lump extra information into the pulldown.  For instance you
       %might want the pulldown to represent a set of saved positions of a
       %motor but you want labels to say "Filter 1", "Filter 2" and have
       %values stored internally as "234.21" "255.22".  If you want to do
       %thatm use UIPopupStruct instead of UIPopup
       %
       % Important to initialize the structure without using
       % struct(field1,val1, ...) constructor due to a weird way that it handles
       % values that are cell arrays.
       % You want to do something like:
       %
       % stOptionA = struct();
       % stOptionA.name = "Test A";
       % stOptionA.value = 100;
       %
       % stOptionB = struct();
       % stOptionB.name = "Test B";
       % stOptionB.value = 110;
       %
       % ceOptions = {stOptionA, stOptionB}
       %    @param {struct} stParams - the config paramaters
       %    @param {cell 1xm of struct} stParams.ceOptions - list of structures the pulldown
       %        represents.   Each struct can nave any number of fields
       %    @param {char 1xm} [stParams.cField = 'cLabel'] - the field of the option structure to use
       %        for the text in the pulldown
       %    @param {char 1xm} [stParams.cLabel = 'Change Me'] - the label of the pulldown
       %    @param {logical 1x1} [stParams.lShowLabel = true] - show the label if true
       %    @param {char 1xm} [stParams.cName = 'Default'] - the name for use in msg and logging  
                  
            stDefault = struct();
            stDefault.ceOptions{1}.cLabel = 'Item 1';
            stDefault.ceOptions{1}.dVal = 1;
            stDefault.ceOptions{2}.cLabel = 'Item 2';
            stDefault.ceOptions{2}.dVal = 2;
            stDefault.ceOptions{3}.cLabel = 'Item 3';
            stDefault.ceOptions{3}.dVal = 3;
            stDefault.cField = 'cLabel';
            stDefault.cLabel = 'Change Me';
            stDefault.cName = 'Default';
            stDefault.lShowLabel = true;
            
            
            stParams = mergestruct(stDefault, stParams);
            
            this.ceOptions = stParams.ceOptions;
            this.cField = stParams.cField;
            this.cLabel = stParams.cLabel;
            this.lShowLabel = stParams.lShowLabel;
            
                        
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight)
           
           
           if this.lShowLabel
               
               this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'HorizontalAlignment', 'left'...
                );
           
                dTop = dTop + 15;
           end
           
           
           this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', 'white', ...
                'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'popupmenu', ...
                'String', this.getLabels(), ...
                'Callback', @this.cb, ...
                'TooltipString', this.cTooltip, ...
                'HorizontalAlignment','left'...
            );
        
       end
       
       
       function cb(this, src, evt)
           
            switch src
                case this.hUI
                    this.u8Selected = uint8(get(src, 'Value'));
            end

       end
       
       
       % modifiers
       
       function set.ceOptions(this, ceVal)
       %SETCEOPTIONS
       
          
           % prop
           if iscell(ceVal)
                this.ceOptions = ceVal;
                
                if ~isempty(this.u8Selected)
                    
                    % Correct for the case when the number of options has
                    % decreased to less than the active option before they
                    % were updated
                    
                    if this.u8Selected > length(this.ceOptions)                        
                        this.u8Selected = uint8(length(this.ceOptions));
                    end
                    
                    % Correct for the case when ceOptions was empty and it
                    % was just now filled.  For this case u8Selected would
                    % be 0 and would not make it into the above logic.
                    % Need to update u8Selected to 1
                    
                    if this.u8Selected == uint8(0) && ...
                       ~isempty(this.ceOptions)
                   
                        this.u8Selected = uint8(1);
                    end
                    
                else
                    this.u8Selected = uint8(1); % default
                end
                
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
                set(this.hUI, 'Value', this.u8Selected);
                set(this.hUI, 'String', this.getLabels());               
           end
           
           
           notify(this,'eChange');
           
       end
       
       function set.u8Selected(this, u8Val)
           
           % prop
           if isinteger(u8Val)
               if(u8Val <= length(this.ceOptions))
                   this.u8Selected = u8Val;
                   % this.cSelected = this.ceOptions{this.u8Selected};
               end
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'Value', this.u8Selected);
           end
           
           notify(this,'eChange');
               
       end
       
       function out = val(this)
       %VAL
       %    @returns {struct 1x1} - the u8Selected index of this.ceOptions 
       %        (it is a sctuct)
       
            out = this.ceOptions{this.u8Selected};
       end
       
       function show(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
                % Make sure correct item is showing if it was changed while
                % the UI was not visible
                set(this.hUI, 'Value', this.u8Selected);
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
    

    methods (Access = protected)
        
        
        function ceLabels = getLabels(this)
        %GETLABELS
        %   @return {cell 1xm} - parst the list of structures and return a
        %   cell array to be used as the labels of the pulldown
        
            % Use dynamic fieldname syntax allows to access structure field
            % with variable.  It looks like this
            %
            % a = 'car'
            % b = struct();
            % b.car = 'ferrari';
            % b.(a) % gives 'ferrari'
        
            ceLabels = cell(1, length(this.ceOptions));
            for n = 1: length(this.ceOptions) 
                ceLabels{n} = this.ceOptions{n}.(this.cField);
            end
            
            
        end


    end
end