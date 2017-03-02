classdef List < mic.Base
    
    
    properties (Constant)
       
    end
    
      
    properties
        ceOptions               % cell of options
        u8Selected              % uint8 of selected options
        ceSelected              % cell of selected options
    end
    
    
    properties (Access = private)
        
        dLeft
        dTop
        dWidth
        dHeight

        hParent
        hLabel
        hUI
        hDelete
        hMoveUp
        hMoveDown
        hRefresh
        
        % {logical 1x1} show delete button
        lShowDelete = true 
        
        % {logical 1x1} show move buttons
        lShowMove = true   
        
        % {logical 1x1} show label
        lShowLabel = true   
        
        % {logical 1x1} show show refresh button.  If you show this, you
        % need to supply the function handle to use that returns a cell of
        % options
        lShowRefresh = true
        
        % {char 1xm} the label
        cLabel = 'Fix Me'        
        
        
        fhRefresh       % function handle
        
        dWidthDelete    = 20;
        dWidthUp        = 20;
        dWidthDn        = 20;
        dWidthRefresh   = 60;
        dPad            = 10;
        
    end
    
    
    events
        eChange
        eDelete
    end
    
    
    methods
        
       % constructor
       
       function this= List(varargin)
           
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
       end
       
       
       function build( ...
                this, ...
                hParent, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
            )
                       
           if this.lShowLabel
               
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
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
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'listbox', ...
                'String', this.ceOptions, ...
                'Min', 0, ...
                'Max', 2, ... % allows for multiple selection
                'Callback', @this.cb ...
           );
            
           dRight = dLeft + dWidth;
           
           if this.lShowDelete
              
               this.hDelete = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([ ...
                    dRight - this.dWidthDelete ...
                    dTop + dHeight + 5 ...
                    this.dWidthDelete ...
                    20], hParent),...
                'HorizontalAlignment', 'Center',...
                'Style', 'pushbutton', ...
                'String', 'X',...
                'Callback', @this.cb ...
                );
            
                dRight = dRight - this.dWidthDelete - this.dPad;
               
           end
           
           
           if this.lShowMove
               
                this.hMoveUp = uicontrol(...
                    'Parent', hParent,...
                    'Position', mic.Utils.lt2lb([ ...
                        dRight - this.dWidthUp ...
                        dTop + dHeight + 5 ...
                        this.dWidthUp ...
                        20], hParent),...
                    'HorizontalAlignment', 'Center',...
                    'Style', 'pushbutton', ...
                    'String', 'Up',...
                    'Callback', @this.cb ...
                );
            
               dRight = dRight - this.dWidthUp - this.dPad;
            
               this.hMoveDown = uicontrol(...
                    'Parent', hParent,...
                    'Position', mic.Utils.lt2lb([ ...
                        dRight - this.dWidthDn ...
                        dTop + dHeight + 5 ...
                        20 ...
                        20], hParent),...
                    'HorizontalAlignment', 'Center',...
                    'Style', 'pushbutton', ...
                    'String', 'Dn',...
                    'Callback', @this.cb ...
               );
            
               dRight = dRight - this.dWidthDn - this.dPad;

           end
           
           
           if this.lShowRefresh
               
              this.hRefresh = uicontrol( ...
                'Parent', hParent, ...
                'Position', mic.Utils.lt2lb([ ...
                    dRight - this.dWidthRefresh ...
                    dTop + dHeight + 5 ...
                    this.dWidthRefresh ...
                    20], hParent),...
                'HorizontalAlignment', 'Center', ...
                'Style', 'pushbutton', ...
                'String', 'Refresh', ...
                'Callback', @this.cb ...
                ); 
               
           end

       end
       
       
       function cb(this, src, evt)
           
            switch src
                case this.hUI
                    this.u8Selected = uint8(get(src, 'Value'));
                case this.hDelete
                    this.removeSelected();
                case this.hMoveUp
                    this.moveUp();
                case this.hMoveDown
                    this.moveDown();
                case this.hRefresh
                    this.refresh();
            end

       end
       
       
       function refresh(this)
           this.msg('refresh');
           this.ceOptions = this.fhRefresh();
       end
       
       function setRefreshFcn(this, fh)
           this.fhRefresh = fh;
       end
       
       
       % modifiers
       
       function set.ceOptions(this, ceVal)
          
           % prop
           if iscell(ceVal) % empty cell [1x0] is aloud
                this.ceOptions = ceVal;
                
                if isempty(this.ceOptions)
                    % no options in list ...
                    
                    this.u8Selected = uint8([]); % uint8 [0x0] empty array is aloud
                else
                    % options...
                    
                    if ~isempty(this.u8Selected)
                        
                        % Check max(u8Selected) to make sure there are all
                        % selected indicies are valid and modify u8Selected
                        % if needed to make it comply (this happens when
                        % you update to a list cell with less items than the
                        % previous one and a selected item on the previous
                        % cell would extend past thi new option cell
                    
                        if max(this.u8Selected) > length(this.ceOptions)
                            this.u8Selected = uint8(length(this.ceOptions));
                        else
                            % Make sure to re-set u8Selected so the setter
                            % is called which updates this.ceSelected.  If
                            % you don't call the setter (or manualy update
                            % ceSelected, it won't be updated)
                            
                            this.u8Selected = this.u8Selected; 
                            
                        end
                    else
                        
                        % default to first item 
                        this.u8Selected = uint8(1); 
                    end
                end
                
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
                set(this.hUI, 'Value', this.u8Selected);
                set(this.hUI, 'String', this.ceOptions);               
           end
           
           
           % notify(this,'eChange');
           
       end
       
       function set.u8Selected(this, u8Val)
           
           % prop
           if isinteger(u8Val) % uint8 [0x0] empty array is aloud
               
               if isempty(u8Val)
                   this.u8Selected = [];
               elseif(max(u8Val) <= length(this.ceOptions))
                   this.u8Selected = u8Val; 
               end
               
               % this.ceSelected = this.ceOptions(1,this.u8Selected); % will be cell [1x0] when u8Selected = uint8 [0x0]
               this.ceSelected = this.ceOptions(this.u8Selected);
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'Value', this.u8Selected);
           end
           
           notify(this,'eChange');
               
       end
       
       
       function prepend(this, cVal)
           % add item to beginning of ceOptions
           if ischar(cVal)
               this.ceOptions = {cVal this.ceOptions{:}};
           end
           
       end
       
       function append(this, cVal)
           % adds item to end of ceOptions
           if ischar(cVal)
               this.ceOptions{end+1} = cVal;
               this.u8Selected = uint8(length(this.ceOptions));
           end
           
           
       end
       
       function removeSelected(this)
           
           % removes selected options ceOptions
           
           % 2014.05.08 CNA
           % Dispatching an eDelete event and passing data that is a cell
           % of the selected options that are being removed.  In order to
           % pass custom data through Matlab events and listeners, you have
           % to build a custom class that extends event.EventData and add
           % whatever properties you want.  See classes/EventWithData for
           % more information
           
           
           stData = struct();
           stData.ceOptions = this.ceOptions(this.u8Selected);
           notify(this, 'eDelete', mic.EventWithData(stData));
           
           this.ceOptions(this.u8Selected) = [];
       end
       
       function insertBefore(this, cVal)
           % should only work when one option is selected. Inserts before
           % selected item
       end
       
       function insertAfter(this, cVal)
           % should only work when one option is selected. Inserts after
           % selected item
       end
       
       function moveUp(this)
           % moves selected options up the list
           
           if min(this.u8Selected) ~= 1
               % loop through each selected item and swap it with the one
               % above it
               for n=1:length(this.u8Selected)
                   this.ceOptions([this.u8Selected(n) this.u8Selected(n)-1]) = this.ceOptions([this.u8Selected(n)-1 this.u8Selected(n)]);
               end
               
               this.u8Selected = this.u8Selected - 1;
               
           end
           
       end
       
       function moveDown(this)
           % moves selected options down the list
           
           if max(this.u8Selected) ~= length(this.ceOptions)
               % loop through each selected item and swap it with the one
               % above it
               for n=1:length(this.u8Selected)
                   this.ceOptions([this.u8Selected(n) this.u8Selected(n)+1]) = this.ceOptions([this.u8Selected(n)+1 this.u8Selected(n)]);
               end
               
               this.u8Selected = this.u8Selected + 1;
               
           end
       end
       
       
       
             
    end
end