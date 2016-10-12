classdef Config < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        dDelay   % @prop {double} dDelay - the delay in seconds for UI updates
        ceUnits  % @prop {cell of struct 1xm} ceUnits - list of unit definitions
                 % @prop {char} ceUnits[].name - the name of the unit
                 % @prop {double} ceUnits[].slope - the slope (cal = slope * (raw - offset))
                 % @prop {double} ceUnits[].offset - the offset
                 % @prop {double} ceUnits[].precision - the display precision
        ceStores % @prop {cell of struct 1xm} ceStores - list of stored raw positions
                 % @prop {char 1xm} ceStores[].name - the name of the
                 % stored position
                 % @prop {double 1x1} ceStores[].raw - the raw value of the
                 % stored position
    end
    
    properties (Access = private)
       cDir           % 
       cPathJson          % @prop {char} - path to a JSON configuration file
       cPathJsonDefault   % @prop {char} - path to a JSON configuration file 
                            %   (this is used if cPathConfig is not
                            %   provided)
       stJson   % @prop {struct} stJson - struct representation of JSON (returned by parse_json) 
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Config(cPath)
        %CONFIG Loads a JSON configuration file
        %   @param {char} [cPath = this.cPathJsonDefault] - path to a JSON
        %       configuration file
                    
             % Default arguments
            
            if nargin == 0
                
                cFileFull = mfilename('fullpath');
                [cFilePath, ~, ~] = fileparts(cFileFull);

                this.cPathJsonDefault = fullfile(...
                    cFilePath, ...
                    '..', ...
                    'config', ...
                    'default.json' ...
                );
                cPath = this.cPathJsonDefault;
                this.msg(...
                    sprintf('setting default arg: %s', cPath), ...
                    3 ...
                );
                   
            end
            
            this.cPathJson = cPath;
            
            if (exist(this.cPathJson, 'file') ~= 2) 
                
%                 this.msg(...
%                     sprintf('The config file: %s does not exist', this.cPathJson), ...
%                     3 ...
%                 );
                exception = MException(...
                    'Config:cPathJson', ...
                    sprintf('The config file: %s does not exist', this.cPathJson) ...
                );
                throw(exception);
                return;
            else 
               this.msg(...
                    sprintf('loading config file: %s', cPath), ...
                    3 ...
               );     
            end
            
            
            this.stJson = parse_json(fileread(this.cPathJson));
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
        %UNITDEFINITION Retrieve a unit definition structure (slope, offset, precision)
        %   by the name of the unit
        %   @param {char} cName - the name of the unit (must be supported
        %       in config)
        %   @return {struct} - the unit definition structure.  
        %   
        
        
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