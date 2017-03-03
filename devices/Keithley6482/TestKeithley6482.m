classdef TestKeithley6482 < HandlePlus
    %TESTKEITHLEY6517A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        clock
        keithley6482
    end
    
    properties (Access = private)
        
        config
        h
        
    end
    
    methods
        
        function this = TestKeithley6482()
        
            this.clock = Clock('master');
            this.keithley6482 = Keithley6482(...
                'clock', this.clock, ...
                'lShowSettings', true, ...
                'lShowRange', true ...
            );
        
            % Set the Api
            this.keithley6482.setApi(ApivKeithley6482);
            %{
            this.keithley6482.setApi(ApiKeithley6482(...
                'cPort', 'COM2' ...
            ));
            %}
            
        end
        
        function build(this)
            
            this.h = figure;
            this.keithley6482.build(this.h, 0, 0);
            
        end
        
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.keithley6482);
            delete(this.clock);
        end
    
    end
    
end



