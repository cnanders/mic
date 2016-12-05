classdef ConfigHardwareIOText < HandlePlus
        
    properties (Constant)
               
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        dDelay   % @prop {double} dDelay - the delay in seconds for UI updates
        ceStores % @prop {cell of struct 1xm} ceStores - list of stored raw positions
                 % @prop {char 1xm} ceStores[].name - the name of the
                 % stored position
                 % @prop {char 1xm} ceStores[].val - the raw value of the
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
        
        
        function this = ConfigHardwareIOText(cPath)
        %CONFIG Loads a JSON configuration file
        %   @param {char} [cPath = this.cPathJsonDefault] - path to a JSON
        %       configuration file
                    
             % Default arguments
            
            if nargin == 0
                
                cFileFull = mfilename('fullpath');
                [cFilePath, ~, ~] = fileparts(cFileFull);

                this.cPathJsonDefault = fullfile(...
                    MicUtils.pathConfig(), ...
                    'hiotx', ...
                    'default.json' ...
                );
                cPath = this.cPathJsonDefault;
                
                %{
                this.msg(...
                    sprintf('setting default arg: %s', cPath), ...
                    3 ...
                );
                %}
                   
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
            
            % delay is requires
            this.dDelay = this.stJson.delay;
            
            % [stores] optional
            if isfield(this.stJson, 'stores')
                this.ceStores = this.stJson.stores;
            else
                this.ceStores = {}; % 0x0 cell
            end    
        end
        
        
        
        
    end
    
    methods (Access = protected)
        function lOut = validateJson(this)
        %VALIDATE Validate a configuration structure.  These are JSON
        %files that are loaded and parsed with parse_json function to
        %become a struct
        
        
            fields = {'delay'};
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
            
%             % Check each structure in the units cell array
%             
%             fields = {'name', 'val'};
%             for n = 1:length(this.stJson.stores)
%                 for m = 1:length(fields)
%                     if ~isfield(this.stJson.stores{n}, fields{m})
%                         msg = sprintf(...
%                             'Invalid config file. Stores definition %1.0f must contain property "%s"', ...
%                             n, ...
%                             fields{m} ...
%                         );
%                         this.msg(msg, 2);                
%                         lOut = false;
%                         return;
%                     end
%                 end
%             end
            
            lOut = true;
        end      
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end