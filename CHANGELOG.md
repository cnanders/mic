# 1.0.0-alpha.38

### UIEdit
- New private property lNotify used to wrap all calls to notify to allow temporary disabling of notify on setVal() [see below]
- New method setValWithoutNotify() equivalent to setVal() but does not notify 'eChange' event

### HardwareIOPlus
- Added dWidthPad* properties to allow padding any of each configurable UI component
- New properties lAskOnApiClick and lAskOnInitClick allow configuring if it shows confirmation dialog when these buttons are clicked.
- Now dispatches 'eTurnOff' on turnOff() and 'eTurnOn' on turnOn()

### Keithley6482 
- New property lAskOnApiClick allows configuring if it shows confirmation dialog when the 
API button is clicked.


# 1.0.0-alpha.37

### ConfigHardwareIOPlus
- Now supports optional 'step' property which is the step in raw units.
- If not provided in config.json, defaults to 0.1
- Now supports optional 'min' and 'max' values (raw unit).  When not provided, defaults to +/-maxreal()

### HardwareIOPlus
- Now sets uieStep.val() to config.step on load
- Now has option lShowRange.  When true, displays the range [config.min, config.max]
- Now changes value color during moves


### Keithley6482
- Added dTimeout property to set the timeout
- Now supports setting the baud rate of serial communication
- Refactored the device API wrappers.  Now have HardwareIOPlusFromKeithley, HardwareIOTextFromKeithley, HardwareOPlusFromKeithley.  
- Deleted all previous API wrappers
- Now when lShowSettings = true and lShowRange = false, draws settings at correct height
- delete() method now calls disconnect() method and calls delete({serial})

# 1.0.0-alpha.36

### Keithley6482
- Now supports varargin
- Added cPort property 
- Renamed terminator property to cTerminator to follow Hungarian

### HardwareIOPlus
- In turnOn() call this.setDestCalDisplay(this.valCalDisplay()) to update goal to device value.

# 1.0.0-alpha.35

### UIImageLogical
- New component that has two image states to display the value of a logical
- This will most likely break other code.  I will need to fix.

### InterfaceHardwareIOPlus
- Modified the Interface to add initialize() and isInitialized() methods which all of Carl's Axis classes need.  

### HardwareIOPlus
- Added Init button to send initialize() gommand to API.
- Added InitState UIImageLogical to show the state of isInitialized()
- handleClock now polls getApi().isInitialized() along with getApi().get()
- Both of these UI elements are configurable in varagrin with [lShowInitButton = true] and [lShowInitState = true]
- Updated image assets for the API toggle

### Keithley6482
- Updated image assets for the API toggle


# 1.0.0-alpha.34

- Added .mat to .gitignore
- Removed all .mat files from the repository

### HandlePlus
- Added setVarargin() method since many components are now varargin.  Built a unified way to set properties.
- It turns out that this doesn’t work because the base class cannot access protected / private methods in the child class. 

# 1.0.0-alpha.33

### HardwareIOPlus, HardwareIOText
- Removed setter for apiv property and added method setApiv()
- Moved documentation from above the constructor to the property names in the class definition

### Keithley6517a, Keithley6482
- Added setApiv() method that calls setApiv() on all of the HioText and Hio instances so they use the wrappers around ApivKeithley* that implement the correct interface for the UI components.
- call to setApiv() now at the end of init() since it relies on having all of the Hardware* instances available
- delete() method now properly calls delete() on all children
- delete() now deletes the apiv at the end (after all Hardware* classes have been deleted) since they rely on the api/apiv being available for timer callbacks

### Unanswered Question
What class is responsible for deleting api and apiv instances? Need to think about this.  Often times, Hardware* classes have an api that is an interface wrapper around a larger API. It should be OK for Hardware* classes to delete their api refernce in this scenario. 

# 1.0.0-alpha.32

### Keithley6482
- Added lShowRange and lShowSettings to allow disabling the range and settings UI.  Made changes robust enough that if there is ever a version of this instrument with separate settings for each channel, a few lines of code can make this work. 

### Keithley6517a
- Bug fixes from 1.0.0-alpha.31 in setApi() and turnOff() methods

# 1.0.0-alpha.31

### Keithley6517a
- Added lShowRange and lShowSettings to allow disabling the range and settings UI

### ApiKeithley6517a
- Now supports serial and GPIB communication protocols.  Both are synchronous right now.  Communication isn't the bottleneck; it is the time the device takes to fill buffer with answer.
- Full synchronous read takes between 50 ms - 60 ms
	- 3 ms to send the command
	- 45 ms for the instrument to fill its buffer
	- 1 ms for reading the result 
- Commented tic/toc that was used while debugging serial vs. gpib speed

# 1.0.0-alpha.30.5

### NOT STABLE RELEASE

### UIEdit
Figured out how to make it notify 'eEnter' on clicking enter and have the val() function report the value in the edit box.  get(src, 'String') doesn't return the value the user has typed until the callback is evoked. The callback is evoked by pressing enter or by clicking another component but in the callback there is no way to know if it was evoked from enter or not.  I used KeyPress event to store the last key press and check it in the callback.  This was a 



# 1.0.0-alpha.30.3

### NOT STABLE RELEASE

In the process of making backwards compatible with 2009b.  And eventually want to try going back to 2008a, where OOP was first introduced.  isprop() functions differently in 2009b then in 2013a, which is the last place it was tested.

# 1.0.0-alpha.30.2

### NOT STABLE RELEASE

### KEITHLEY6517A
- Build new API that asynchronously polls the device and stores recent values so when a consumer needs them, it can get them immediately.  Not fully tested.

# 1.0.0-alpha.30.1

### NOT STABLE RELEASE

