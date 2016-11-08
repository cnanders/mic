% close all, then clear

% close all initializes the 'CloseRequestFunction' of every window that has
% a visible handle.

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

close all 

% loop through workspace variables and call delete on each one
% that is an object

ceVars = who;
for(n = 1:length(ceVars))
   if isobject(eval(ceVars{n}))
       delete(eval(ceVars{n}));
   end
end


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);
            

% if ~isempty(timerfind)
%     stop(timerfind);
%     delete(timerfind); % delete existing timers
% end

addpath(pwd);
addpath(fullfile(pwd,'classes'));

h = figure;

uip = UIEdit( ...
    'Saved pos', ...
    'd');

uip.build(h, 10, 10, 100, 30);


