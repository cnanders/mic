classdef ApiInterfaceAxis < HandlePlus

    methods (Abstract)
        
        
        % Create the serial port object associated with the COM serial
        %  port the device is attached to and configure baud rate and
        %  terminator. Will set property "s" of the Api class
        init(this)
        
        % Connect the serial port to the instrument (fopen)
        connect(this)
        
        % Disconnect the serial port from the instrument (fclose)
        disconnect(this)
        
        
               
    end
    
end
        
