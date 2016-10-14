classdef TestUIPopupStruct < HandlePlus
        
    properties (Constant)
        
        dWidth = 400
        dHeight = 100;
               
    end
    
	properties
        
        uip
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestUIPopupStruct()
             
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
            
            
            
            this.uip = UIPopupStruct(...
                'ceOptions', ceOptions, ...
                'cLabel', 'This Popup' ...
            );
            
            addlistener(this.uip, 'eChange', @this.onChange);

            
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
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end