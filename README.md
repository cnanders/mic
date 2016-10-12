# mic
Matlab Instrument Control Toolbox

## components/
Low-level UI components / building blocks

## devices/
High-level UI to control hardware.  They are collections of components that work together to control a piece of hardware.  These should have verbose names like Keithley6517A or SmarPodGoni735B and it is understood that they are UI that control a specific device.  

## assets/
Contains all graphic assets used by the library

## functions/
Functions or libraries that the code relies on

## tests/
Test classes and scripts