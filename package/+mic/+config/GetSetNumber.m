classdef GetSetNumber < mic.Base
        
    properties (Constant)
               
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        
         
         % {double 1x1} dDelay - the delay in seconds for UI updates
         dDelay
         
         % {cell of struct 1xm} ceUnits - list of unit definitions
         % {char} ceUnits[].name - the name of the unit
         % {double} ceUnits[].slope - the slope (cal = slope * (raw - offset))
         % {double} ceUnits[].offset - the offset
         % {double} ceUnits[].precision - the display precision
         ceUnits
         
         % {cell of struct 1xm} ceStores - list of stored raw positions
         % {char 1xm} ceStores[].name - the name of the stored position
         % {double 1x1} ceStores[].raw - the raw value of the stored position
         ceStores 
         
         % {double 1x1} dStep - step size in raw units
         dStep
         % {double 1x1} dMin - min value in raw units
         dMin
         % {double 1x1} dMax - max value in raw units
         dMax
    end
    
    properties (Access = private)
       
        % @prop {char 1xm} - path to a JSON configuration file
        cPath = fullfile(...
            mic.Utils.pathConfig(), ...
            'get-set-number', ...
            'config-default-stores.json' ...
        ); 
        stJson   % @prop {struct} stJson - struct representation of JSON (returned by parse_json) 
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = GetSetNumber(varargin)
        
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if (exist(this.cPath, 'file') ~= 2) 
                
%                 this.msg(...
%                     sprintf('The config file: %s does not exist', this.cPath), ...
%                     3 ...
%                 );
                exception = MException(...
                    'Config:cPath', ...
                    sprintf('The config file: %s does not exist', this.cPath) ...
                );
                throw(exception);
               
            else 
               this.msg(...
                    sprintf('loading config file: %s', this.cPath), ...
                    3 ...
               );     
            end
            
            this.stJson = parse_json(fileread(this.cPath));
            this.stJson = this.stJson{1}; % has to do with parse_json

              
            if ~this.validateJson()
                return;
            end
            
            this.dDelay = this.stJson.delay;
            this.ceUnits = this.stJson.units;
            
            if isfield(this.stJson, 'stores')
                this.ceStores = this.stJson.stores;
            else
                this.ceStores = {}; % 0x0 cell
            end
            
            if isfield(this.stJson, 'step')
                this.dStep = this.stJson.step;
            else
                this.dStep = 0.1;
            end
            
            if isfield(this.stJson, 'min')
                this.dMin = this.stJson.min;
            else
                this.dMin = -realmax('double');
            end
            
            if isfield(this.stJson, 'max')
                this.dMax= this.stJson.max;
            else
                this.dMax = realmax('double');
            end
            
            if ischar(this.dMin)
                this.dMin = eval(this.dMin);
            end
            if ischar(this.dMax)
                this.dMax = eval(this.dMax);
            end
                        
            % If slope, offset, precision are a string, run eval on them.
            % This allows using mathematical expressions for these values
            % in the JSON
            
            for n = 1:length(this.ceUnits)
                
                if ischar(this.ceUnits{n}.slope)
                    this.ceUnits{n}.slope = eval(this.ceUnits{n}.slope);
                end

                if ischar(this.ceUnits{n}.offset)
                   this.ceUnits{n}.offset = eval(this.ceUnits{n}.offset); 
                end

                if ischar(this.ceUnits{n}.precision)
                    this.ceUnits{n}.precision = eval(this.ceUnits{n}.precision);
                end
            end
            
        end
        
        
        function stOut = unit(this, cName)
        %UNITDEFINITION Retrieve a unit definition structure (name, slope, offset, precision)
        %   by the name of the unit
        % @param {char} cName - the name of the unit (must be supported
        %       in config)
        % @return {struct 1x1} st - the unit definition structure. 
        % @return {char 1xm} st.name
        % @return {double 1x1} st.slope
        % @return {double 1x1} st.offset
        % @return {double 1x1} st.precision
        
        
            % The units property of this.stConfig contains a cell array of
            % structures.  Each struct defines a unit with three
            % properties: (label, scale, offset).  This method returns the
            % unit struct whose label property == cName.
        
            % Loop through list of unit structure definitions and check
            % the label property of each one for equality with cUnit.
            
            for n = 1:length(this.ceUnits)
                if (strcmp(this.ceUnits{n}.name, cName)) 
                    stOut = this.ceUnits{n};
                    return;
                end
            end

            
            msgID = 'UNIT:NotSupported';
            msg = sprintf('The unit ?%s? is not supported', cName);
            exception = MException(msgID,msg);
            throw(exception);
            
        end
        
    end
    
    methods (Access = protected)
        function lOut = validateJson(this)
        %VALIDATE Validate a configuration structure.  These are JSON
        %files that are loaded and parsed with parse_json function to
        %become a struct
        
        
            fields = {'delay', 'units'};
            for n = 1:length(fields)
                
                if ~isfield(this.stJson, fields{n})
                    msg = sprintf(...
                        'Invalid config file. Must contain property "%s"', ...
                        fields{n} ...
                    );
                    this.msg(msg, 2);
                    lOut = false;
                    return;
                end
            end
            
            % Check each structure in the units cell array
            
            fields = {'name', 'slope', 'offset', 'precision'};
            for n = 1:length(this.stJson.units)
                for m = 1:length(fields)
                    if ~isfield(this.stJson.units{n}, fields{m})
                        msg = sprintf(...
                            'Invalid config file. Unit definition %1.0f must contain property "%s"', ...
                            n, ...
                            fields{m} ...
                        );
                        this.msg(msg, 2);                
                        lOut = false;
                        return;
                    end
                end
            end
            
            lOut = true;
        end      
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end