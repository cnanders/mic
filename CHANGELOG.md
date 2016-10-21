# 1.0.0-alpha.8

- New component HardwareIOText similar to HardwareIOPlus except that it is unitless, therefore has no cal / raw, and sets values using char, not double.

# 1.0.0-alpha.7

Unknown changes

# 1.0.0-alpha.6

###UiPopupStruct
- now uses varargin

###Keithley6482
- support for new UIPopupStruct constructor

###HardwareIOPlus
- support for new UIPopupStruct constructor



# 1.0.0-alpha.5

###HardwareIOPlus 
- now uses varargin for constructor
- valCal, valCalDisplay, and valRaw now force a call to api.get() instead of using dValRaw that is updated with the clock
- clock task added in build() and only if clock is not empty [ ]

### APIVHardwareIOPlus
- if clock is empty [ ], directly goes to the destination instead of marching a linear path in time to the destination. 

### Documentation
- Added CONVENTIONS.md to describe Hungarian notation, loop counters, and other conventions used throughout the MIC library
- Added NOTES.md


# 1.0.0-alpha.4

Updated README.md with instructions for checking out a specific tag

# 1.0.0-alpha.3

Updated README.md with proposed project structure and other information

# 1.0.0-alpha.2

Added CHANGELOG.md

# 1.0.0-alpha.1

Initial commit