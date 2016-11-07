classdef InterfaceNPoint < HandlePlus

    methods (Abstract)
        
        % Assign the wavetable values and begin scanning.  Stages have
        % 20-bit precision throughout their range.  Positions are 20-bit
        % signed (+/-524287). When signal is at +/- 524287, the stage is at
        % its max range. For example, if an axis has a range of +/- 50 um
        % and you want to command the stage to move to +15 microns from
        % center, you would set "signal" to 0x26666 (= 524287/50*15). User
        % passes in pre-scaled array of integers The maximum buffer size is
        % 83,333 points, 2 seconds of data at full loop speed (1 clock
        % cycle every 24 usec). Example of creating 20-bit values:
        %
        % i32Ch1 = int32(this.dVx/this.uieVoltsScale.val()*2^20/2);
        % i32Ch2 = int32(this.dVy/this.uieVoltsScale.val()*2^20/2);
        %
        % @param {int32 1xm} - 20-bit values for x position
        % @param {int32 1xm} - 20-bit values for y position
        % @return {logical 1x1} - true if successful
        setWavetable(this, i32X, i32Y)
        
        % Enable both channels.  This does not start both channels, it
        % allows both channels to be started with the start command
        enable(this)
        
        % Disable both channels.  See enable
        disable(this)
        
        % Start both channels scanning
        start(this)
        
        % Stop both channels from scanning
        stop(this)
        
        % @return {logical 1x1} - return true if both channels are enabled
        isEnabled(this)
        
        % @param {uint8 1x1} u8Channel - the channel (1 or 2)
        % @param {char 1xm} cType - 'p', 'i', 'd'
        % @return {double 1x1} - the value
        getGain(this, u8Channel, cType)
        
        % Set PID gain parameters
        % @param {uint8 1x1} u8Channel - the channel (1 or 2)
        % @param {char 1xm} cType - 'p', 'i', 'd'
        setGain(this, u8Channel, cType)
        
        % Record the commanded and sensor signals on both channels for a
        % specified duration
        % @param {double 1x1} dTime - record time in ms 
        % @return {struct 1x1} stReturn
        % @return {int32 1xm} stReturn.i32Command1 - the commanded signal
        % on channel 1
        % @return {int32 1xm} stReturn.i32Sensor1 - the sensor value
        % on channel 1
        % @return {int32 1xm} stReturn.i32Command2 - the commanded signal
        % on channel 2
        % @return {int32 1xm} stReturn.i32Sensor2 - the sensor value
        % on channel 2
        % @return {double 1xm} stReturn.dTime - time values at each
        % recorded sample
        record(this, dTime)
        
        % Retrieve a string that lists the value of every parameter that
        % can be retrieved from the hardware
        % @return {cStatus 1xm} - text string 
        status(this, u8Channel)
        
        
        
    end
    
end
        
