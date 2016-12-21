classdef UIImageLogical < HandlePlus


    properties

        cData = ''  %this is what the textbox contains. feel free to access it directly...
        

        % val is not a property because it can be several different types.
        % We use val() and setVal() methods that force the correct type
    end


    properties (Access = private)
        
        hAxes
        hImage
        
        cTooltip = 'Tooltip: set me!';
        dWidth = 24
        dHeight = 24
        u8ImgTrue
        u8ImgFalse
        cDirThis
        
    end


    %%
    methods
        
        function this= UIImageLogical(varargin)

            % Defaults
            this.u8ImgTrue = imread(fullfile(MicUtils.pathAssets(), 'image-logical-true-1.png'));
            this.u8ImgFalse = imread(fullfile(MicUtils.pathAssets(), 'image-logical-false-1.png'));
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
        end

        function build(this, hParent, dLeft, dTop)

            dPosition = MicUtils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent);
            this.hAxes = axes( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Position', dPosition,...
                'Color', [0 0 0], ...
                'Color', [0 0 0], ...
                'HandleVisibility', 'on', ...
                'Visible', 'off', ... % 'LineWidth', 0, ...
                'DataAspectRatio' , [1 1 1] ...
            );
            drawnow;
        
%             this.hImage = image(...
%                 'CData', this.u8ImgFalse, ...
%                 'Parent', this.hAxes ...
%             );

            this.hImage = image(this.u8ImgFalse);
            set(this.hImage, 'Parent', this.hAxes);
            % set(this.hAxes, 'XTick', []); % gets rid of axes and gridlines
            % set(this.hAxes, 'YTick', []); % gets rid of axes and gridlines
            % set(this.hAxes, 'box', 'off');
            set(this.hAxes, 'Visible', 'off');
           
        end
        
        % @param {logical 1x1} the state
        function setVal(this, l)
            
            if ~ishandle(this.hImage)
                return
            end
            
            if l
                set(this.hImage, 'CData', this.u8ImgTrue);
            else
                set(this.hImage, 'CData', this.u8ImgFalse);
            end
        end
        
        function enable(this)
            
        end
        
        function disable(this)
           
            
        end


    end
end