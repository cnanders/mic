classdef HardwareIOWithSave < HardwareIO
    
    
    
    properties (Constant)
       
        cSaveDir = 'save/hio'
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
    end
    
    properties
        
        % in addition to HardwareIO
        
        ceSavedRaw      = {10};
        ceSavedName     = {'Test'};
        uipSaved
        
        uibSave
        uibDelete
        
    end
    
    events
        
    end
    
    methods
        
        function this = HardwareIOWithSave(cName, cl, cDispName)
            
            if ~exist('cDispName', 'var')
                cDispName = cName; % ms
            end
            
            % call constructor of base class calls init().  We will
            % overload the init() method.  **Important** The access of
            % overloaded methods needs to be same in the base class and the
            % extended class and cannot be private (for example, they can
            % both be protected or public)
            
            this = this@HardwareIO(cName, cl, cDispName);
            
           
        end
        
                
        % overload build 
        % ** must have same access here and in base class **
        
        function build(this, hParent, dLeft, dTop)
            
            % call superclass build
            build@HardwareIO(this, hParent, dLeft, dTop);
            
            % Update width
            dWidth = 410;
            set(this.hPanel, 'Position', Utils.lt2lb([dLeft dTop dWidth 36], hParent));
                        
            dLeft = 290;
            this.uipSaved.build(this.hPanel, ...
                dLeft,  ...
                12, ...
                80 + 36, ... 
                12);
            this.uibSave.build(this.hPanel, ...
                dLeft, ...
                0, ...
                36, ...
                12);
            this.uibDelete.build(this.hPanel, ...
                dLeft + 80, ...
                0, ...
                36, ...
                12);
                                    
        end
        
       
         
    end
    
    
    methods (Access = protected)
       
        % overload init()
        % ** must have same access here and in base class **
        
        function init(this)
        
            % call superclass init
            init@HardwareIO(this);
                        
            this.uipSaved = UIPopup( ...
                this.ceSavedName, ...
                '', ...
                false ...
                );
            
            this.uibSave = UIButton( ...
                'Save', ...
                true, ...
                imread(fullfile(Utils.pathAssets(), 'axis-save.png')) ...
                );
            
            this.uibDelete = UIButton( ...
                'Delete', ...
                true, ...
                imread(fullfile(Utils.pathAssets(), 'axis-delete.png')) ...
                );
                        
            addlistener(this.uibSave, 'eChange', @this.handleSave);
            addlistener(this.uibDelete, 'eChange', @this.handleDelete);
            addlistener(this.uipSaved, 'eChange', @this.handleSaved);
            
            this.load();
            
            
        end
        
    end
    
    methods (Access = private)
        
        function append(this, cVal)
            
            this.ceSavedName{end+1} = cVal;
            this.ceSavedRaw{end+1} = this.dValRaw;
            this.uipSaved.setOptions(this.ceSavedName);
            this.uipSaved.u8Selected = uint8(length(this.uipSaved.ceOptions));
            this.save();
            
        end
       
        function remove(this)
            
            if  this.uipSaved.u8Selected > 0
                this.ceSavedName(this.uipSaved.u8Selected) = [];
                this.ceSavedRaw(this.uipSaved.u8Selected) = [];
                this.uipSaved.setOptions(this.ceSavedName);
                this.save();
            end
            
        end
        
        
        function save(this)
            
           % Only want to save ceSavedName and ceSavedRaw
            
           s = struct();
           s.ceSavedName    = this.ceSavedName;
           s.ceSavedRaw     = this.ceSavedRaw;
           
           
           save(this.saveName(), 's'); 
            
        end
        
       
        
        function load(this)
            
            % Look up saved file
            
            cFile = this.saveName();

            if exist(cFile, 'file') ~= 0

                load(cFile); % populates s in local workspace
                this.loadClassInstance(s);
                
                % Update the pulldown
                this.uipSaved.setOptions(this.ceSavedName);

            end
            
        end
      
        
        function cReturn = saveName(this)
           
            cDir = fullfile(pwd, this.cSaveDir);
            this.checkDir(cDir);
            
            cReturn = fullfile(cDir, [this.cName, '.mat']);
            
        end
        
        function handleSave(this, src, evt)
                        
            
            cSaveName = Utils.listSaveAs('', this.ceSavedName);
            if ~strcmp(cSaveName, '')
                
                % If cSaveName is already in ceSavedName, need to purge
                % this item from ceSavedName and cSavedRaw
                
                u8Index = strmatch(cSaveName, this.ceSavedName, 'exact');
                if (~isempty(u8Index))
                    this.ceSavedName(u8Index) = [];
                    this.ceSavedRaw(u8Index) = [];
                end
                
                this.append(cSaveName);
            end
            
        end
        
        function handleDelete(this, src, ~)
                        
            cQuestion   = 'Are you sure you want to remove this saved position?';
            cTitle      = 'Warning';
            cAnswer1    = 'Yes';
            cAnswer2    = 'Cancel';
            cDefault    = cAnswer2;
            
            cAns = questdlg( ...
                cQuestion, ...
                cTitle, ...
                cAnswer1, ...
                cAnswer2, ...
                cDefault ...
                 );

            switch cAns
                case cAnswer1
                    this.remove();
                otherwise

            end 
            
        end
        
        function handleSaved(this, src, ~)
            
            if this.uipSaved.u8Selected > 0
                this.setDestRaw(this.ceSavedRaw{this.uipSaved.u8Selected});
            end
        end
        
            
        
        
    end
    
end