//
//  luaavAppDelegate.h
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "luaavLog.h"

#include "lua.h"
#include "lualib.h"
#include "luajit.h"
#include "lauxlib.h"

@interface luaavApp : NSObject <NSApplicationDelegate, NSWindowDelegate> {
@public
	IBOutlet NSWindow * window;
	//IBOutlet WebView * webView;
	IBOutlet NSTextView * logView;
	
	BOOL logViewScrolling;
	
	luaavLog * redirectStdOut;
	luaavLog * redirectStdErr;
	
	NSDictionary * attributeStdOut;
	NSDictionary * attributeStdErr;
	
	// this is the lua_State for the application itself
	lua_State * L;
	
	
	NSPipe * outputPipe;
	NSFileHandle * outputPipeReadHandle;
}

+ (luaavApp *)singleton;

-(IBAction)logClear:(id)sender;
-(IBAction)logScrolling:(id)sender;
-(IBAction)help:(id)sender;

- (lua_State *)createLuaState;
@end
