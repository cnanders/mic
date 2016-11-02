classdef TestUIPopupStruct < HandlePlus
        
    properties (Constant)
        
        dWidth = 400
        dHeight = 100;
               
    end
    
	properties
        
        uip
        
        
    end
    
    properties (SetAccess = private)
        cName = 'TestUIPopopStuct';
    end
    
    properties (Access = private)
        
        hFigure
        clock
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestUIPopupStruct()
             
            num = 100;
            ceOptions = cell(1, num);
            this.clock = Clock('master');
            for n = 1:num
                
               stOption = struct( ...
                    'cLabel', sprintf('Val %1.0f', n), ...
                    'cVal', n ...
               );
               ceOptions{n} = stOption;
  
            end
            
            %{
            ceOptions = {
                struct( ...
                    'cLabel', 'Blah 1', ...
                    'cVal', 1 ...
                ), ...
                struct( ...
                    'cLabel', 'Blah 2', ...
                    'dVal', 2 ...
                ) ...
            };
            %}
            
            
            
            this.uip = UIPopupStruct(...
                'ceOptions', ceOptions, ...
                'cLabel', 'This Popup' ...
            );
            
            addlistener(this.uip, 'eChange', @this.onChange);
            
            this.clock.add(@this.onClock, this.id(), 0.5);

            
        end
        
        function onClock(this, src, evt)
            this.uip.u8Selected = uint8(6);
        end
        function onChange(this, src, evt)
            
            this.uip.val()
            
        end
        
        function build(this)
            
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            else 
                this.hFigure = figure();
            end
            
            this.uip.build(this.hFigure, 10, 10, 300, 30);
        end
        
        function delete(this)
            this.msg('delete', 5);
            this.clock.remove(this.id());
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end