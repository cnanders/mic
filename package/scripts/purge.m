% purge.m

% Purges the workspace of all variables, classes, timers, etc.

% close all executes the 'CloseRequestFunction' of every window that has a
% visible handle.

% This order is important because it deletes any open windows that have a
% visible handle, before deleting the reference to the objects that created
% the windows. If you call clear first, you delete reference to the object
% that created the open window but the open window stays open and now you
% have a window that points to nothing which crashes MATLAB when you try to
% interact with the window.

% Whenever you run clear on a class instance, it calls the destructor (if
% defined) BUT only when there are no outstanding references to the object
% (like open windows, etc).  To define a destructor, define a delete()
% method in the class

% Loop through workspace variables and call delete on each one that is an
% object.

% You may be tempted to make a class or a method of Utils that executes
% this code but it will not work.  The problem is that "who" only has
% access to the variables within scope of where it is called from.  If it
% is called from within a class method, it only has access to the class
% variables.

fprintf('\n*** purge.m listing workspace variables: *** \n');
ceVars = who
fprintf('*** purge.m end workspace variables *** \n\n');
for n = 1:length(ceVars)
    if isobject(eval(ceVars{n}))
        if ishandle(eval(ceVars{n}))
            if isvalid(eval(ceVars{n}))
                fprintf( ...
                    'purge.m OBJECT + HANDLE + VALID %s:%s \n', ...
                    ceVars{n}, ...
                    class(eval(ceVars{n})) ...
                );
                delete(eval(ceVars{n}));
            else 
               fprintf('purge.m OBJECT + HANDLE + INVALID %s\n', ceVars{n}); 
            end
        else
            fprintf( ...
                'purge.m OBJECT + NON-HANDLE %s:%s\n', ...
                ceVars{n}, ...
                class(eval(ceVars{n})) ...
            );
            delete(eval(ceVars{n}));
            % eval(ceVars{n}).delete();
        end
            
    else
        fprintf('purge.m NON-OBJECT: %s.\n', ceVars{n});
    end
end


clear variables
close all
