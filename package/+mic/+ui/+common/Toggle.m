classdef Toggle < mic.Base        
      
    properties
        
        lVal = false                    % state (on/off)
        lInit = false
    
    end
    
    
    % @param {char} cTextOff - the text to show when the toggle is off
       
       
    properties (Access = private)
        
        hUI
       
            
        % @param {u8 m x n} u8ImgOn - the image to show when toggle is on
        u8ImgOn = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-true.png'))
        
        % @param {u8 m x n} u8ImgOff - the image to show when toggle is off
        u8ImgOff = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-false-yellow.png'))
        
        % @param {char} cTextOn - the text to show when the toggle is on
        cTextOn = 'On'
        
        % @param {char} cTextOn - the text to show when the toggle is off
        cTextOff = 'Off'                   
        
        % @param {logical} [lImg = false] - use img instead of text
        lImg = false
        

       % @param {struct} [stF2TOptions] - configuration for what dialog to
       %    show when switching from false to true.  Defaults to not
       %    showing a dialog
       % @param {struct} [stT2FOptions] - configuration for what dialog to
       %    show when swithing from true to false.  Defaults to now showing
       %    a dialog
        
        stF2TOptions = struct( ...
            'lAsk', false, ...
            'cTitle',  'Switch?', ...
            'cQuestion',  'Are you sure you want to switch?', ...
            'cAnswer1', 'Yes', ...
            'cAnswer2',  'Cancel' ...
        );
          
        stT2FOptions = struct( ...
            'lAsk', false, ...
            'cTitle',  'Switch?', ...
            'cQuestion',  'Are you sure you want to switch?', ...
            'cAnswer1', 'Yes', ...
            'cAnswer2',  'Cancel' ...
        );               
                                    

        cTooltip = 'Tooltip: set me!';
    end
    
    events
        eChange  
    end
    
    
    methods
        
       % cTextOnstructor
       %{
                cTextOff, ...
               cTextOn, ...
               lImg, ...            % optional
               u8ImgOff, ...        % optional
               u8ImgOn, ...         % optional
               stF2TOptions, ...
               stT2FOptions ...     % optional
       %}
       
       function this = Toggle(varargin) 
                   
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
                                  
            this.hUI = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent),...
                'Style', 'togglebutton',...
                'TooltipString', this.cTooltip, ...
                'Callback', @this.cb ...
                );
            
            % update toggle string/cdata
            this.lVal = this.lVal;

       end
       
       
       function cb(this, src, evt)
           if isequal(src,this.hUI)
               
               if ~this.lVal && this.stF2TOptions.lAsk
                   
                   % ask before switching from false to true
                   
                   % when the toggle was clicked, the 'Value' property
                   % of the uicontrol changed so the textbox either
                   % became light or dark (opposite of what it was
                   % before click).  The cdata/string properties of
                   % the uicontrol don't change on click.  Here I will
                   % reset the uicontrol so it looks like it did
                   % before click (using the setter to update the
                   % uicontrol)
                   
                   this.lVal = this.lVal;
                   
                   cAns = questdlg( ...
                       this.stF2TOptions.cQuestion, ...
                       this.stF2TOptions.cTitle, ...
                       this.stF2TOptions.cAnswer1, ...
                       this.stF2TOptions.cAnswer2, ...
                       this.stF2TOptions.cDefault ...
                   );
               
                   switch cAns
                       case this.stF2TOptions.cDefault
                           % Default is to not switch
                           return
                       otherwise
                           % switch
                           this.lVal = ~this.lVal;
                   end
                   
               elseif this.lVal && this.stT2FOptions.lAsk
                   
                   % ask before switching from true to false (see comments
                   % above for more info)
                   
                   this.lVal = this.lVal;
                   
                   cAns = questdlg( ...
                       this.stT2FOptions.cQuestion, ...
                       this.stT2FOptions.cTitle, ...
                       this.stT2FOptions.cAnswer1, ...
                       this.stT2FOptions.cAnswer2, ...
                       this.stT2FOptions.cDefault ...
                   );
               
                   switch cAns
                       case this.stT2FOptions.cDefault
                           % Default is to not switch
                           return
                       otherwise
                           % switch
                           this.lVal = ~this.lVal;
                   end
                   
               else
                   % update
                   this.lVal = logical(get(src, 'Value'));
               end
           end
           
