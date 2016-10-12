# mic
MATLAB Instrument Control library.  

# Directory structure

## components/
Low-level UI components / building blocks

## devices/
High-level UI to control hardware.  They are collections of components that work together to control a piece of hardware.  These should have verbose names like Keithley6517A or SmarPodGoni735B and it is understood that they are UI that control a specific device.  

## assets/
Contains all graphic assets used by the library

## functions/
Functions or libraries that the code relies on

## tests/
Test classes and scripts.  Every class in components/ and devices/ should have a test.


# Recommended project structure

* project
  * lib
    * mic
    * other-lib-a
    * other-lib-b
  * classes
    * ClassA.m
    * ClassB.m
  * tests
  	* TestClassA.m
  	* TestClassB.m

# How to use a specific tag

1. Clone the repo into your project `$ git clone https://github.com/cnanders/mic.git`
2. After the clone, you can list the tags with `$ git tag -l`
3. Checkout a specific tag as a new branch: `$ git checkout <tag_name> -b <branch_name>`.  If you don’t specify a branch name, the repo goes into a “detached head” state. You don't want that.
4. Include the library in your MATLAB code:
 
```
[cPath, cName, cExt] = fileparts(mfilename('fullpath'));
% Add mic 
addpath(genpath(fullfile(cPath, 'mic')));
```