### Keithley6517A
- Fixed bug referncing this.terminator instead of this.cTerminator

### Clock
- Added second optional paramater in constrictor to set the period

# 1.0.0-alpha.30
- Renamed components/HardwareIOPlus/InterfaceHardwareIO to InterfaceHardwareIOPlus to fix namespace conflict with components/HardwareIO/InterfaceHardwareIO
- In devices folder, all APIs that implemented InterfaceHardwareIO were switched to HardwareIOPlus


# 1.0.0-alpha.29

### Keithley6517A
- Major changes to visual appearance

### HardwareIOToggle
- Minor changes 

# 1.0.0-alpha.28

### HardwareIOPlus, HardwareIOText, HardwareOPlus
Fixing case errors in class names due to git case insensivity that occurred in 1.0.0-alpha.26 release


# 1.0.0-alpha.27

### Keithley6482, Keithley6517A
Fixing case errors in class names due to git case insensivity that occurred in 1.0.0-alpha.26 release

# 1.0.0-alpha.26

### Keithley6482, Keithley6517A
- Disambiguated names of API wrappers.  In general, it is good practice to have verbose names for API wrappers.  I'm using ApiKeithley6482AutoRangeState, for exampele, for the API that implements InterfaceHardwareIOText.

# 1.0.0-alpha.25

- HardwareIOPlus, HardwareIOText, HardwareOPlus, Keithley6482, Keithley6517A all migrating away from upper-case acronyms in class names and method names.   For example APIHIOTXAutoRangeState became ApiHiotxAutoRangeState for easier readibility.  

# 1.0.0-alpha.24

### Config
- Deprecated and it became ConfigHardwareIOPlus for more verbosity

### HardwareIOPlus, Keithley6517A, Keithley6482
- Updated to use ConfigHardwareIOPlus instead of deprecated Config

# 1.0.0-alpha.23

- Moved tests into component and devide folders so they are easier to find.  Now a component or device folder contains its tests.


# 1.0.0-alpha.22

### Keithley6482
- Updates to appearance.  Made it more closely resemble the display on the physical unit

# 1.0.0-alpha.21

### UIEdit
- Temporarily disabling KeyReleaseFcn callback and channeling the handler through KeyPressFcn which works in earlier versions of MATLAB.
- Update to HardwarePlus.checkDir() for better type checking (forces === 7 check) and it now displays a message whenever it creates a directory.


# 1.0.0-alpha.20

### Keithley6482
- Realized that ADC period, average filter, and median filter apply globally to both channels.  Updated UI to reflect this.
- Changed API to implement READ? SPCI command instead of MEASure?.  MEASure calls another function which sets auto range to on on both channels.  Not what we want.

# 1.0.0-alpha.19

### Keithley6482
- Rebuilt the UI as a 2-channel version of Keithley 6517A

# 1.0.0-alpha.18

### Keithley6517A
- Added tests from DCT codebase.

# 1.0.0-alpha.17

### Keithley6517A
- Added this device from DCT codebase.  The API uses the MATLAB Instrument Control Toolbox and talks to the device using SCPI (Standard Commands for Programmable Instruments).

# 1.0.0-alpha.16

### HardwareOPlus
- Fixed bug in constructor.  Now works with varargin.  Since HardwareOPlus is a HardwareIOPlus with limited functionality, since changing HardwareIOPlus to varargin input HardwareOPlus was not working correctly. 

### HardwareOPlus, IOPlus, IOText
- Now have settable properties for the values of each label

# 1.0.0-alpha.15

### UIEdit
- Now nofies event eEnter when user releases the Enter key while the UI has focus (onKeyRelease)

### HardwareIOPlus
- Now calls moveToDest() when the user releases the Enter key when the destination has focus

# 1.0.0-alpha.14

### HardwareIOPlus
- Updated APIInterface with return values on get and isReady

### HardwareIOText
- Updated APIInterface with return value on get
- Fixed bug that called depricated setValRaw method in turnOn method

### Keithley6482
- Finalized APIInterface
- Built API
- Built APIV
- improved tests to call several methods of the class

# 1.0.0-alpha.13

### HardwareIOPlus, HardwareIOText,
- Now notify {event} eChange only when the value changes

# 1.0.0-alpha.12

###HardwareIOPlus, HardwareIOText,
- Now notify {event} eChange when the destination changes


#1.0.0-alpha.11

### HardwareIOPlus, HardwareIOText, UIButtonToggle
- enable, disable methods now supported to dis/enable UI programatically

# 1.0.0-alpha.10

### HardwareIOPlus, HardwareIOText
- Improved formatting on Windows
- @param {logical 1x1} lActive now defaults to false
- Moved all of the constant width, height props to protected properties so they are settable with varargin syntax.
- @param {char 1xm} cLabelStores now settable with varargin to control label over stores PopUp.

# 1.0.0-alpha.9

### HardwareIOPlus
- New @prop {logical 1x1} [lShowUnit = true] allows hiding the unit dropdown
- New @prop {char 1x1 | 1xm} [cConversion = 'f'] allows setting the string conversion of the value.  'f' for floating point and 'e' for exponential are currently supported
- To set either of these new properties, assignn them in the constructor with varargin syntax.


# 1.0.0-alpha.8

### HardwareIOText
- New component HardwareIOText similar to HardwareIOPlus except that it is unitless, therefore has no cal / raw, and sets values using char, not double.

# 1.0.0-alpha.7

Unknown changes

# 1.0.0-alpha.6

### UiPopupStruct
- now uses varargin

### Keithley6482
- support for new UIPopupStruct constructor

### HardwareIOPlus
- support for new UIPopupStruct constructor



# 1.0.0-alpha.5

### HardwareIOPlus 
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