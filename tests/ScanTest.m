classdef ScanTest < HandlePlus
%SCANTEST Class provided alongside with the Scan class to test it. 
% The goal here is to test the ability to perform different flavors of scan
%
%   scantest = ScanTest()
%
%   useful methods :
%       - ScanTest.build(hParent, dTop, dLeft)
%
%   types of scan :
%       - ScanTest.startScan()
%       - Scantest.startShutterScan
%       - ScanTest.startAvgScan()
%       - ScanTest.startExponentialScan()
%       - ScanTest.start2Dscan()
%       - ScanTest.startCameraScan()
%
%
%   example of use :
%       sc = ScanTest;
%       sc.build(gcf, 0, 0);
%       sc.startAvgScan;
%       x = sc.scan.cePositions;
%       y = sc.scan.cdData;
%       sc.delete; clear sc;
%
%Comments : beware before using the 'scan' button when a 
%   'complex' scanning procedure has been set. 
%   Make sure all the function handle are correctly defined
%
% See also SCAN, MONITOR


    properties (Constant)

        dWidth  = 300;  %  width of the UI element
        dHeight = 320;  % height of the UI element
    end

    properties (Dependent = true)
    end

    properties
        axis;   % axis instantiated for 1D scan
        axis2;  % axis instantiated for 2D scan
        diode;  % diode instantiated for fake diode measurement
        clock;  % clock instantiated for asynchronous operation %TODO make it gen
        tic;    % time tic, for monitor scan
        camera; % camera instantiaed for multi-image scan
        shutter;% shutter instantiaed for exposure scans
        
        scan;   % scan instantiated for various scan procedure
        scan2;  % scan instantiated for 
        
        nAvg = 10;  % number of averaging for averaged measurement
    end


    properties (SetAccess = private)
        cName   % made private set since there is no setters available;-) 

        hParent;% handle to the parent of the UI element
        hUI;    % handle to the UI element panel
    end

    properties (Access = private)
        dAvgData;   % data container for reading averaging
        dAvgCount;  % cursor for averaging
    end

    events
    end


    methods

    function this = ScanTest()
    %SCANTEST Class constructor
    %   scantest = ScanTest() 
    %   creates a scan test instance, instanting a bunch of virtual motors
    %
    % See also INIT, BUILD, DELETE    
        
        this.cName = 'Scanning test';
        this.clock = Clock('Clock');
        
        this.axis   = Axis('Axis',this.clock);
        this.axis2  = Axis('Axis 2',this.clock);
        this.camera = Camera('Camera');
        this.diode  = Diode('Diode',this.clock);
        this.shutter= Shutter('Shutter', this.clock);
        
        this.scan = Scan('Scan',this.clock, @this.fhMoveFcn, @this.fhSettleFcn, @this.fhAcqFcn );
       
        this.init;
    end



    function init(this)
    %INIT Initializes the class instance (mainly populates the controls)
    %   Scantest.init()
        
        %populating the editboxes for easy test
        this.scan.setup(1,1,3);
    end

%% Axis scan
% This is an example for using scan in the most common mode : moving a
% stage and acquiring the data from a diode
    function startScan(this)
    %STARTSCAN Starts a sample axis scan
    %   ScanTest.startScan()
    %    scans a virtual axis and reads a virtual diode once the position is
    %    reached

        this.scan.fhMoveFcn     = @this.fhMoveFcn;
        this.scan.fhSettleFcn   = @this.fhSettleFcn;
        this.scan.fhAcqFcn      = @this.fhAcqFcn;
        
        %this.scan.setup(0,1,10);
        this.scan.start()
    end
    
        function fhMoveFcn(this, value)
            %this.axis.uieDest.setVal(value)
            %this.axis.moveToDest();
            %equivalently :
            this.axis.move(value);
        end

        function value = fhSettleFcn(this)
            value = this.axis.avVirtual.isStopped();
            %this.axis.avVirtual.dPos
        end

        function value = fhAcqFcn(this)
            value = this.diode.read();
        end
    
    
%% Shutter Scan
% This is an example where the 'positions' of the scan are actually time
% delays rather than axis positions
    
    function startShutterScan(this)
    %STARTSUTTERSCAN Starts a sample shutter scan
    %   ScanTest.startShutterScan()
    %    gradually increase a virtual shutter opening time. 
    %    No data is collected, but it is possible of needed
    
        this.scan.fhMoveFcn     = @this.fhOpenShutter;
        this.scan.fhSettleFcn   = @this.fhWaitShutter;
        this.scan.fhAcqFcn      = @this.fhDoNothing;
        
        this.scan.start;
    end
    
        function fhOpenShutter(this, value)
            this.shutter.uieExposureTime.setVal(value)
            this.shutter.open();
            tic
            fprintf('exposing')
        end

        function value = fhWaitShutter(this)
            value = ~this.shutter.uitOpen.lVal;
        end

        function value = fhDoNothing(this)
            value = 0;
            toc
            tic
            disp('Doing nothing with the shutter scan')
        end
        