%AW2013-7-18 changed switch to if statement to ensure compatibility
%            switch src
%                case this.hUI
%                    if this.lAsk
%                        % ask
%                        
%                        % when the toggle was clicked, the 'Value' property
%                        % of the uicontrol changed so the textbox either
%                        % became light or dark (opposite of what it was
%                        % before click).  The cdata/string properties of
%                        % the uicontrol don't change on click.  Here I will
%                        % reset the uicontrol so it looks like it did
%                        % before click
%                        
%                        this.lVal = this.lVal;
%                        
%                        cAns = questdlg(this.cAskMsg, 'Warning', 'Yes', 'Cancel', 'Cancel');
%                        switch cAns
%                            case 'Yes'
%                                % switch
%                                this.lVal = ~this.lVal;
%                            otherwise
%                                return
%                        end
%                    else
%                        % update
%                        this.lVal = logical(get(src, 'Value'));
%                    end
%            end
       end
       
       
       function setValWithoutNotification(this, lVal)
           
            if this.lVal == lVal
                % Don't need to do anything
                return;
            end
            
            this.lVal = lVal;

            % Update UI
            
            if ~isempty(this.hUI) && ishandle(this.hUI)

               % cdata / string
               if this.lImg
                   % cdata
                   if this.lVal
                       % on
                       set(this.hUI, 'CData', this.u8ImgOn);
                   else
                       % off
                       set(this.hUI, 'CData', this.u8ImgOff);
                   end
               else
                   % string
                   if this.lVal
                        % on
                        set(this.hUI, 'String', this.cTextOn);
                   else
                       % off
                       set(this.hUI, 'String', this.cTextOff);
                   end
               end

               % value
               set(this.hUI, 'Value', this.lVal);
            end
           
           
       end
       
       
       
       function set.lVal(this, l)
           
           

           this.msg('set.lVal', 6);
            % 2014.11.19 CNA
            % If you want to mute the broadcast (notification) when
            % manually setting the value of the toggle, set lInit property
            % to false (it will think it is uninitialized) before setting
            % lVal
           
          
           if islogical(l)
               
               % If l (logical) is different than this.lVal, we need to 
               % dispatch a message.  Figure out if we should do this or not
               % When we have lAsk == true or lTrueAsk == true this check
               % is important because we don't want to broadcast eChange
               % unless the user confirms the change through the question
               % dialog
               
               lNotify = this.lVal ~= l;
                               
               % Update lVal
               this.lVal = l;
               
               % ui
               if ~isempty(this.hUI) & ishandle(this.hUI)
                  
                   % cdata / string
                   if this.lImg
                       % cdata
                       if this.lVal
                           % on
                           set(this.hUI, 'CData', this.u8ImgOn);
                       else
                           % off
                           set(this.hUI, 'CData', this.u8ImgOff);
                       end
                   else
                       % string
                       if this.lVal
                            % on
                            set(this.hUI, 'String', this.cTextOn);
                       else
                           % off
                           set(this.hUI, 'String', this.cTextOff);
                       end
                   end
                   
                   % value
                   set(this.hUI, 'Value', this.lVal);
               end
               
               % Nofity if there was a change in lVal
               
               % Don't want to blast eChange on first set so use lInit
               % property to keep track.  Also, if we are initialized, only
               % notify if the logical() passed in here was different than
               % this.lVal (see logic for lNotify above)
                
               if this.lInit
                   if lNotify
                        notify(this, 'eChange');
                        this.msg('set.lVal notify eChange', 6);
                   end
               else
                    this.lInit = true;
               end               

           else
               this.msg('Toggle.lVal input not type == logical', 2);
           end
       end
       
        function show(this)
    
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end
            

        end
        
        function setTextOff(this, cText)
           
            this.cTextOff = cText;
            this.lVal = this.lVal; % redraw
            
        end
        
        function setTextOn(this, cText)
           
            this.cTextOn = cText;
            this.lVal = this.lVal; % redraw
            
        end
        
         function setTooltip(this, cText)
        %SETTOOLTIP
        %   @param {char 1xm} cText - the text of the tooltip
        
            this.cTooltip = cText;
            if ishandle(this.hUI)        
                set(this.hUI, 'TooltipString', this.cTooltip);
            end
            
         end
        
         function enable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'on');
            end
        end
        
        function disable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'off');
            end
            
        end
       
         
    end
end