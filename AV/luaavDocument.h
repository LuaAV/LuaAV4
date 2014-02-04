//
//  luaavDocument.h
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "luaavApp.h"

@interface luaavDocument : NSDocument
{
	NSString * posix_path;
	const char * posix_path_cstr;
	
	NSTask * task;
	NSPipe * outpipe;
	NSPipe * errpipe;
	NSFileHandle * outpipeReadHandle;
	NSFileHandle * errpipeReadHandle;
	NSDictionary * attributeStdOut;
	NSDictionary * attributeStdErr;
	
	lua_State * L;
	
	CFRunLoopObserverRef runLoopObserver;
	
	
	IBOutlet NSWindow * window;
	IBOutlet NSTextView * consoleView;
	
	BOOL consoleViewScrolling;
}

-(IBAction)stop:(id)sender;
-(IBAction)reload:(id)sender;
-(IBAction)edit:(id)sender;

-(IBAction)logClear:(id)sender;
-(IBAction)logScrolling:(id)sender;
-(IBAction)help:(id)sender;

@end