%% Time sweep
% This an example where time is the scan 
    function startTimeScan(this)
    %STARTTIMESCAN Starts a virtual diode monitoring
    %   ScanTest.startTimeScan()
    %    reads the reading of a virtual diode every second or so

    %FIXME The time registration is not perfect; 
    
        this.scan.fhMoveFcn     = @this.fhMoveTimeFcn;
        this.scan.fhSettleFcn   = @this.fhSettleTimeFcn;
        this.scan.fhAcqFcn      = @this.fhAcqTimeFcn;
        
        this.scan.setup(0,1,10);
        this.scan.start;
    end
    
        function fhMoveTimeFcn(this, value)
            % do nothing, just wait !
            this.tic = tic;
        end

        function value = fhSettleTimeFcn(this)
            pos = this.scan.cePositions;
            
            value = toc(this.tic)> abs(pos{2}-pos{1});
            %this.axis.avVirtual.dPos
        end

        function value = fhAcqTimeFcn(this)
            value = this.diode.read();
        end

   
%% Camera scan
% This is an example of a scan when an axis is moved and a picture is taken
% for each position of the axis.
% This demonstrate the ability of the scan to handle 'complex' data surch
% as images
    
    %the only difference is the data acquisition
	function startCameraScan(this)
    %STARTCAMERA SCAN Starts a sample camera scan
    %   ScanTest.startCameraScan()
    %    scans a virtual axis and reads a the image for each location

        this.scan.fhMoveFcn     = @this.fhMoveFcn;
        this.scan.fhSettleFcn   = @this.fhSettleFcn;
        this.scan.fhAcqFcn      = @this.fhSnapShotFcn;
        
        this.scan.start;
    end
    
    function value = fhSnapShotFcn(this)
        value = this.camera.acquire();
    end
    
%% 2D spatial scan
% This is an example of a 2-dimensional scan. The main scan accomplish a
% list of subscans, and retrieves there valus when they are completed.
% For now, the trajectory is a E instead of a Z, but that can be easily
% modified by changing alternatively the direction in the fhStartNextScan
% function handle

    function start2Dscan(this)
	%START2DSCAN Starts a sample double axes scan
    %   ScanTest.start2DScan()
    %    scans a virtual axis for each position of another virtual axis,
    %    and reads a virtual diode once the position is reached
    %    It is an example of chained scans

            this.scan.fhMoveFcn     = @this.fhStartNextScan;
            this.scan.fhSettleFcn   = @this.fhIsCurrentScanOver;
            this.scan.fhAcqFcn      = @this.fhGetScanData;
            
            this.scan.setup(2,0.5,3); %main scan positions
            this.scan.start;
    end

        function fhStartNextScan(this,value)
            %move to the main scan position
            this.axis.move(value)
            if ~isempty(this.scan2)
                this.scan2.delete;
            end
            % When arrived at destination, start a subscan
            %Rene Claus 2013-7-19 : 
            %initialize the scan before setting it as a property fixed
            %asynchronous problem
            sc = Scan('Scan2', this.clock, @this.fhMove2Fcn, @this.fhSettle2Fcn, @this.fhAcq2Fcn);
            sc.setup(1,0.25,2);
            sc.start;
            this.scan2 = sc ;
        end
        
            %function handles for the subscans
            function fhMove2Fcn(this, value)
                %the subscan controls an other axis
                this.axis2.move(value);
            end

            function value = fhSettle2Fcn(this)

                value = this.axis2.avVirtual.isStopped();
            end

            %could be fhAcqFcn
            function value = fhAcq2Fcn(this)
                value = this.diode.read();
            end

        %the main scan can read the value when the subscan has completed
        function value = fhIsCurrentScanOver(this)
            if ~isempty(this.scan2)
                value = ~this.scan2.bIsActive;
            else
                value = false;
            end
        end

        %the main scan reads the values of the current subscan
        function value = fhGetScanData(this)
            value = this.scan2.ceData;
        end
   
%% scan with averaging
% This is an example of a scan over a few positions allowing data averaging
% without being a blocking method%
% (here, the average is 10, set in the properties of this class)
% It is working relatively well, even though there are funny things that
% happen when the clock refresh is too slow compared to the speed of the
% tasks
    function startAvgScan(this)
    %STARTAVGSCAN Starts a sample axis scan where the diode signal is averaged
    %   ScanTest.startAvgScan()
    %    scan a virtual axis and reads a virtual diode multiple times 
    %    once the position is reached, before sending the averaged data
    
        this.scan.fhMoveFcn     = @this.fhMoveAcqFcn;
        this.scan.fhSettleFcn   = @this.fhSettleAcqFcn;
        this.scan.fhAcqFcn      = @this.fhAcqAvgFcn;
        
        this.scan.start;
    end
