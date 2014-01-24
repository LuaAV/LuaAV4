# Build notes

## OSX

### Dependencies

The first thing is to build LuaJIT. There is a shell script to do this, which can be invoked from the Xcode project (the libluajit.a target).

### LuaAV.app

The Xcode project is designed to target Mac OS 10.6. Yeah, I know, it's like a few years old... but a lot of people still have 10.6 machines and would like to use this software.
If you have Xcode 4 or 5, you'll need to copy the 10.6 SDK into your Xcode.app. E.g., if the old SDKs are in /Developer-old:

	cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
	sudo cp -rf /Developer-old/SDKs/MacOSX10.6.sdk .

Otherwise you could just switch the base SDK to 10.whatever you have, but don't check that change in please.




