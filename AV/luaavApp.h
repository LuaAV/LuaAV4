//
//  luaavAppDelegate.h
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface luaavApp : NSObject <NSApplicationDelegate, NSWindowDelegate> {
@public
	IBOutlet NSWindow * window;
	//IBOutlet WebView * webView;
}

+ (luaavApp *)singleton;
@end
