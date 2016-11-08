classdef TestKeithley6517A < HandlePlus
    %TESTKEITHLEY6517A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        clock
        keithley6517a
    end
    
    properties (Access = private)
        
        config
        h
        
    end
    
    methods
        
        function this = TestKeithley6517A()
        
            this.clock = Clock('master');
            this.keithley6517a = Keithley6517A(...
                'clock', this.clock ...
            );
        
            % Set the API
            this.keithley6517a.setApi(APIVKeithley6517A);
            
        end
        
        function build(this)
            
            this.h = figure;
            this.keithley6517a.build(this.h, 10, 10);
            
        end
        
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.keithley6517a);
            delete(this.clock);
        end
    
    end
    
end



