classdef Checkbox < mic.Base
    
%     properties (Constant)
%         dHeight = 15;
%     end
    
    properties
        lChecked = false
        cLabel = 'Fix Me'
        lShowLabel = true
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
       function this = Checkbox(varargin)
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
           
           this.hUI = uicontrol( ...
                ...
                'Parent',           hParent, ...
                'BackgroundColor',  'white', ...
                'Position',         mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
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