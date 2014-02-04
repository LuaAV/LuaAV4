//
//  luaavAppDelegate.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavApp.h"
#import "luaavDocument.h"

luaavApp * app = 0;

@implementation luaavApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	app = self;
	
	// chdir to the .app container:
	//[[NSFileManager defaultManager] changeCurrentDirectoryPath:[self getApplicationPath]];
	 
	NSLog(@"application bundle container %@", [self getApplicationPath]);
	
	// Q: put modules next to app, or inside resources?
	NSLog(@"resource container %s", [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding: NSASCIIStringEncoding]);
	
	// home directory [NSHomeDirectory() cStringUsingEncoding: NSASCIIStringEncoding]
	
	char cwd[1024];
	getcwd(cwd, 1024);
	// "/"
	printf("cwd %s\n", cwd);
	
	// e.g. /Users/grahamwakefield/code/LuaAV4/build/Debug/LuaAV.app
	printf("bun %s\n", [[[NSBundle mainBundle] bundlePath] UTF8String]);
	// e.g. /Users/grahamwakefield/code/LuaAV4/build/Debug/LuaAV.app/Contents/MacOS/LuaAV
	printf("bun %s\n", [[[NSBundle mainBundle] executablePath] UTF8String]);
	
	NSLog(@"cwd %s", cwd);
	
	//[webView setMainFrameURL:@"http://www.google.com/"];
	//[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

- (NSString*) getApplicationPath {
	NSString *appPath = [[NSBundle mainBundle] executablePath];
	appPath = [appPath stringByResolvingSymlinksInPath];
	NSArray *bundlePathComponents = [appPath componentsSeparatedByString:@"/Contents"];
	appPath = [bundlePathComponents objectAtIndex:0];
	bundlePathComponents = [appPath pathComponents];
	appPath = [appPath substringToIndex: ([appPath length] - [[bundlePathComponents lastObject] length])];
	if([appPath length] > 1) {
		appPath = [appPath substringToIndex: [appPath length]-1];
	}
	return appPath;
}

+ (luaavApp *)singleton
{
	return app;
}

- (void)openPath:(NSString *)path
{
	NSError * error;
	NSURL * absoluteURL = [NSURL fileURLWithPath:path];
	
	id newdoc = [[NSDocumentController sharedDocumentController] makeDocumentWithContentsOfURL:absoluteURL
																						ofType:@"DocumentType"
																						 error:&error];
	
	[[NSDocumentController sharedDocumentController] addDocument: newdoc];
	[newdoc makeWindowControllers];
	[newdoc showWindows];
}

/*
 // don't use this for document-based app
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSLog(@"openFile %@", filename);
	
	[[luaavDocument alloc] init];
	
	return YES;
}
 */

// currently disabled (no close button on main window).
- (void)windowWillClose:(NSNotification *)aNotification
{
	[[NSApplication sharedApplication] terminate:self];
}

@end