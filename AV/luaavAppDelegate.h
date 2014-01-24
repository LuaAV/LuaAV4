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

@interface luaavAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
@public
	IBOutlet NSWindow * window;
	//IBOutlet WebView * webView;
	IBOutlet NSTextView * logView;
	
	BOOL logViewScrolling;
	
	luaavLog * redirectStdOut;
	luaavLog * redirectStdErr;
	
	NSDictionary * attributeStdOut;
	NSDictionary * attributeStdErr;
}
-(IBAction)logClear:(id)sender;
-(IBAction)logScrolling:(id)sender;
-(IBAction)help:(id)sender;
@end
