classdef JavaDevice < HandlePlus
    
    % Carl + Vamsi may implement a single "mega" .jar that I use to 
    % instantiate one Object whose member functions are called to
    % instantiate all other objects. The comparison of the "modular"
    % approach vs. the "mega" approach is shown below.
    %
    % Modular:
    % this.jDevice      = cxro.common.device.motion.MotionControlProxy('M141-Stage','iman.lbl.gov')
    %
    % Mega:
    % this.jMegaDevice  = cxro.common.device.MET5();
    % this.jDevice      = this.jMegaDevice.getMotionControl('M141-Stage');
    %
    % Properties used on instance object
    %       cConnectFcn
    %       cDisconnectFcn
    %
    % ##### MODULAR
    %
    % Properties needed to create the instance object:
    %       cJarPath
    %       cPackage
    %       cConstructFcn
    %        % 
    % ##### MEGA
    %
    % Properties needed to create the instance object:
    %       cConstructFcn2
    %
    % Use:
    %       cPrivateJarPath
    %       cPrivatePackage
    %       cPrivateConstructFcn
    %       cPrivateConnectFcn 
        
	properties
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        
              
        
        cPrivateJarPath        = 'MET5.jar';
        cPrivatePackage        = 'cxro.common.device.';
        cPrivateConstructFcn   = 'MET5()';
        cPrivateConnectFcn     = 'init()';
        
    end
    
    properties (Access = protected)
        
        
        
        lMega = false 
        jMegaDevice
        jDevice        
        
        uitConnect
        
        % Set these in constructor of child class
        cJarPath           
        cPackage            = 'cxro.common.device.motion'; 
        cConstructFcn       = 'MotionControlProxy(''M141-Stage'',''iman.lbl.gov'')'; % For string (char) args, use '' as an excaped quote
        cConstructFcn2      = 'getMotionControl(''M141-Stage'')'; % Use with mega 
        
        cConnectFcn         = 'init()';
        cDisconnectFcn      = 'unInit()';
                
                
    end
    
        
    events
        
        eConnect
        eDisconnect
        
    end
    

    
    methods
        
        function this = JavaDevice()
                
            % This constructor is called by default immediately in the in
            % the constructor of any class that extends this class (it is 
            % called before any code of the child constructor is executed
            
            %{
            msgbox( ...
                ['To connect to device over ICE, you need to turn off ' ...
                'WiFi and turn off VPN (for some reason, we cannot ' ...
                'reach  met-dev.dhcp.lbl.gov when VPN is on) and plug ' ...
                'an ethernet cable into the computer.'], ...
                'Mod3 ICE connection help', ...
                'warn' ...
            );
            %} 
            
            this.msg('JavaDevice constructor');

            
            % this.cJarDir              = pwd;
            % this.cJarPath             = sprintf('%s%snPointProxy.jar', pwd, filesep);
            % this.cPackage             = 'cxro.common.device';     % Set in 
            % this.cConstructFcn        = 'nPointProxy()';
            % this.cConnectFcn          = 'init()';
            % this.cDisconnectFcn       = 'unInit()';
                
            this.uitConnect = UIToggle('Connect', 'Disconnect');
            addlistener(this.uitConnect, 'eChange', @this.handleConnectToggle);            
            
        end
                
        function delete(this)
            
            if this.jDevice ~= []
                this.msg('delete()');
                lResult = eval(sprintf('this.jDevice.%s', this.cDisconnectFcn));
            end
            
        end
        
        % Programmatic press/unpress of the toggle This will trigger all of
        % the events that happen when the user clicks the connect button
        % manually
        
        function turnOn(this)
            
            if ~this.uitConnect.lVal
                this.uitConnect.lVal = true;
            end
                        
        end
        
        
        function turnOff(this)
        
            if this.uitConnect.lVal
                this.uitConnect.lVal = false;
            end
        end
        
        function lReturn = isActive(this)
            
            lReturn = this.uitConnect.lVal;
            
        end
        
        %{
        function methods(this)
            
           methods(sprintf('%s.%s', this.cPackage, this.cClass)); 
            
        end
        %}
        

    end
    
    methods (Access = protected)
                
        function lReturn = disconnect(this)
            
            if isequal(this.jDevice, [])
                lReturn = false;
                return;
            end
            
            
            cCode = sprintf('this.jDevice.%s', this.cDisconnectFcn); 

            try
                lReturn = eval(cCode);
            catch err
                eval(cCode);
                lReturn = true;
            end
                       
            
        end
                
        function lReturn = connect(this)
              
            
            if this.lMega
                
                % Mega.jar  Get instance object by calling a method on the
                % mega object
                
                % Make sure mega library is loaded
                if ~this.megaLibIsLoaded()
                    this.loadMegaLib();
                end
                
                % Make sure jMegaDevice exists
                if isequal(this.jMegaDevice, [])
                    
                    cCode = sprintf('%s.%s', this.cPrivatePackage, this.cPrivateConstructFcn);
                    this.jMegaDevice = eval(cCode);
                
                    % Call the connect function
                    cCode = sprintf('this.jMegaDevice.%s', this.cPrivateConnectFcn);

                    try
                        lReturn = eval(cCode);
                    catch err
                        eval(cCode);
                        this.msg(err);
                        lReturn = true;
                    end
                end
                
                % Instantiate jDevice by calling a public method of 
                % jMegaDevice if it doesn't already exist
                
                if isequal(this.jDevice, [])
                    cCode = sprintf('this.jMegaDevice.%s', this.cConstructFcn2);
                    this.jDevice = eval(cCode);
                end
                
                % this.jDevice.unInit();  % Make sure device not initialized to old instance
                % lReturn = this.jDevice.init();
                
                % Connect to the device
                cCode = sprintf('this.jDevice.%s', this.cConnectFcn);

                try
                    lReturn = eval(cCode);
                catch err
                    eval(cCode);
                    this.msg(err);
                    lReturn = true;
                end
                                                
            else

                % Modular .jar
                
                % Make sure modular library is loaded
                if ~this.libIsLoaded()
                    this.loadLib();
                end

                % Create the device if it doesn't exist
                if isequal(this.jDevice, [])

                    cCode = sprintf('%s.%s', this.cPackage, this.cConstructFcn);

                    % cCode = sprintf('%s.%s(%s)', this.cPackage, this.cClass, this.cConstructArgs)
                   
                    this.jDevice = eval(cCode);
                end

                % this.jDevice.unInit();  % Make sure device not initialized to old instance
                % lReturn = this.jDevice.init();
                
                % Connect
                cCode = sprintf('this.jDevice.%s', this.cConnectFcn);

                
                try
                    lReturn = eval(cCode);
                catch err
                    eval(cCode);
                    this.msg(getReport(err));
                    lReturn = true;
                end
                
            end
            
        end
        
        
        function loadLib(this)
        
            % javaclasspath
            
            % Temporarily set user.dir to this folder so nPoint.jar can
            % load libnPoint.dylib and other files
            
            [cPath, cName, cExt] = fileparts(this.cJarPath); 
            java.lang.System.setProperty('user.dir', cPath);

            % Add files to Java class path

            javaaddpath(this.cJarPath);
            
            % By using the import command, we can simplify java class
            % names.  Instead of a = cxro.serm.wago.Test(), you can do a =
            % Test();
            
            % When you do the import, you can create devices without the
            % full package name, for example you can do:
            % 
            % import cxro.common.device.*
            % jDevice = nPointProxy();
            %
            % or if you don't import the package, you have to spell out the
            % entire path:
            % 
            % jDevice = cxro.common.device.nPointProxy();
            %
            % I prefer the latter approach
            %
            % methods('cxro.common.device.nPointProxy')
            
        end
        
        
        
                  
        
        function lOut = libIsLoaded(this)
           
            % DPE == Dynamic Path Entries
            
            ceDPE = javaclasspath;
            for k = 1:length(ceDPE)
                if strcmp(ceDPE{k}, this.cJarPath)
                    lOut = true;
                    return;
                end
            end
            
            lOut = false;
            
        end
        
        
        
        function lOut = megaLibIsLoaded(this)
           
            % DPE == Dynamic Path Entries
            
            ceDPE = javaclasspath;
            for k = 1:length(ceDPE)
                if strcmp(ceDPE{k}, this.cPrivateJarPath)
                    lOut = true;
                    return;
                end
            end
            
            lOut = false;
            
        end
        
        function loadMegaLib(this)
        
            % javaclasspath
            
            % Temporarily set user.dir to this folder so nPoint.jar can
            % load libnPoint.dylib and other files
            
            [cPath, cName, cExt] = fileparts(this.cPrivateJarPath); 
            java.lang.System.setProperty('user.dir', cPath);

            % Add files to Java class path

            javaaddpath(this.cPrivateJarPath);
            
        end
        
        
        function turnOffHardware(this)
            
            % Overload required.  Will look something like this:
            %
            %{
            this.hioCh1P.turnOff();
            this.hioCh1I.turnOff();
            this.hioCh1D.turnOff();
            this.hioCh2P.turnOff();
            this.hioCh2I.turnOff();
            this.hioCh2D.turnOff(); 
            %}
        end
        
        function turnOnHardware(this)
            
            % Overload required.  Will look something like this:
            
            %{
            this.hioCh1P.turnOn();
            this.hioCh1I.turnOn();
            this.hioCh1D.turnOn();
            this.hioCh2P.turnOn();
            this.hioCh2I.turnOn();
            this.hioCh2D.turnOn(); 
            %}
            
        end
        
        
        function handleConnectToggle(this, src, evt)
            
            if(this.uitConnect.lVal)
                                
                % Try to connect
                
                if this.connect()
                    
                    % Success
                    this.msg('handleConnectToggle() connected to Java device');
                                        
                    % Turn on HardwareIO instances 
                    this.turnOnHardware();
                                        
                    notify(this,'eConnect');
                else
                    
                    % Failed.  Show warning message and reset the toggle
                    msgbox( ...
                        ['Could not connect from java device.  ' ...
                        'Check USB cable and controller power.'], ...
                        'Communication error', ...
                        'error');
                    
                    this.uitConnect.lVal = false;
            
                end
                                    
            else
                
                % Attempt to disconnect.  Before doing so, we need to turn
                % off all HardwareIO instances
                
                this.turnOffHardware();
               
                if this.disconnect()
                    % Success
                    
                    notify(this, 'eDisconnect');
                else
                    % Fail  
                    % Show message and reset the toggle
                    msgbox( ...
                        ['Could not disconnect from java device.  ' ...
                        'Check USB cable and controller power.'], ...
                        'Communication error', ...
                        'error');
                    this.uitConnect.lVal = true;
                    
                    % Turn on HardwareIO instances
                    this.turnOnHardware();
                    
                end
            end
                            
        end

    end % protected
    
    methods (Access = private)
        
        
    end
    
    
end