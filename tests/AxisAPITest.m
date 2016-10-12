classdef AxisAPITest < HandlePlus
    %AXISAPITEST Summary of this class goes here
    %   Detailed explanation goes here
    
%% properties    
properties
    nAxis;
    stage;
end

%% methods
methods
    
function this = AxisAPITest(stage, nAxis)
    this.stage = stage;
    this.nAxis = nAxis;
end

function lReturn = isStopped(this)
    lReturn = true;
end

function dReturn = getPosition(this)
    dReturn = this.stage.positionRAW(this.nAxis);
end


function i8Return = moveAbsolute(this, dDest)
    this.stage.moveRAW(this.nAxis, dDest)

    i8Return = int8(0);
end 

function i8Return = stopMove(this)
	%this.stage.motorStop()
    i8Return = true;
end

end
    
end

