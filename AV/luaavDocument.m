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

void MyRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info)
{
    luaavDocument* me = (luaavDocument*)info;
    
    //printf("idle %p\n", info);
 
    // Perform your tasks here.
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
		runLoopObserver = NULL;
		
		task = NULL;
		pipe = NULL;
		
		//[self installRunLoopObserver];
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
	if (task) {
			[task terminate];
		[task release];
		task = NULL;
	}
	if (pipe) { [pipe release]; pipe = NULL; }
	
	if (L) { lua_close(L); L = NULL; }
	if (posix_path) { [posix_path release]; posix_path = NULL; }
}

- (void) installRunLoopObserver
{
    printf("adding self %p\n", self);
	
	CFRunLoopObserverContext context;
	memset (&context, 0, sizeof (context));
	context.info = self;
    
	// Create the observer reference.
    runLoopObserver = CFRunLoopObserverCreate(NULL,
                            kCFRunLoopEntry, //kCFRunLoopBeforeTimers | kCFRunLoopBeforeWaiting,
                            YES,        /* repeat */
                            0,
                            &MyRunLoopObserver,
                            &context);
 
    if (runLoopObserver)
    {
        // Now add it to the current run loop
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, kCFRunLoopCommonModes);
    }
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
	
	//[self run];
	
	// run luajit from the resources folder:
	task = [[NSTask alloc] init];
	pipe = [[NSPipe alloc] init];
	
	[task setLaunchPath: [NSString stringWithFormat:@"%@/modules/luajit", [[NSBundle mainBundle] resourcePath]]];
	//[task setLaunchPath: [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"luajit"]];
	[task setArguments: [NSArray arrayWithObjects: [NSString stringWithFormat:@"%@/start.lua", [[NSBundle mainBundle] resourcePath]], posix_path, nil]];
	
	// set cwd to the source script?
	//[task setCurrentDirectoryPath:[posix_path stringByDeletingLastPathComponent]];
	
	// [task setEnvironment
	
	//[task setStandardOutput: pipe];
	//[task setStandardError: pipe];
	
	[task launch]; //launch the task
	
	// [task setStandardInput:[NSFileHandle fileHandleForReadingAtPath:@"inputfile.text"]];
	
	/*
	 http://www.cocoabuilder.com/archive/cocoa/170680-using-nstask-and-nspipe-to-perform-shell-script.html
	 
	 NSPipe *writePipe = [NSPipe pipe];
	 NSFileHandle *writeHandle = [writePipe
	 fileHandleForWriting];
	 
	 
	 [task setStandardOutput: readPipe];
	 [task setStandardError: errorPipe];
	 [task setStandardInput: writePipe];
	 
	 [writeHandle writeData:[NSData
	 dataWithContentsOfFile:@"/users/keithblount/Markdown/readme.markdown"]];
	 [writeHandle closeFile];
	 
	 NSData *readData;
	 
	 while ((readData = [readHandle availableData])
	 && [readData length]) {
	 [data appendData: readData];
	 }
	*/
	
	// NSPipe *readPipe = [NSPipe pipe];
	// NSFileHandle *readHandle = [readPipe fileHandleForReading];

	/*
	// periodic:
	NSData * data = [[pipe fileHandleForReading] readDataToEndOfFile];
	NSString *string = [[NSString alloc] initWithData: data encoding:
						NSASCIIStringEncoding];
	[string release];
	*/
    return YES;
}
@end
