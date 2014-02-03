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
	NSPipe * pipe;
	
	lua_State * L;
	
	
	CFRunLoopObserverRef runLoopObserver;
}

@end
