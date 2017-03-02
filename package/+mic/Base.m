classdef Base < handle
%Base is an overloaded handle class that implements useful functions
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

        %{
        
        % Override properties with varargin
        % @param {cell 1xm} the result of varargin

        function setVarargin(this, ce)
            for k = 1 : 2: length(ce)
                % this.msg(sprintf('passed in %s', ce{k}));
                if this.hasProp( ce{k})
                    this.msg(sprintf('settting %s', ce{k}), 3);
                    this.(ce{k}) = ce{k + 1};
                end
            end  
        end
        
        %}
        
        function assignPropsFromStruct(this, struct)
            this.loadClassInstance(struct);
        end
        
        
        function loadClassInstance(this, sSaveStruct)
        % Loads a saved instance of a class
        %  Base.loadClassInstance(sSaveStruct)
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
                
                if isempty(sSaveStruct.(ceFields{k}))
                    cMsg = sprintf(...
                        'loadClassInstance() skipping %s.  It is [] ', ...
                        ceFields{k}...
                    );
                    this.msg(cMsg);
                    continue
                end
                
                % If this field represents a structure, recursively load children
                % CNA 2016 FIXME.  This is a problem when a public property
                % of a class is a structure.  Yes it is.  Need to check 
                
                % If the field is a structure, it could reference a Class
                % instance that extends Base.  If it does, want to 
                % recursively call.  But we need to be sure.  
                % 1) Is the field is a structure
                % 2) If (1), is the this.field an object?
                % 3) If (2), does this.field have a 'loadClassInstance'
                % method?
                
                
                
                if isstruct(sSaveStruct.(ceFields{k})) && ...
                   isobject(this.(ceFields{k})) && ...
                   any(strcmp('loadClassInstance', methods(this.(ceFields{k}))))
                    
                    cMsg = sprintf(...
                        'loadClassInstance() recursive on %s.  Field references < Base ', ...
                        ceFields{k}...
                    );
                    this.msg(cMsg);
                    
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
                    
                            cMsg = sprintf(...
                                'loadClassInstance() setting %s', ...
                                ceFields{k}...
                            );
                            this.msg(cMsg);
                            % sSaveStruct.(ceFields{k})
                            this.(ceFields{k}) = sSaveStruct.(ceFields{k});
                        end
                    end
                   
                end
            end
        end
            

        function sSaveStruct = saveClassInstance(this)
        % Saves the current state of a class instance
        %  sSaveStruct = Base.saveClassInstance()
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
                
                % 2017.01.17 CNA
                % Making it so we don't try to save properties with
                % SetAccess = private. This code looks for the property
                % on "this", which is the class calling the
                % saveClassInstance() method.  If it can't find the
                % property, it means it isn't public.

                mp = findprop(this, ceProperties{k});  % returns instance of meta.property

                if isempty(mp)
                    cMsg = sprintf(...
                        'saveClassInstance() skipping %s. Cannot be found.', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    continue
                end
                
                if strcmp(mp.SetAccess, 'private')
                    % Not settable
                    cMsg = sprintf(...
                        'saveClassInstance() skipping %s. SetAccess is private.', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    continue;
                end
                
                if mp.Constant
                    cMsg = sprintf(...
                        'saveClassInstance() skipping %s. It is a Constant.', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    continue;
                end
                
               
                
                % If this property is an object, recursively save children
                if isobject(this.(ceProperties{k}))  %  && ... ishandle(this.(ceProperties{k})
               
                    cMsg = sprintf(...
                        'saveClassInstance() recursively calling on %s. Is object', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    sSaveStruct.(ceProperties{k}) = this.(ceProperties{k}).saveClassInstance();
                    
                    % Otherwise, add this property to the save structure
                else
                    cMsg = sprintf(...
                        'saveClassInstance() saving %s', ...
                        ceProperties{k} ...
                    );
                    this.msg(cMsg);
                    
                    % Check if property is constant:
                    % mpProp = findprop(this, ceProperties{k});
                    % if ~mpProp.Constant
                        sSaveStruct.(ceProperties{k}) = this.(ceProperties{k});
                    % end
                end
            end
            
        end        
        
        function cID = id(this)
        %ID Gives the Class of which this object is an instance
        %   cID = Base.id()
            if this.hasProp( 'cName')
                cID =  sprintf('%s-%s', class(this), this.cName);
            % elseif this.hasProp( 'cLabel')
                % cID =  sprintf('%s-%s', class(this), this.cLabel);
            else
                cID = class(this);
            end
        end
        
        function log(this, string, file, verbosity)
            
        end
        
        %%
        % @param {char 1xm} c - name of property
        % @return {logical 1x1} - true if class has property
        
        function l = hasProp(this, c)
            l = false;
            if length(findprop(this, c)) > 0
                l = true;
            end
        end
        
        
        
        
        
        
    end %methods
    
    % 2013-11-20 AW added method overloads to remove 'handle' class
    % for the listed methods of the class.
    % This is better for cod pretty-print and autocompletion
    % http://stackoverflow.com/questions/6621850/is-it-possible-to-hide-the-methods-inherited-from-the-handle-class-in-matlab
    methods(Hidden)
        
        function deleteTimer(this, t)
        %DELETETIMER Deletes a timer in an appropriate manner
        %   Base.deleteTimer(t)
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
        %   Base.msg('Hello World')
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

            
            
            if (exist(cPath, 'dir') ~= 7)
                cMsg = sprintf('checkDir() creating dir %s', cPath);
                this.msg(cMsg);
                mkdir(cPath);
            end
            
        end
        
        
        
        
    end
    
end %classdef
        
        
