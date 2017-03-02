classdef (ConstructOnLoad) EventWithData < event.EventData
   
    % Allows passing custom data through an event to a listener
    % http://www.mathworks.com/help/matlab/matlab_oop/learning-to-use-events-and-listeners.html#brzefhl-2
    % http://stackoverflow.com/questions/23230723/how-to-send-data-through-matlab-events-and-listeners
    
    % For example use see UIList and DemoPanel which listens for an event
    % from UIList that uses this class to send custom data
    
    properties
        stData          % structure
    end
    
    methods
        function this = EventWithData(stData)
            this.stData = stData;
        end
    end
end