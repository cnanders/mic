classdef JavaDevice_ais < HandlePlus
% Carl & Vamsi may implement a single "mega" .jar that I use to
% instantiate one Object whose member functions are called to
% instantiate all other objects. The comparison of the "modular"
% approach vs. the "mega" approach is shown below.
%
% Modular:
% this.jDevice      = cxro.common.device
%           .motion.MotionControlProxy('M141-Stage','iman.lbl.gov')
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
        ais_fork = true;
    end
    
    properties (SetAccess = protected)
        % Set these in constructor of child class
        cJarPath
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
        
    
        cPackage            = 'cxro.common.device.motion'; 
        % For string (char) args, use '' as an excaped quote
        cConstructFcn       = 'MotionControlProxy(''M141-Stage'',''iman.lbl.gov'')'; 
        cConstructFcn2      = 'getMotionControl(''M141-Stage'')'; % Use with mega 
        
        cConnectFcn         = 'init()';
        cDisconnectFcn      = 'unInit()';   
    end
    
    events
        eConnect
        eDisconnect
    end
    
    methods
        
        function this = JavaDevice_ais()
        % JavaDevice Class constructor
        %   jd = JavaDevice()
        %
        % See also ...
        
            % This constructor is called by default immediately in the in
            % the constructor of any class that extends this class (it is 
            % called before any code of the child constructor is executed
            
            this.msg('JavaDevice constructor', 8);

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
        %DELETE Class destructor    
        if this.ais_fork
            this.cDisconnectFcn = 'disconnect()';
        end
        
            if ~isempty(this.jDevice)
                this.msg('delete()', 8);
                eval(sprintf('this.jDevice.%s', this.cDisconnectFcn));
            end
        end
        function set_jMegaDevice(this, jMegaDevice)
            this.jMegaDevice = jMegaDevice();
        end
        
        % Programmatic press/unpress of the toggle This will trigger all of
        % the events that happen when the user clicks the connect button
        % manually
        
        function turnOn(this)
        % TURNON Turns on the device
        %   JavaDevice.Turnon()
        %
        % See also JAVADEVICE.TURNOFF
            if ~this.uitConnect.lVal
                this.uitConnect.lVal = true;
            end         
        end
        
        
        function turnOff(this)
        % TURNOFF Turns on the device
        %   JavaDevice.Turnon()
        %
        % See also JAVADEVICE.TURNON
            if this.uitConnect.lVal
                this.uitConnect.lVal = false;
            end
        end
        
        function lReturn = isActive(this)
        %ISACTIVE Returns whehter the device is active or not
        % isActive = JavaDevice.isActive()
        %
        % See aslo ...
            lReturn = this.uitConnect.lVal;
        end
        
        function jMega = get_mega(this)
            jMega =  this.jMegaDevice;
        end
        
    end
    
    
    methods (Access = protected)
               
        function lReturn = connect(this)
            % CONNECT Connects the device
            %   JavaDevice.connect()
            %   isConnected = JavaDevice.connect()
            %
            % See also JAVADEVICE.DISCONNECT
            
            %Case 1 :  Use of Mega.jar
            % Get instance object by calling a method on the mega object
            
            %FIXME: access problems with mega
            if this.ais_fork
                this.lMega = true;
                this.cPrivatePackage = 'intel.ais';
                this.cPrivateConstructFcn = 'AisInstruments';
                this.cPrivateConnectFcn = 'getStage()';
            end
            
            %FIXME : perform load check
            if this.lMega
                % Make sure mega library is loaded
%                 if ~this.megaLibIsLoaded()
%                     this.loadMegaLib();
%                 end
                
                % Make sure jMegaDevice exists
                if isequal(this.jMegaDevice, [])
                    
                    cCode = sprintf('%s.%s', this.cPrivatePackage, ...
                        this.cPrivateConstructFcn);
                    this.jMegaDevice = eval(cCode);
                end
                
                if isequal(this.jDevice, [])
                    cCode = sprintf('this.jMegaDevice.%s', this.cPrivateConnectFcn);
                    this.jDevice = eval(cCode);
                end
                
               
            else
                
                % Case 2: use of a modular .jar
                % Make sure modular library is loaded
                if ~this.libIsLoaded()
                    this.loadLib();
                end
                
                % Create the device if it doesn't exist
                if isequal(this.jDevice, [])
                    if ~strcmp(this.cConstructFcn,'')
                        cCode = sprintf('%s.%s', this.cPackage, this.cConstructFcn);
                    else %there is no explicit construction function
                        cCode = sprintf('%s', this.cPackage);
                    end
                    
                    if ~this.ais_fork
                        try
                            this.jDevice = eval(cCode);
                        catch err
                            rethrow(err)
                        end
                    else %ais fork-- get stage from the main class instance
                        try
                            temp = eval(cCode);
                            this.jDevice = temp.getStage();
                        catch
                            %this.jDevice = intel.ais.AisInstrumentsRemote;
                            warning('error in JavaDevice.connect -- sim mode')
                            temp = intel.ais.AisInstrumentsSimulated;
                            this.jDevice = temp.getStage();
                        end
                    end
                end
            end
            
            % Connect
            cCode = sprintf('this.jDevice.%s', this.cConnectFcn);
            
            try %connect to the device
                if ~this.ais_fork
                    lReturn = eval(cCode);
                else
                    lReturn = strcmp(eval(cCode),'OK');
                end
                this.uitConnect.lVal = true;
            
            catch err
                eval(cCode);
                this.msg(getReport(err), 2);
                lReturn = true;
                
                %should be :
                %                     this.msg(getReport(err));
                %                     lReturn = true;
                %                     rethrow(err)
            end
            
            try
                isInit = this.jDevice.getAxesIsInitialized();
                if ~isInit
                    warning('Smarpod may not be properly referenced')
                end
            catch
                warning('something is wrong with the smarpod...')
            end
            
            
        end
        
        function lReturn = disconnect(this)
            % DISCONNECT Disconnects the device
            %   JavaDevice.disconnect()
            %   isDiconnected = JavaDevice.disconnect()
            %
            % See also JAVADEVICE.CONNECT
            
            if isequal(this.jDevice, [])
                lReturn = false;
                return;
            end
            
            if ~this.ais_fork
                cCode = sprintf('this.jDevice.%s', this.cDisconnectFcn);
            else
                cCode = sprintf('this.jDevice.%s', 'disableAxes()');
            end
            
            try
                if ~this.ais_for
                    lReturn = eval(cCode);
                else
                    lReturn = strcmp(eval(cCode),'OK');
                end
            catch err
                eval(cCode);
                lReturn = true;
            end
        end
        
        
        function loadLib(this)
            %LOADLIB
            %   JavaDevice.loadLib()
            %
            %   See also JavaDevice.libIsLoaded, JavaDevice.loadMegaLib
            
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
        
        function loadMegaLib(this)
        %LOADMAGALIB
        %   JavaDevice.loadMagaLib()
        %
        %   See also JavaDevice.magaLibIsLoaded, JavaDevice.loadLib
            
            % Temporarily set user.dir to this folder so nPoint.jar can
            % load libnPoint.dylib and other files
            [cPath, cName, cExt] = fileparts(this.cPrivateJarPath);
            java.lang.System.setProperty('user.dir', cPath);
            
            % Add files to Java class path
            javaaddpath(this.cPrivateJarPath);
        end
        
        function lOut = libIsLoaded(this)
        %LOADISLOADED Checks whether the appropriate library is loaded
        %   isLibLoaded = JavaDevice.libIsLoaded()
        %
        %   See also JavaDevice.megaLibIsLoaded, JavaDevice.loadLib   
        
            % DPE == Dynamic Path Entries
            ceDPE = javaclasspath('-all');
            for k = 1:length(ceDPE)
                if strcmp(ceDPE{k}, this.cJarPath)
                    lOut = true;
                    return;
                end
            end
            lOut = false;
        end
        
        function lOut = megaLibIsLoaded(this)
        %MEGALOADISLOADED Checks whether the appropriate library is loaded
        %   isLibLoaded = JavaDevice.megaLibIsLoaded()
        %
        %   See also JavaDevice.libIsLoaded, JavaDevice.loadMegaLib
           
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

        %FIXME : remove TurnOn and Off-- useless
        function turnOffHardware(this)
            % Overload required.  
            % Will look something like this:
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
        %HANDLECONNECTTOGGLES Callback for the "Connect" button
            
            if(this.uitConnect.lVal) %if the button shows "Connect"         
                % Try to connect
                if this.connect()
                    
                    % Success
                    this.msg('handleConnectToggle() connected to Java device', 6);
                                        
                    % Turn on HardwareIO instances 
                    this.turnOnHardware();
                                        
                    notify(this,'eConnect');
                else % Failed.  Show warning message and reset the toggle
                    msgbox( ...
                        ['Could not connect from java device.  ' ...
                        'Check USB cable and controller power.'], ...
                        'Communication error', ...
                        'error');
                    
                    this.uitConnect.lVal = false;
                end
                                    
            else % if the button shows "disconnect"
                % Attempt to disconnect.  Before doing so, we need to turn
                % off all HardwareIO instances
                
                this.turnOffHardware();
               
                if this.disconnect() % Success
                    notify(this, 'eDisconnect');
                else  % Fail  
                    % Show message and reset the toggle
                    msgbox( ...
                        ['Could not disconnect from java device.  ' ...
                        'Check USB cable and controller power.'], ...
                        'Communication error', ...
                        'error');
                    this.uitConnect.lVal = true;
                    
                    %FIXME ????
                    % Turn on HardwareIO instances
                    this.turnOnHardware();
                end
            end                 
        end

    end % protected
    
    methods (Access = private)
    end
    
    
end