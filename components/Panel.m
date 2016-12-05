classdef Panel < handle
    
    % abbr = pan    
   	
    properties
                
        cName;
        dLeft;
        dTop;
        
        ceList;             % values (cell)
        u16List;             % selected index (integer)
        cList;              % selected value (char)
        
        cePopup;            % values of popup
        u8PopupSelected;    % force uint8
        cPopupSelected;
        
        lToggle;
        
        ceHairColorOptions
        u8HairColorSelected
        cHairColorSelected
        
        ceHairStyleOptions
        u8HairStyleSelected
        ceHairStyleSelected
        lbHairStyle
        
        
    end
    
    properties (Constant)
        
        
    end
    
    
    properties (Constant, Access = private)
               
        dHeight = 300;
        dWidth = 300;
        dButtonWidth = 100;
        dButtonHeight = 30;
        dUIPad = 20;
        
       
        
    end
    
    
    
    properties (Access = private)
                
        % handles
        
        hParent
        hPanel
        hButton
        hList
        hToggle
        hCheckbox
        hButtonGroup
        ppHairColor
        

    end
    
    events
        eSomethingClick;
    end
    
    
    
   
    methods (Static)
        
        
    end
    
    methods
        
        function this = Panel(...
                cName, ...
                dLeft, ...
                dTop, ...
                hParent ...
                )

            
            this.cName = cName;
            this.dLeft = dLeft;
            this.dTop = dTop;
            this.hParent = hParent;
            this.build();
            
             
        end
        
        
        function build(this)
            
            dXOffset = 10;
            
            
            this.hPanel = uipanel(...
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', this.cName,...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([this.dLeft this.dTop this.dWidth this.dHeight], this.hParent));
			drawnow;
            
            dTop = 20;
            
            this.hButton = uicontrol(...
                'Parent', this.hPanel,...
                'Position', MicUtils.lt2lb([dXOffset dTop this.dButtonWidth this.dButtonHeight], this.hPanel),...
                'HorizontalAlignment', 'Center',...
                'Style', 'pushbutton', ...
                'String', 'ui pushbutton',...
                'Callback', @this.cb ...
                );


            dTop = dTop + this.dButtonHeight + this.dUIPad;

           	this.hList = uicontrol( ...
                'Parent', this.hPanel, ...
                'Position', MicUtils.lt2lb([dXOffset dTop this.dButtonWidth 100], this.hPanel),...
                'Style', 'listbox', ...
                'BackgroundColor', 'white', ...
                'String', {'item 1', 'item 2', 'item 3'},...
                'Callback', @this.cb ...
                );
            
            dTop = dTop + 100 + this.dUIPad;
            
            this.hToggle = uicontrol( ...
                'Parent', this.hPanel, ...
                'Position', MicUtils.lt2lb([dXOffset dTop this.dButtonWidth this.dButtonHeight], this.hPanel),...
                'Style', 'toggle', ...
                'String', 'ui toggle',...
                'Callback', @this.cb ...
                );
            
            dTop = dTop + this.dButtonHeight + this.dUIPad;
            
            this.ppHairColor = Popup(...
                'hair-color', ...
                {'blonde', 'brown', 'red'}, ...
                dXOffset, ...
                dTop, ...
                this.dButtonWidth, ...
                this.hPanel ...
            );
        
            addlistener(this.ppHairColor, 'eChange', @this.cb);
            
           dTop = dTop + this.dButtonHeight + this.dUIPad;

            this.uilHairStyle = UIList(...
                'hair-style', ...
                {'flat top', 'perm', 'buzz'}, ...
                dXOffset, ...
                dTop, ...
                this.dButtonWidth, ...
                100, ...
                this.hPanel, ...
                
            );
            
            
                
            dTop = 20;
            dXOffset = 130;
            
            this.hCheckbox = uicontrol( ...
                'Parent', this.hPanel, ...
                'Position', MicUtils.lt2lb([dXOffset dTop this.dButtonWidth this.dButtonHeight], this.hPanel),...
                'Style', 'checkbox', ...
                'String', 'Check me',...
                'Callback', @this.cb ...
                );
            
            dTop = dTop + this.dButtonHeight + this.dUIPad;
            
            this.hButtonGroup = uibuttongroup( ...
                'Parent', this.hPanel, ...
                'Title', 'Button Group', ...
                'Visible', 'on', ...
                'Units', 'pixels', ...  %have to specify or it will not draw
                'Position', MicUtils.lt2lb([dXOffset dTop this.dButtonWidth 4*this.dButtonHeight], this.hPanel),...
                'SelectionChangeFcn', @this.cb ...
                );
            
            u0 = uicontrol(...
                'Style', 'radiobutton', ...
                'String', 'Option 1', ...
                'pos', MicUtils.lt2lb([10 20 100 30], this.hButtonGroup), ...
                'parent', this.hButtonGroup, ...
                'HandleVisibility','off' ...
                );
            u1 = uicontrol( ...
                'Style', 'radiobutton', ...
                'String', 'Option 2', ...
                'pos', MicUtils.lt2lb([10 50 100 30], this.hButtonGroup), ...
                'parent', this.hButtonGroup,  ...
                'HandleVisibility','off' ...
                );
            u2 = uicontrol( ...
                'Style', 'radiobutton', ...
                'String', 'Option 3', ...
                'pos', MicUtils.lt2lb([10 80 100 30], this.hButtonGroup), ...
                'parent', this.hButtonGroup,  ...
                'HandleVisibility', 'off' ...
                );

        end
        
        
        function cb(this,src,evt)
            
            switch src
                case this.hButton
                    disp('Panel.cb() pushbutton');
                case this.hList
                    disp('Panel.cb() list');
                case this.hToggle
                    disp('Panel.cb() toggle');
              
                case this.hCheckbox
                    disp('Panel.cb() checkbox');
                case this.hButtonGroup
                    disp('Panel.cb() buttongroup');
                case this.ppHairColor
                    disp('Panel.cb() ppHairColor');
               
            end
            
            
        end
        
        
        
        % Modifiers 
        
        % listbox, popupmenu  
        function set.ceList(this, ceVal)
            
            if iscell(ceVal)
                
                % force selected index <= length (ceVal)
                if(~isempty(this.u16List) && ...
                    length(ceVal) > this.u16List)
                    this.u16List = length(ceVal);
                end
                
                set(this.hList, 'String', this.ceVal);
            end
            
            this.ceList = get(this.hList, 'String');
            this.cList = this.ceList{this.u16List};
            
        end
        
        function set.u16List(this, u16Val)
            if isinteger(u16Val)                
                set(this.hList, 'Value', u16Val);
            end
%             this.u16List = get(this.hList, 'Value');
%             this.cList = this.ceList{this.u16List};
        end
        
%         % Setters
% 
%         function set.ceHairColorOptions(this, ceVal)
%             this.ppHairColor.setOptions(ceVal);
%         end 
%         
%         function set.u8HairColorSelected(this, u8Val)
%            this.ppHairColor.u8Selected = u8Val; 
%         end
%         
%         
%         
%         
%         
%         function set.ceHairStyleOptions(this, ceVal)
%             this.lbHairStyle.setOptions(ceVal);
%         end 
%         
%         function set.u8HairStyleSelected(this, u8Val)
%            this.lbHairStyle.u8Selected = u8Val; 
%         end
%             
%         
%         % getters
%         function val = get.ceHairColorOptions(this)
%             val = this.ppHairColor.ceOptions;
%         end
%         
%         function val = get.cHairColorSelected(this)
%             val = this.ppHairColor.cSelected;
%         end
%             
%         function val = get.u8HairColorSelected(this)
%             val = this.ppHairColor.u8Selected;
%         end
%         
%         
%         function val = get.ceHairStyleOptions(this)
%             val = this.lbHairStyle.ceOptions;
%         end
%         
%         function val = get.ceHairStyleSelected(this)
%             val = this.lbHairStyle.ceSelected;
%         end
%             
%         function val = get.u8HairStyleSelected(this)
%             val = this.lbHairStyle.u8Selected;
%         end
            
            
        % toggles
%         function set.lToggle(this,lVal)
%             if islogical(lVal)            
%                 this.
%                 set(this.hToggle, 'Value', lVal);
%             end
%         end

    end
    
end
    