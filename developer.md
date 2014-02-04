# Build notes

Run this first to pull in all the submodules:

git submodule update --init --recursive 
git submodule update --recursive

## OSX

### Dependencies

The first thing is to build LuaJIT. There is a shell script to do this, which can be invoked from the Xcode project (the libluajit.a target).

### LuaAV.app

The Xcode project is designed to target Mac OS 10.6. Yeah, I know, it's like a few years old... but a lot of people still have 10.6 machines and would like to use this software.
If you have Xcode 4 or 5, you'll need to copy the 10.6 SDK into your Xcode.app. E.g., if the old SDKs are in /Developer-old:

	cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
	sudo cp -rf /Developer-old/SDKs/MacOSX10.6.sdk .

Otherwise you could just switch the base SDK to whatever you have, but don't check that change in please.

## Windows



### Build luajit:

Open a VS command prompt & force 32-bit mode:

	vcvarsall.bat x86

Navigate to the luajit-2.0/src folder:

	msvcbuild
	


## Modules

### Search paths

LuaAV uses the default Lua search paths for modules. 

In addition, LuaAV.app adds the folder in which the LuaAV.app resides, as well as the /modules folder inside the LuaAV.app/Contents/Resources/modules





## Notes

LuaAV.app (OSX) is simply a platform-specific wrapper of the LuaJIT interpreter, with console output. It uses Cocoa document-based application structure for the benefits of native user experience. Each cocoa document however simply launches luajit as an NSTask and routes output back to the document window console.  


