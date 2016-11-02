classdef HandlePlus < handle
%HANDLEPLUS is an overloaded handle class that implements useful functions
%   Among these functions are the ability to recursively save and load
%   an instance of a child class.

    % 2014.05.08 CNA
    % I thought it would be a good idea to make cName a protected property,
    % but I realized most of the classes don't have a cName property. It is
    % realy only HardwareIO, HardwareO classes that need them.  We will
    % make them public properties to the msg() method can access them
    
    %{
    properties (Access = protected)
        cName   = 'Unnamed';
    end
    %}
    
    
    
    properties (Access = protected)
        u8verbosity = 5;
    end
    
    
    methods

        function assignPropsFromStruct(this, struct)
            this.loadClassInstance(struct);
        end
        
        
        function loadClassInstance(this, sSaveStruct)
        % Loads a saved instance of a class
        %  handlePlus.loadClassInstance(sSaveStruct)
        %      Recursively loads the values of sSaveStruct into the properties of
        %      oClassInstance.  If sSaveStruct contains a field that is not a property,
        %      it is skipped.
        %
        % See also SAVECLASSINSTANCE
                        
            % Get field names of sSaveStruct:
            ceFields = fields(sSaveStruct);
            
            % Get properties of oClassInstance:
            ceProperties = properties(this);
            
            % Loop through properties:
            for k = 1:length(ceFields)
                
                % If this field isn't a property, skip it
                if ~(ismember(ceFields{k}, ceProperties))
                    continue
                end
                
                % If this field represents a structure, recursively load children
                % CNA 2016 FIXME.  This is a problem when a public property
                % of a class is a structure
                
                if isstruct(sSaveStruct.(ceFields{k}))
                    this.msg(sprintf('loadClassInstance() recursive on %s', ceFields{k}), 9);
                    
                     this.(ceFields{k}).loadClassInstance(sSaveStruct.(ceFields{k}));
                else
                    
                    % Otherwise, add this field value to the class
                    % instance:
                    
                    % ceFields{k}
                    % sSaveStruct.(ceFields{k})
                    
                    % 2014.05.13 CNA
                    % Making it so we don't try to set properties with
                    % SetAccess = private
                    
                    mp = findprop(this, ceFields{k});  % returns instance of meta.property
                
                    if(~isempty(mp))

                        % It is a property of oThis.

                        if(~mp.Constant && ...
                           ~strcmp(mp.SetAccess,'private'))

                            % It is NOT a Constant (static) property
                            % It is also not (access = private) 
                            % in this case, we can set it
                    
                            this.msg(sprintf('loadClassInstance() setting %s', ceFields{k}), 9);
                            % sSaveStruct.(ceFields{k})
                            this.(ceFields{k}) = sSaveStruct.(ceFields{k});
                        end
                    end
                   
                end
            end
        end
            

        function sSaveStruct = saveClassInstance(this)
        % Saves the current state of a class instance
        %  sSaveStruct = handlePlus.saveClassInstance()
        %      recursively saves the properties of THIS into 
        %      sSaveStruct, a nested structure whose data tree mirrors
        %      the structure of THIS.
        %
        % See also LOADCLASSINSTANCE
            
            sSaveStruct = struct;
            % Get properties:
            ceProperties = properties(this);
            
            % Loop through properties:
            for k = 1:length(ceProperties)
                
                % If this property is an object, recursively save children
                if isobject(this.(ceProperties{k}))  %  && ... ishandle(this.(ceProperties{k})
               
                    cMsg = sprintf(...
                        'saveClassStructure() property %s IS object, recursively calling', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    sSaveStruct.(ceProperties{k}) = this.(ceProperties{k}).saveClassInstance();
                    
                    % Otherwise, add this property to the save structure
                else
                    cMsg = sprintf(...
                        'saveClassStructure() setting property %s', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    
                    % Check if property is constant:
                    mpProp = findprop(this, ceProperties{k});
                    if ~mpProp.Constant
                        sSaveStruct.(ceProperties{k}) = this.(ceProperties{k});
                    end
                end
            end
            
        end        
        
        function cID = id(this)
        %ID Gives the Class of which this object is an instance
        %   cID = handlePlus.id()
            if isprop(this, 'cName')
                cID =  sprintf('%s-%s', class(this), this.cName);
            elseif isprop(this, 'cLabel')
                cID =  sprintf('%s-%s', class(this), this.cLabel);
            else
                cID = class(this);
            end
        end
        
        function log(this, string, file, verbosity)
            
        end
        
        
        
        
        
        
    end %methods
    
    % 2013-11-20 AW added method overloads to remove 'handle' class
    % for the listed methods of the class.
    % This is better for cod pretty-print and autocompletion
    % http://stackoverflow.com/questions/6621850/is-it-possible-to-hide-the-methods-inherited-from-the-handle-class-in-matlab
    methods(Hidden)
        
        function deleteTimer(this, t)
        %DELETETIMER Deletes a timer in an appropriate manner
        %   handlePlus.deleteTimer(t)
        %       where t is a timer object
        %       deletes timer objects in a way that doesn't make Matlab 
        %       freak the fuck out or issue warnings / errors
            
            % timer
            if isvalid(t)
                if strcmp(t.Running, 'on')
                    stop(t);
                end
                % set(this.t, 'TimerFcn', '');
                delete(t);
            end
        end
        
        function msg(this, cMsg, u8verbosity_level)
        % Outputs a message in the command window
        %   handlePlus.msg('Hello World')
        %     similar to disp() except that channeling every fprintf or
        %     disp through this method lets us easily eliminate all print
        %     or only show certain ones.  I've found it really helpful in
        %     other projects to do something like this.  Especially
        %     event-based projects.  Also, if you make the message prefixed
        %     with the class name, you can put logic in here to only echo
        
        % 0 : always shows
        % 1 : show by default
        % 2 : show errors
        % 3 : something is sent
        % 4 : something is received
        % 5 : something is activated/deactivated
        % 6 : event addition or clock
        % 7 : something loaded/saved (parameters)
        % 8 : something is instantiated/deleted
        % 9 : show everything
            
            % April 2016 (AW) addition of verbosity parameteres
            
            cTimestamp = datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local');
            
            try
                if nargin<3
                    u8verbosity_level = 0;
                end
                if u8verbosity_level<=this.u8verbosity
                    fprintf('%s: %s %s\n', cTimestamp, this.id(), cMsg);
                end
                
            catch
                fprintf('%s: %s %s\n', cTimestamp, this.id(), cMsg);
            end
        end
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%HANDLE CLASS METHODS THAT SHOULD BE HIDDEN TO MAKE
        %%AUTO-COMPLETION EASIER
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %{
        function lh = addlistener(varargin)
            lh = addlistener@handle(varargin{:});
        end
        function notify(varargin)
            notify@handle(varargin{:});
        end
        function delete(varargin)
            delete@handle(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@handle(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@handle(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
        %}
        
        
        function checkDir(this, cPath)
        %CHECKDIR Check that the dir at cPath exists. Make if needed

            
        
            if (~exist(cPath, 'dir'))
                mkdir(cPath);
            end
            
        end
        
        
        
        
    end
    
end %classdef
        
        
