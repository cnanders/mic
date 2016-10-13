# Conventions

This docuemnt describes conventions used by the MIC library

## Hungarian notation

The MIC library uses Hungarian notation.  This is not a standard in MATLAB, however, the creators of the library feel that it is useful to have a prefix that specifies variable type to make the library more readable and maintanable.  MATLAB IDE is not good about type hinting.



### MATLAB classes


- x:    mixed (can be any type)
- d:    double
- s:    single
- i8:   int8 (signed)
- i16:  int16 (signed)
- i32:  int32 (signed)
- u8:   uint8
- u16:  uint16
- u32:  uint32
- c:    char
- h:    handle
- l:    logical (MATLAB equiv of boolean) (true is shorthand logical(1))
- st:   struct
- ce:   cell
- t:    timer
- fh:   function_handle
- vi:   videoinput (Image Acquisition Toolbox)
- j:    java native(must always be private to wrapper class)    

### Custom classes

- uip: UIPopup
- uil: UIList
- uie: UIEdit
- uic: UICheckbox
- uib: UIButton
- uit: UIToggle 
- hio:      HardwareIO
- ho:       HardwareO
- setup:    Setup
- ax:   Axis
- as:   AxisSetup
- av:   AxisVirtual
- api:  API*
- apiv: APIVirtual*
- di: Diode
- ds: DiodeSetup
- dv: DiodeVirtual
- sc: scan
- cm: camera
- mr: Mirror
- cl: Clock
- win:  Window
- pan:  Panel

### When to use Hungarian notation?

Only for primitive Matlab classes and core framework classes, as outlined above

For me hungarian notation lets you define two things with the variable name:

 1. the Matlab class 
 2. the physical thing the variable represents

For example, "uieResistName" says that this variable represents the name of the resist and that it is a UIEdit Matlab class. We need the Hungarian prefix because the "representation" part (ResistName) is not enough to specify what Matlab class it is (it could be a char, or anything). It is ambiguous)

But lets consider a higher-level class like ReticleCoarseStage. Here, if we use a variable name like "reticleCoarseStage" the "physical thing the variable represents" and the Matlab class name are identical, so there is no need for the hungarian prefix. I.E., the variable instance represents the reticle coarse stage and the Matlab class is called ReticleCoarseStage, so there is no need for the Hungarian prefix.

I think whenever the Matlab class name is identical to the physical thing the variable represents, there is no need for a hungarian prefix.


## Loop counters

k, m, p, q (loop counters are excempt from Hungarian notation)



## Array initialization

- true(0)                 0x0 logical
- []                      0x0 double
- {}                      0x0 cell
- struct()                1x1 struct with no fields
- struct([])              0x0 struct with no fields






