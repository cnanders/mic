classdef APILabjack < HandlePlus
    
    properties    
        hDevice = 0;
    end

    methods 
        
        function this = APILabjack()
            this.init();
        end
        
        function init(this)
            ljmAsm = NET.addAssembly('LabJack.LJM'); %Make the LJM .NET assembly visible in MATLAB
            
            t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
            LJM_CONSTANTS = System.Activator.CreateInstance(t); %creating an object to nested class LabJack.LJM.CONSTANTS
            
            try
                %Open first found LabJack
                [ljmError, this.hDevice] = LabJack.LJM.OpenS('ANY', 'ANY', 'ANY', this.hDevice);
                % showDeviceInfo(handle);
            catch e
                showErrorMessage(e)
            end
            
        end
      
        function out = get(this)
            try
                %Setup and call eReadName to read from AIN0.
                name = 'AIN0';
                [ljmError, value] = LabJack.LJM.eReadName(this.hDevice, name, 0);
                %disp([name ': ' num2str(value) ' V'])
                out = value;
            catch e
                showErrorMessage(e)
            end
        end
        
        function delete(this)
            try
                % Close handle
                LabJack.LJM.Close(this.hDevice);
            catch e
                showErrorMessage(e)
            end
            %this.delete();
        end

    end
    
end

