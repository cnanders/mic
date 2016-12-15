classdef AxisWithSave < Axis
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
    end
    
    properties
        
        % in addition to Axis
        
        ceSavedRaw      = {10};
        ceSavedName     = {'Test'};
        uipSaved
        
        uibSave
        uibDelete
        
    end
    
    events
        
    end
    
    methods
        
        function this = AxisWithSave(cName, cl, cDispName)
            
            % call constructor of superclass
            this = this@Axis(cName, cl, cDispName);
        end
        
        % overload init
        
        function init(this)
        
            
            % call superclass init
            init@Axis(this);
            
            this.msg('init');
            
            this.uipSaved = UIPopup( ...
                this.ceSavedName, ...
                '', ...
                false ...
                );
            
            this.uibSave = UIButton( ...
                'Save', ...
                true, ...
                imread(sprintf('%s../assets/axis-save.png', this.cDir)) ...
                );
            
            this.uibDelete = UIButton( ...
                'Delete', ...
                true, ...
                imread(sprintf('%s../assets/axis-delete.png', this.cDir)) ...
                );
            
            addlistener(this.uibSave, 'eChange', @this.handleSave);
            addlistener(this.uibDelete, 'eChange', @this.handleDelete);
            addlistener(this.uipSaved, 'eChange', @this.handleSaved);
            
            
        end
        
        % overload build
        
        function build(this, hParent, dLeft, dTop)
            
            % call superclass build
            % build@Axis(this, hParent, dLeft, dTop);
            
            % don't call superclass build since we need to make room for
            % the save buttons
            
            dWidth = 400;
            
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'Position', MicUtils.lt2lb([dLeft dTop dWidth 36], hParent) ...
                );
			drawnow;
             
            dLeft = dWidth - 12;
            this.uitActive.build(hPanel, dWidth-12, 0, 12, 36);
            
            dLeft = dLeft - 36;
            this.uitCal.build(hPanel, dLeft, 0, 36, 12);
            this.uibSetup.build(hPanel, dLeft, 12, 36, 12);
            this.uibIndex.build(hPanel, dLeft, 24, 36, 12);
            
            
            dLeft = dLeft - 80 - 36;
            this.uipSaved.build(hPanel, dLeft, 12, 80 + 36, 12);
            this.uibSave.build(hPanel, dLeft, 0, 36, 12);
            this.uibDelete.build(hPanel, dLeft + 80, 0, 36, 12);
                        
            dLeft = dLeft - 36;
            this.uitPlay.build(hPanel, dLeft, 0, 36, 36);
            
            dLeft = dLeft - 18;
            this.uibStepPos.build(hPanel, dLeft, 0, 18, 18);
            this.uibStepNeg.build(hPanel, dLeft, 18, 18, 18);
            
            dLeft = dLeft - 75;
            this.uieDest.build(hPanel, dLeft, 0, 75, 36);
            
            dLeft = dLeft - 75;
            this.uitxPos.build(hPanel, dLeft, 12, 75, 12);
            
            this.uitxLabel.build(hPanel, 0, 12, dLeft, 12);
            
            
        end
        
        function handleSave(this, src, evt)
                        
            
            cSaveName = MicUtils.listSaveAs('', this.ceSavedName);
            if ~strcmp(cSaveName, '')
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
    
    methods (Access = private)
        
        function append(this, cVal)
            
            this.ceSavedName{end+1} = cVal;
            this.ceSavedRaw{end+1} = this.destRaw();
            this.uipSaved.setOptions(this.ceSavedName);
            this.uipSaved.u8Selected = uint8(length(this.uipSaved.ceOptions));
            
        end
       
        function remove(this)
            
            if  this.uipSaved.u8Selected > 0
                this.ceSavedName(this.uipSaved.u8Selected) = [];
                this.ceSavedRaw(this.uipSaved.u8Selected) = [];
                this.uipSaved.setOptions(this.ceSavedName);
            end
            
        end
        
        
    end
    
end