# Build notes

Run this first to pull in all the submodules:

git submodule update --init --recursive 
git submodule update --recursive

## OSX

### Dependencies

The first thing is to build LuaJIT. There is a shell script to do this, which can be invoked from the Xcode project (the LuaJIT target).

### LuaAV.app

LuaAV.app (OSX) is simply a platform-specific wrapper of the LuaJIT interpreter, with console output. It uses Cocoa document-based application structure for the benefits of native user experience. Each document launches the script using LuaJIT as a subprocess, and routes output back to the document window console. It also watches the script file for modifications, and re-runs the script when changes occur.

The Xcode project is designed to target Mac OS 10.6. I know, it's a few years old now... but people still have 10.6 machines and would like to use this software. If you have Xcode 4 or 5, you'll need to copy the 10.6 SDK into your Xcode.app. E.g., if the old SDKs are in /Developer-old:

	cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
	sudo cp -rf /Developer-old/SDKs/MacOSX10.6.sdk .

Otherwise you could just switch the base SDK to whatever you have, but don't check that change in please.

## Windows

### Build luajit:

Open a VS command prompt & force 32-bit mode:

	vcvarsall.bat x86

Navigate to the luajit-2.0/src folder:

	msvcbuild

## Linux

# Modules

## Search paths

LuaAV uses the default Lua search paths for modules. 

In addition, LuaAV.app adds the /modules folder inside the LuaAV.app/Contents/Resources/modules, and the folder from which the user script is loaded.

# Roadmap

## Windows

- Minimal launcher/watcher. Will need to test application path is reliable, since modules are not embedded in a bundle.

## OSX

- File->New
- Investigate if kqueue is better than NSTask/NSPipe notifcation etc.
- Integrate app server (libwebsockets?) and client (WebKit) for live coding interface. 
- Make edit button use web interface, and integrate Save behavior for NSDocument



