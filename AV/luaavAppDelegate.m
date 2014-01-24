//
//  luaavAppDelegate.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavAppDelegate.h"

@implementation luaavAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[NSApp setDelegate:self];
	
	logViewScrolling = TRUE;
	
	NSFont * font = [NSFont userFixedPitchFontOfSize:11.0];
	attributeStdOut = @{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor whiteColor]};
	attributeStdErr = @{NSFontAttributeName: font,
						NSForegroundColorAttributeName: [NSColor orangeColor]};
	
	redirectStdOut = [[luaavLog alloc] initWithObserver:self withFile:(stdout) withSelector:@selector(luaavRedirectStdOutNotification:)];
	
	redirectStdErr = [[luaavLog alloc] initWithObserver:self withFile:(stderr) withSelector:@selector(luaavRedirectStdErrNotification:)];
	
	//[webView setMainFrameURL:@"http://www.google.com/"];
	//[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
	
	for (int i=0; i<100; i++) {
		fprintf(stdout, "stdout test\n");
		fprintf(stderr, "stderr test\n");
	}
}

- (void)luaavRedirectStdOutNotification:(NSNotification *)notification
{
	
	[redirectStdOut poll];
	
	NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
													objectForKey: NSFileHandleNotificationDataItem]
										  encoding: NSASCIIStringEncoding];
	
	[redirectStdOut oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
	
	//dispatch_async(dispatch_get_main_queue(), ^{
	NSAttributedString* attr = [[NSAttributedString alloc] initWithString:str attributes:attributeStdOut];
	
	[[logView textStorage] appendAttributedString:attr];
	if (logViewScrolling)
		[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
    //});
}

- (void)luaavRedirectStdErrNotification:(NSNotification *)notification
{
	
	[redirectStdErr poll];
	
	NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
													objectForKey: NSFileHandleNotificationDataItem]
										  encoding: NSASCIIStringEncoding];
	
	[redirectStdErr oldprint:[str cStringUsingEncoding:NSASCIIStringEncoding]];
	
	//dispatch_async(dispatch_get_main_queue(), ^{
	NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributeStdErr];
	
	[[logView textStorage] appendAttributedString:attr];
	if (logViewScrolling)
		[logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];
    //});
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