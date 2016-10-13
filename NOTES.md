# Random notes

Useful notes learned as this library was built

## uistack()


It seems like uistack doesn't work on hggroup or hgtransfom objects, only the actual instances of images, lights, lines, patches, rectangles, surfaces, and text that are children of the hg* objects. Also, there is a bug in the default renderer, 'painters', which doesn't properly stack objects in the heirarchy with which they are drawn when things are moved. This can be fixed by setting the renderer property of the figure to 'OpenGL' or 'zbuffer' but OpenGL is faster


## How to removed a nested property from a structure

Assume a structure "s" looks like this:

```
  pt
      uieUser
      uieBase
  rc
      uilBooyah
      uilBooyah2
```
and that you want to remove only pt.uieUser.  Here is how you would do
it:

`s.pt = rmfield(s.pt, 'uieUser');`





## Inheritance and overloading in Matlab

Matlab does support inheritance and method overloading but there are some
things you need to be aware of.

UPDATE:

Actually, there is no need to explicitly call the constructor of the base class in the constructor of the extended class; Matlab does this by default. In some cases, you might specifically *not* want to overload some methods due to the order they are called in. Matlab calls the constructor of the base class before executing any commands in the constructor of the extended class. This can result in problems; here is an example. Lets say the base class calls init() and the extended class overrides init(). When the constructor of the base class is called, it will call init() and use the overloaded version out in the extended class. Lets say you pass a clock into the constructor of the extended class and want to set it to a property before init() is evoked... this is impossible in the situation I just described because the overloaded init() will be called immediately, before you can set the clock property.

THE FOLLOWING IS GOOD TO READ, BUT YOU DON'T HAVE TO EXPLICITLY CALL THE CONSTRUCTOR OF THE BASE CLASS IN THE CONSTRUCTOR OF THE EXTENDED CLASS; MATLAB DOES THIS AUTOMATICALLY

I'll discuss a concrete example here.  I wanted to extend HardwareIO and make a class HardwareIOWithSave that also has a drop down of saved destination locations. 

Here is the classdef classdef HardwareIOWithSave < HardwareIO

For the constructor, you want to call the constructor of the parent class.  You do it like this:

```
function this = HardwareIOWithSave(cName, cl, cDispName)
            
  % call constructor of base class which calls init(), which we
  % will overload.  See below 
  this = this@HardwareIO(cName, cl, cDispName);            
            
end
```

The constructor of HardwareIO calls the init() method.  If we overload init() in this extended class HardwareIOWIthSave , the HardwareIO constructor will use the overloaded init() method, that lives out in the extended class.  This is what I wanted to do.

The overloaded init() method is shown below.  You will notice the first thing it does is call init on the base class to initialize everything the base class needs, and it also adds the uipSaved, and the two buttons for saving/ deleting stored destination values.

For overloading to work, the method of the base class needs to have *protected* or *public* access so the extended class can access it. If access is private, overloading does not work.  Also, the overloaded init() method in the extended class has to have the same access rules as the base class.  If it is protected in the base class, it needs to be protected in the extended class

```
methods (Access = protected)
       
  function init(this)
        
      % call init() on base class since we are overloading
      init@HardwareIO(this);
                        
      % do stuff specific for the extended class here
            
  end
        
end
```


## APIHardwareIO classes

**Legacy we no longer do things like this**

These are always passed the instance of the hardware class and they serve as a wrapper to call methods within the hardware class.  They should contain nothing more than some switch blocks that call methods of the associated hardware instance.

When possible, build general APIHardwareIO classes, for example check out the APIHardwareIOStageXYZ class which can be used for any general stage where you want to get/set 'x', 'y', and 'z' properties.  We leave the API general, and un-generalize it in the get(cProp) and set(cProp, dVal) properties of the parent, if needed. I also built a general one for StageXYZRxRy

Every APIHardwareIO needs to implement three methods:

```
function get():double{
    returns value of hardware propery
}

function set(double):void{
    sets the hardware property to the value passed in and, if
    necessary, calls the move
}

function stop():void{
    updates hardware property to val() and/or calls a stop() method if
    the hardware supports it.
}
```

## APIHardwareO classes

**Legacy we no longer do things like this**

These are always passed the instance of the hardware class and they serve as a wrapper to call methods within the hardware class.  They should contain nothing more than some switch blocks that call methods of the associated hardware instance

Every APIHardwareO needs to implement one method:

```
function get():double{
    returns value of hardware propery
}
```

