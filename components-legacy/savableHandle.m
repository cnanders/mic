classdef savableHandle < handle
    
    
    %% Savable handles implement save and load methods defined below:
    methods
        
        
        % Recursively loads the values of sSaveStruct into the properties of
        % oClassInstance.  If sSaveStruct contains a field that is not a property,
        % it is skipped.
        function loadClassInstance(this, sSaveStruct)
            
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
                if isstruct(sSaveStruct.(ceFields{k}))
                     this.(ceFields{k}).loadClassInstance(sSaveStruct.(ceFields{k}));
                else
                    
                    % Otherwise, add this field value to the class
                    % instance:
                    this.(ceFields{k}) = sSaveStruct.(ceFields{k});
                end
                
            end
        end
            
        % Recursively saves the properties of THIS into sSaveStruct, a
        % nested structure whose data tree mirrors the structure of THIS.
        function sSaveStruct = saveClassInstance(this)
            
            sSaveStruct = struct;
            
            % Get properties:
            ceProperties = properties(this);
            
            % Loop through properties:
            for k = 1:length(ceProperties)
                
                % If this property is an object, recursively save children
                if isobject(this.(ceProperties{k}))
                    sSaveStruct.(ceProperties{k}) = this.(ceProperties{k}).saveClassInstance();
                    
                    % Otherwise, add this property to the save structure
                else
                    sSaveStruct.(ceProperties{k}) = this.(ceProperties{k});
                end
                
            end
        end
        
        % End methods
        
    end
    
end
        
        
