classdef ApivHardwareO < InterfaceApiHardwareO

    % apivho

    properties (Access = protected)
        clock                      % Clock
        dPeriod
        dPos 
        
    end


    properties

        cName
        dMean  % Make public to allow them to be changed
        dSig   % Make public to allow them to be changed

    end

            
    methods
        
        function this = ApivHardwareO(stParams)
        % @param {struct 1x1} stParams - config information
        % @param {char 1xm} stParams.cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        % @param {clock 1x1} stParams.clock - the clock
        % @param {double 1x1} [stParams.dPeriod = 0.1] - clock task period
        % @param {double 1x1} [stParams.dMean = 0] - mean reported value
        % @param {double 1x1} [stParams.dSig = 0.1] - std. deviation of
        %   reported value

                        
            % Defaults
            stDefault = struct(); % No default 
            stDefault.dPeriod = 0.1;
            stDefault.dMean = 0;
            stDefault.dSig = 0.1;
            
            % Merge defaulte into params
            stParams = mergestruct(stDefault, stParams);
            
            % Assign params to properties
            ceNames = fieldnames(stParams);
            for k = 1:length(ceNames)
                this.(ceNames{k}) = stParams.(ceNames{k});
            end
            
            this.clock.add(@this.handleClock, this.id(), this.dPeriod);

        end

        function dReturn = get(this)
            dReturn = this.dPos;
        end

        function handleClock(this)

            this.dPos = this.dMean + this.dSig*randn(1);
        end
            
        function delete(this)

            this.msg('ApivHardwareO.delete()');

            % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end

        end

    end %methods
end %class
    

            
            
            
        