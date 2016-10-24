# 1.0.0-alpha.10

- Improved PC formatting of HardwareIOPlus, HardwareIOText. 
- HardwareIOPlus and HardwareIOText @param {logical 1x1} lActive now defaults to false
- Moved all of the constant width, height props of HardwareIOPlus and HardwareIOText to protected properties so they are settable with varargin syntax.
- @param {char 1xm} cLabelStores now settable with varargin to control label over stores PopUp.

# 1.0.0-alpha.9

###HardwareIOPlus
- New @prop {logical 1x1} [lShowUnit = true] allows hiding the unit dropdown
- New @prop {char 1x1 | 1xm} [cConversion = 'f'] allows setting the string conversion of the value.  'f' for floating point and 'e' for exponential are currently supported
- To set either of these new properties, assignn them in the constructor with varargin syntax.


# 1.0.0-alpha.8

### HardwareIOText
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