//
//  luaavAppDelegate.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavApp.h"

@implementation luaavApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	
	logViewScrolling = TRUE;
	
	NSFont * font = [[NSFont userFixedPitchFontOfSize:11.0] retain];
	attributeStdOut = [@{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor whiteColor]} retain];
	attributeStdErr = [@{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor orangeColor]} retain];
	
	redirectStdOut = [[[luaavLog alloc] initWithObserver:self withFile:(stdout) withSelector:@selector(luaavRedirectStdOutNotification:)] retain];
	
	redirectStdErr = [[[luaavLog alloc] initWithObserver:self withFile:(stderr) withSelector:@selector(luaavRedirectStdErrNotification:)] retain];
	
	//[webView setMainFrameURL:@"http://www.google.com/"];
	//[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
	
	
	[self initLua];
}

static void print_jit_status(lua_State *L)
{
	int n;
	const char *s;
	lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
	lua_getfield(L, -1, "jit");  /* Get jit.* module table. */
	lua_remove(L, -2);
	lua_getfield(L, -1, "status");
	lua_remove(L, -2);
	n = lua_gettop(L);
	lua_call(L, 0, LUA_MULTRET);
	fputs(lua_toboolean(L, n) ? "JIT: ON" : "JIT: OFF", stdout);
	for (n++; (s = lua_tostring(L, n)); n++) {
		putc(' ', stdout);
		fputs(s, stdout);
	}
	putc('\n', stdout);
}

- (void)initLua
{
	LUAJIT_VERSION_SYM();  /* linker-enforced version check */
	
	// TODO: any args to push to script?
	
	L = lua_open();
	if (L == NULL) {
		fputs("Failed to create Lua state", stderr);
	} else {
		
		lua_gc(L, LUA_GCSTOP, 0);  /* stop collector during initialization */
		luaL_openlibs(L);  /* open libraries */
		lua_gc(L, LUA_GCRESTART, -1);
		
		fputs(LUAJIT_VERSION " -- " LUAJIT_COPYRIGHT ". " LUAJIT_URL "\n", stdout);
		print_jit_status(L);
	}
}

- (void)terminateLua
{
	if (L) lua_close(L);
}

- (void)luaavRedirectStdOutNotification:(NSNotification *)notification
{
	
	@autoreleasepool {
		[redirectStdOut poll];
	
		NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
														objectForKey: NSFileHandleNotificationDataItem]
											  encoding: NSASCIIStringEncoding] ;
		
		[redirectStdOut oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
		
		//dispatch_async(dispatch_get_main_queue(), ^{
		NSAttributedString * attr = [[NSAttributedString alloc] initWithString:str attributes:attributeStdOut];
		
		[[logView textStorage] appendAttributedString:attr];
		if (logViewScrolling)
			[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
		//});
	}
}

- (void)luaavRedirectStdErrNotification:(NSNotification *)notification
{
	
	@autoreleasepool {
		[redirectStdErr poll];
	
		NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
														objectForKey: NSFileHandleNotificationDataItem]
											  encoding: NSASCIIStringEncoding];
		
		[redirectStdErr oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
		
		//dispatch_async(dispatch_get_main_queue(), ^{
		NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributeStdErr] ;
		
		[[logView textStorage] appendAttributedString:attr];
		if (logViewScrolling)
			[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
		//});
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