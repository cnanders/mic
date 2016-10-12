classdef AxisAPIGeneric < HandlePlus
%AXISAPIGENERIC Class that provides a generic API for a stage
%   The stage may comprise various axis, and must have at least these four
%   methods implemented :
%   -out = stage.positionRAW(nAxis)
%   -stage.moveRAW(nAxis,in)
%   -stage.abort()
%   -isStopped = stage.isStopped()
%
%   It was mainly implemented to provide compatibility between ais 
%   experiment and met5gui framework
%    examples of (ais) classes that are compatible with this API :
%    -Flexure
%    -Tripod
%    -Mirrorcle
%    -GalilXZ
%    -GalilVT50
%
%   See also AXIS, SETUPHARDWAREIO, FLEXURE, TRIPOD, MIRRORCLE, GALILXZ, GALILVT50
    
    properties
        nAxis   % stage axis number 
        stage   % stage class instance
    end

    %% methods
    methods

        function this = AxisAPIGeneric(stage, nAxis)
        %AXISAPIGENERIC Class constructor
        %   api = AxisAPIGeneric(stage, nAxis)
            this.stage = stage;
            this.nAxis = nAxis;
        end



        function dReturn = getPosition(this)
        %GETPOSITION Returns the absolute position in raw units of the axis
        %    dReturn = AxisAPIGeneric.getPosition()
        %
        % See also MOVEABSOLUTE, ISSTOPPED, STOPMOVE
        
            dReturn = this.stage.positionRAW(this.nAxis);
        end


        function i8Return = moveAbsolute(this, dDest)
        %MOVEABSOLUTE Moves the axis to an absolute position defined in raw
        %   i8Return = AxisAPIGeneric.moveAbsolute(dDest)
        %
        % See also STOPMOVE, ISSTOPPED, GETPOSITION
        
            this.stage.moveRAW(this.nAxis, dDest)

            i8Return = int8(0);
        end 
        
        function lReturn = isStopped(this)
        %ISSTOPPED Returns whether the stage is stopped, and ready for acq
        %   isStopped = AxisAPIGENERIC.isStopped()
        %
        % See also STOPMOVE
        
            try 
                lReturn = this.stage.isStopped();
            catch err
                this.msg('AxisAPIGeneric.isStopped error')
                lReturn = true;
            end
        end

        function i8Return = stopMove(this)
        %STOPMOVE Aborts the current stage motion    
        %   this.stage.motorStop()
        %
        % See also MOVEABSOLUTE, ISSTOPPED
            try
                this.stage.abortAll();
                i8Return = true;
            catch err
                i8Return = false;
            end
        end

    end
    
end