% this would be a blocking procedure
%     function output = fhAcqAvg(this)
%         reading = 0;
%         for i = 1:10
%             reading = this.fhAcqFcn()+reading;
%             pause(1/10)
%         end
%         output = reading/10;
%     end

   function fhMoveAcqFcn(this, value)
        this.axis.move(value);
        this.dAvgCount = 0; %to start a new averaging; must move before flushing
    end

	function value = fhSettleAcqFcn(this)
        %the motor has settled, now start or continue averaging
        if ~this.axis.avVirtual.isStopped() %%&& ~this.clock.has('AxisVirtual:Axis')
            %start or continue averaging
            if ~this.clock.has('Data averaging') %start averaging
                if isempty(this.dAvgCount) || this.dAvgCount ==0 %start averaging %FIXME tricky zero
                    this.clock.add(@this.fhClockDaq, 'Data averaging', 100e-3)
                    value = false;
                else %allow the clock to collect data
                    value = true; %averaging has completed, collect data
                end
            else
                value = false;
            end
        else %motor is not stopped, wait one more loop
            value = true;
        end
    end

    function output = fhAcqAvgFcn(this)
        output = this.dAvgData;
    end    
    
    function fhClockDaq(this)
        this.nAvg = 10; %number of averaged reading
        %flush buffer
        if isempty(this.dAvgCount) || this.dAvgCount == 0
            this.dAvgData  = 0;
            this.dAvgCount = 0;
        end
        
        %everytime, add a reading
        if this.dAvgCount<this.nAvg
            this.dAvgData = this.fhAcqFcn() + this.dAvgData;
            fprintf('averaging\n');
            this.dAvgCount = this.dAvgCount+1;
        else %data is ready to be collected
            this.dAvgData = this.dAvgData/this.nAvg;
            this.clock.remove('Data averaging');
            fprintf('data ready to collect\n')
        end
    end

%% exponential scan
% This is an example of a spatial scan where the position have an
% exponential distance among them. The scan editbox are exponents, and not
% linear
    function startExponentialScan(this)    
    %STARTEXPONENTIALSCAN Starts a sample axis scan with exponential prog
    %   ScanTest.startExponentialScan()
    %    scan a virtual axis with an exponential progression, 
    %    and reads the data once each position is reached
        
        this.scan.fhMoveFcn     = @this.fhMoveExpFcn;
        this.scan.fhSettleFcn   = @this.fhSettleFcn;
        this.scan.fhAcqFcn      = @this.fhAcqFcn;
        
        this.scan.start;
    end
    
    function fhMoveExpFcn(this, value)
        dMin  = this.scan.uieMin.val();
        
        value = dMin.*10.^((value-dMin)/2);
        this.axis.move(value);
    end
        
    function output = test(this,value)
        output =value;
    end
    
%% User interface
    function build(this,hParent,dTop,dLeft)
	%BUILD builds the Scantest user interface, with virtual elements
	%   ScanTest.build(hParent,dTop,dLeft)
    
        this.hParent = hParent;
        %FIMXE fix size
        this.hUI = uipanel( 'Parent', this.hParent,...
                            'Title', this.cName,...
                            'FontWeight', 'Bold',...
                            'BorderType','none',...
                            'Clipping', 'on',...
                            'Units', 'pixels',...
                            'Position', Utils.lt2lb([dLeft dTop 300 320], this.hParent));
        yy = 12;
        this.scan.build(this.hUI,1,yy)
        yy = yy+132;
        this.axis.build(this.hUI,1,yy)
        yy = yy+36;
        this.axis2.build(this.hUI,1,yy)
        yy = yy+36;
        this.diode.build(this.hUI,1,yy)
        yy = yy+36;
        this.shutter.build(this.hUI,1,yy)
    end
    

    
%% Destructor
    function delete(this)
    %DELETE Class destructor
    %   ScanTest.delete()
    %    frees up the memory and remove the clock and all virtual instr.

        if ~isempty(this.axis)
            this.axis.delete
        end
        if ~isempty(this.diode)
            this.diode.delete
        end
        if ~isempty(this.shutter)
            this.shutter.delete
        end
        if ~isempty(this.camera)
            this.camera.delete
        end
        
        if ~isempty(this.clock)
            this.clock.delete
        end
        
        if ~isempty(this.scan)
            this.scan.delete
        end
        
        if ~isempty(this.scan2)
            this.scan2.delete
        end

    end

    end %methods
end %classdef