//
//  luaavDocument.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavDocument.h"

static void l_message(const char *pname, const char *msg)
{
	if (pname) fprintf(stderr, "%s: ", pname);
	fprintf(stderr, "%s\n", msg);
	fflush(stderr);
}

static int traceback(lua_State *L)
{
	if (!lua_isstring(L, 1)) { /* Non-string error object? Try metamethod. */
		if (lua_isnoneornil(L, 1) ||
			!luaL_callmeta(L, 1, "__tostring") ||
			!lua_isstring(L, -1))
			return 1;  /* Return non-string error object. */
		lua_remove(L, 1);  /* Replace object by result of __tostring metamethod. */
	}
	luaL_traceback(L, L, lua_tostring(L, 1), 1);
	return 1;
}

static int docall(lua_State *L, int narg, int clear)
{
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

@implementation luaavDocument

- (int) report: (int) status
{
	if (status && !lua_isnil(L, -1)) {
		const char *msg = lua_tostring(L, -1);
		if (msg == NULL) msg = "(error object is not a string)";
		l_message(posix_path_cstr, msg);
		lua_pop(L, 1);
	}
	return status;
}

- (int)dofile
{
	int status = luaL_loadfile(L, posix_path_cstr) || docall(L, 0, 1);
	return [self report: status];
}

- (id)init
{
    self = [super init];
    if (self) {
		posix_path = NULL;
		L = NULL;
    }
    return self;
}

- (void) dealloc
{
	[self clear];
	[super dealloc];
}

- (void) clear
{
	if (L) lua_close(L);
	if (posix_path) [posix_path release];
}

- (void) run
{
	// run it!
	L = [[luaavApp singleton] createLuaState];
	if (L) {
		
		
		/*
		 //possibility of running scripts as a subprocess?
		 // http://cocoadev.com/UsingAuxiliaryExecutableInBundle
		 // http://www.raywenderlich.com/36537/nstask-tutorial
		 NSTask *task = [[NSTask alloc] init];
		 task.launchPath = @"/usr/bin/say";					// path to luajit
		 task.arguments = @[@"-v", @"vicki", @"hello"];		// path to script + args
		 [task launch];
		 [myTask setCurrentDirectoryPath:@"/Library/Eref/"];
		 // TODO: pipe stdout/stderr into an NSTextView...
		 //[task waitUntilExit];
		 */

		
		int status = [self dofile];
    }
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"luaavDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	//NSLog(@"luaav nib loaded");
}

- (id)initWithType:(NSString *)typeName error:(NSError **)outError {
	NSLog(@"init with type");
	[self init];
	[self setFileType:typeName];
	
	return self;
}

- (BOOL)readFromURL:(NSURL *)inAbsoluteURL ofType:(NSString *)inTypeName error:(NSError **)outError {
	[self clear];
	
	posix_path = [[inAbsoluteURL path] retain];
	posix_path_cstr = [posix_path cStringUsingEncoding:NSASCIIStringEncoding];
	NSLog(@"%@", posix_path);
	
	// TODO: add to filewatcher
	
	[self run];
	
    return YES;
}
@end
