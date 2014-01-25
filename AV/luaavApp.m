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

void script_addtosearchpath(lua_State * L, char * path) {
	char code [8192];
	sprintf(code, "do \
			local path = '%s/' \
			package.path = path .. 'modules/?.lua;' .. package.path \
			package.path = path .. 'modules/?/init.lua;' .. package.path \
			package.cpath = path .. 'modules/?.so;' .. package.cpath \
			end", path);
	if (luaL_dostring(L, code)) {
		printf("%s\n", lua_tostring(L, -1));
		return;
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	app = self;
	
	logViewScrolling = TRUE;
	
	NSFont * font = [[NSFont userFixedPitchFontOfSize:11.0] retain];
	attributeStdOut = [@{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor whiteColor]} retain];
	attributeStdErr = [@{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor orangeColor]} retain];
	
	//perform selector in background thread
	// (TODO: consider doing this via kqueue directly in a kqueue poll thing instead of cooca?)
    [self performSelectorInBackground:@selector(backgroundPoll) withObject:nil];
	
	redirectStdErr = [[[luaavLog alloc] initWithObserver:self withFile:(stderr) withSelector:@selector(luaavRedirectStdErrNotification:)] retain];
	
	redirectStdOut = [[[luaavLog alloc] initWithObserver:self withFile:(stdout) withSelector:@selector(luaavRedirectStdOutNotification:)] retain];
	
	// chdir to the .app container: 
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:[self getApplicationPath]];
	 
	NSLog(@"application bundle container %@", [self getApplicationPath]);
	
	// Q: put modules next to app, or inside resources?
	NSLog(@"resource container %s", [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding: NSASCIIStringEncoding]);
	
	// home directory [NSHomeDirectory() cStringUsingEncoding: NSASCIIStringEncoding]
	
	L = [self createLuaState];
	
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
	
	
	//[self openPath:@"/Users/grahamwakefield/code/libluaav/libluaav/ina.lua"];
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

- (void) backgroundPoll
{
	while (true)
	{
		//Sleep background thread to reduce CPU usage
		[NSThread sleepForTimeInterval:0.1];
		//NSLog(@"tick");
		//printf("tick\n");
		
		// why is this necessary?
		// read somewhere that an OSX bug that since 10.7 has prevented backgroundNotify working on a redirected stdout
		// I seem to have to call this both here AND in the notification handler to get it to work
		// feels really hacky...
		[redirectStdOut poll];
		[redirectStdErr poll];
	}
}

- (lua_State *)createLuaState
{
	LUAJIT_VERSION_SYM();  /* linker-enforced version check */
	
	lua_State * L = lua_open();
	if (L == NULL) {
		fputs("Failed to create Lua state", stderr);
		
	} else {
		
		lua_gc(L, LUA_GCSTOP, 0);  /* stop collector during initialization */
		luaL_openlibs(L);  /* open libraries */
		lua_gc(L, LUA_GCRESTART, -1);
		
		fputs(LUAJIT_VERSION " -- " LUAJIT_COPYRIGHT ". " LUAJIT_URL "\n", stdout);
		
		// add resource/modules path:
		script_addtosearchpath(L, [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding: NSASCIIStringEncoding]);
	}
	return  L;
}

- (void)terminateLua
{
	if (L) lua_close(L);
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

- (void)luaavRedirectStdOutNotification:(NSNotification *)notification
{
	
	@autoreleasepool {
		
		NSFileHandle * fh = [notification object];
		[fh readInBackgroundAndNotify];
		
		NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
														objectForKey: NSFileHandleNotificationDataItem]
											  encoding: NSASCIIStringEncoding] ;
		
		[redirectStdOut oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAttributedString * attr = [[NSAttributedString alloc] initWithString:str attributes:attributeStdOut];
			
			[[logView textStorage] appendAttributedString:attr];
			if (logViewScrolling)
				[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
		});
	}
}

- (void)luaavRedirectStdErrNotification:(NSNotification *)notification
{
	
	@autoreleasepool {
		
		NSFileHandle * fh = [notification object];
		[fh readInBackgroundAndNotify];
		
		NSData * data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
		
		NSString *str = [[NSString alloc] initWithData:data
											  encoding: NSASCIIStringEncoding];
		
		[redirectStdErr oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributeStdErr] ;
			
			[[logView textStorage] appendAttributedString:attr];
			if (logViewScrolling)
				[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
		});
		
	}
}

-(IBAction)logClear:(id)sender {
	NSTextStorage * outputTextStorage = [logView textStorage];
	[outputTextStorage deleteCharactersInRange:NSMakeRange(0, [outputTextStorage length])];
}

-(IBAction)help:(id)sender {
	printf("help\n");
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://luaav.github.io/libluaav/index.html"]];
		//openFile: [[NSString stringWithUTF8String:luaav_app_path()] stringByAppendingPathComponent: @"/extra/docs/index.html"]
}

-(IBAction)logScrolling:(id)sender {
	logViewScrolling = !logViewScrolling;
	if (logViewScrolling) {
		[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
	}
}

// currently disabled (no close button on main window).
- (void)windowWillClose:(NSNotification *)aNotification
{
	[[NSApplication sharedApplication] terminate:self];
}

@end