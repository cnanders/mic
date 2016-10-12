classdef AxisAPI < HandlePlus
    
    properties (Constant)
        
    end
    
    methods (Static)
        
        
        %         
        %  int	abortMove() 
        %           Stop motion, maximum deceleration.
        %  void	disable() 
        %           Disables axis.
        %  void	enable() 
        %           Enables axis.
        %  double	getAcceleration() 
        %           Get axis acceleration.
        %  double	getLowerLimitHard() 
        %           Return lower hardware limit.
        %  double	getLowerLimitSoft() 
        %           Return lower software limit.
        %  double	getPosition() 
        %           Get current axis position.
        %  double	getSpeed() 
        %           Get axis speed.
        %  boolean[]	getSwitches() 
        %           This method returns an array of booleans that represent the current status of the hardware switches on the controller.
        %  double	getUpperLimitHard() 
        %           Returns the upper hardware limit.
        %  double	getUpperLimitSoft() 
        %           Returns the upper software limit.
        %  int	initialize() 
        %           Initialize axis.
        %  boolean	isEnabled() 
        %           Test if the axis has been enabled or disabled by the user.
        %  boolean	isInitialized() 
        %           A test if the axis has been homed or initialized in some fashion.
        %  boolean	isReady() 
        %           Check for axis READY.
        %  boolean	isStopped() 
        %           Check for axis STOPPED.
        %  int	moveAbsolute(double dest) 
        %           Absolute move to target position.
        %  void	setAcceleration(double accel) 
        %           Set axis acceleration.
        %  int	setLowerLimitSoft(double lowerLimit) 
        %           Sets the lower software limit (in native units).
        %  int	setPosition(double pos) 
        %           Define current position.
        %  void	setSpeed(double speed) 
        %           Set axis speed.
        %  int	setUpperLimitSoft(double upperLimit) 
        %           Sets the upper software limit.
        %  int	stopMove() 
        %           Stop motion, normal deceleration.
        %  
        
        
        
        % All static methods require cName property to identify which
        % hardware axis the software is referencing
        
        function dReturn = getPosition(cName)
           
            switch cName
                case 'WFX'
                    
                    % 
                case 'WFY'
                    %
                case 'WCX'
                    %
                case 'WCY'
                    %
                case 'WFTX'
                    %
                case 'WFTY'
                    %
                
            end
            
        end
        
        function lReturn = isStopped(cName) % similar to isThere()
            
        end
        
        function u8Return = stopMove(cName)
            
        end
        
        function enable(cName)
            
        end
        
        function disable(cName)
        end
        
        
        function u8Return = moveAbsolute(cName, dDest)
    

        end
        
       
        
            
    end % Static
end

