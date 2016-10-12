classdef TestClass < HandlePlus


%% Properties
properties
cName
end

properties (Constant)

end

events
end


methods
%% Constructor
function this = TestClass(cName)
    this.cName = cName;
end

end

end