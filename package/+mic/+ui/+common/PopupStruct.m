classdef PopupStruct < mic.Base
    
%UIPOPUPSTRUCT - Similar to UIPopup except that each item in the
%pulldown represents a structure rather than a char.  The idea is
%that calling val() returns a structure with extra information about
%the system state that the pulldown represetns.  It is a convenient
%way to lump extra information into the pulldown.  For instance you
%might want the pulldown to represent a set of saved positions of a
%motor but you want labels to say "Filter 1", "Filter 2" and have
%values stored internally as "234.21" "255.22".  If you want to do
%thatm use PopupStruct instead of UIPopup
       %
    
    properties (Constant)
        dHeight = 30;
    end
    
    properties
        
        % {uint8 1x1} the active / selected index
        u8Selected      

    end
    
    properties (SetAccess = private)
        
    end
    
    properties (Access = private)
        
        % {cell 1xm of struct} list of structures the pulldown represents.
        % Each struct can nave any number of fields.  Default defined in
        % constructor
        ceOptions
        
        % {char 1xm} the field of the option structure to use for the text
        % in the pulldown
        cField = 'cLabel';     
        
        % {char 1xm} the label of the pulldown
        cLabel = 'Fix Me';
        
        % {logical 1x1} show the label?        
        lShowLabel = true;
        
        % {char 1xm} the tooltip
        cTooltip = 'Tooltip: set me!';
        
        % {logical 1x1} show the tooltip?
        lShowTooltip = true;
        
       
        hLabel
        hUI
    end
    
    
    events
      eChange  
    end
    
    
    methods
                       
       function this= PopupStruct(varargin)
       
            % Default ceOptions
       
            stOption1 = struct();
            stOption1.cLabel = 'Item 1';
            stOption1.dVal = 1;
            
            stOption2 = struct();
            stOption2.cLabel = 'Item 2';
            stOption2.dVal = 2;
            
            %{
            CANNOT assign as shown below due to a quirk in the way that
            the struct() constructor handles values that cell arrays 
            stParams = struct(...
                'ceOptions', ceOptions, ...
                'cLabel', 'This Popup' ...
            );
            %}
            
            this.ceOptions = {stOption1, stOption2};
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
                        
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight)
           
           
           if this.lShowLabel
               
               this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'HorizontalAlignment', 'left'...
                );
           
                dTop = dTop + 13;
           end
           
           
           this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', 'white', ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
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