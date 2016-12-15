% UICheckbox class
% Wraps the uicontrol checkbox

classdef UICheckbox < HandlePlus
    
%     properties (Constant)
%         dHeight = 15;
%     end
    
    properties
        lChecked
        cLabel
        lShowLabel
    end
    
    
    properties (Access = private)
        hLabel
        hUI
    end
    
    
    events
      eChange  
    end
    
    
    methods
        
       % Constructor
       function this = UICheckbox( ...
                lChecked, ...
                cLabel ...
                )
            
            if nargin < 2
                error('UICheckbox: Checkbox instantied with insufficient arguments');
            end
            
            this.lChecked   = lChecked;
            this.cLabel     = cLabel;
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
           
           this.hUI = uicontrol( ...
                ...
                'Parent',           hParent, ...
                'BackgroundColor',  'white', ...
                'Position',         MicUtils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style',            'checkbox', ...
                'Callback',         @this.cb, ...
                'Value',            this.lChecked, ...
                'String',           this.cLabel ...
            );
        
       end
       

       % Callback
       function cb(this, src, evt)
           
           this.lChecked = logical(get(src, 'Value'));
           
       end
       
       
       % Modifiers
       function set.lChecked(this, lChecked)
           
           % Rules
           if islogical(lChecked)
               this.lChecked = lChecked;
           elseif any(lChecked == [0, 1])
               this.lChecked = logical(lChecked);
           end
           
           % ui
           if ~isempty(this.hUI)
               set(this.hUI, 'Value', this.lChecked);
           end
           
           notify(this,'eChange');
               
       end
       
       % Save/Load
       function saveInstance(this)
           
       end
       
       function loadInstance(this)
           
       end
               
    end
end