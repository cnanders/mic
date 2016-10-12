classdef Mirror < HandlePlus
% MIRROR Class that allow the control of M mirrors
%   mirror = Mirror();
%
% See also PUPILFILL, HEIGHTSENSOR


    properties (SetAccess = private)

    end

    properties (Access = private)

    end

    events
    end

    properties
        axisUIX     % Axis X UI controls
        axisUIY     % Axis Y UI controls
        axisUIZ     % Axis Z UI controls
        axisUIPitch % Pitch UI controls
        axisUIYaw   % Yaw UI controls

        cl          % Clock

        hUI         % handle to the UI panel element
        hParent     % handle to the parent figure
    end


    events

    end

%%
    methods
        
        function this = Mirror(cl)
        %MIRROR Class constructor
        %   mirror = Mirror(clock)
        
            this.cl = cl;
            %this.msg('Mirror.constructor()');
            this.init();
        end


        function init(this)
        %INIT Initializes the Mirror
        %   Mirror.init()
        
            this.axisUIX  = Axis('X', this.cl);
            this.axisUIY  = Axis('Y', this.cl);
            this.axisUIZ  = Axis('Z', this.cl);
            this.axisUIPitch  = Axis('Pitch', this.cl);
            this.axisUIYaw    = Axis('Yaw', this.cl);
            %TODO : link the API the proper way
        end

        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI Element related to the Mirror class
        %   Mirror.build(hParent, dLeft, dTop)
        
            this.hParent = hParent;
            this.hUI = uipanel( 'Parent', this.hParent,...
                                'Units', 'pixels',...
                                'Title', 'Mirror Controls',...
                                'FontWeight', 'Bold',...
                                'Clipping', 'on',...
                                'Position', Utils.lt2lb([dLeft dTop Axis.dWidth dTop+5*Axis.dHeight], this.hParent));
            drawnow;

            if (~isempty(this.axisUIX) && ~isempty(this.axisUIY) && ~isempty(this.axisUIZ))
                this.axisUIX.build(       this.hUI,0, dTop+0*Axis.dHeight)
                this.axisUIY.build(       this.hUI,0, dTop+1*Axis.dHeight)
                this.axisUIZ.build(       this.hUI,0, dTop+2*Axis.dHeight)
                this.axisUIPitch.build(   this.hUI,0, dTop+3*Axis.dHeight)
                this.axisUIYaw.build(     this.hUI,0, dTop+4*Axis.dHeight)
            end 
        end

        function delete(this)
        %DELETE Class destructor
            if ~isempty(this.axisUIX)
                delete(this.axisUIX)
            end
            if ~isempty(this.axisUIY)
                delete(this.axisUIY)
            end
            if ~isempty(this.axisUIZ)
                delete(this.axisUIZ)
            end
            if ~isempty(this.axisUIPitch)
                delete(this.axisUIPitch)
            end
            if ~isempty(this.axisUIYaw)
                delete(this.axisUIYaw)
            end
        end

    end

end