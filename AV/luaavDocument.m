//
//  luaavDocument.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavDocument.h"

#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

@implementation luaavDocument

- (id)init
{
    self = [super init];
    if (self) {
		posix_path = NULL;
		posix_path_cstr = 0;
		task = NULL;
		outpipe = NULL;
		errpipe = NULL;
		watchThread = NULL;
		
		consoleViewScrolling = TRUE;
		
		NSFont * font = [[NSFont userFixedPitchFontOfSize:10.0] retain];
		attributeStdOut = [@{NSFontAttributeName: font,
							 NSForegroundColorAttributeName: [NSColor whiteColor]} retain];
		attributeStdErr = [@{NSFontAttributeName: font,
							 NSForegroundColorAttributeName: [NSColor orangeColor]} retain];
		
		fildes = 0;
		kq = kqueue();
		
		[[NSNotificationCenter defaultCenter]	addObserver: self
												 selector: @selector(appWillTerminateNotification:)
													 name: NSApplicationWillTerminateNotification
												   object: nil];
    }
    return self;
}

- (void) dealloc
{
	[self clear];
	if (posix_path) { [posix_path release]; posix_path = NULL; }
	if (watchThread) { [watchThread cancel]; [watchThread release]; }
	
	[super dealloc];
}

- (void) clear
{
	if (task) {
		NSLog(@"terminating task\n");
		[task terminate];
		[task release];
		task = NULL;
	}
	if (outpipe) { [outpipe release]; outpipe = NULL; }
	if (errpipe) { [errpipe release]; errpipe = NULL; }
}


-(IBAction)logClear:(id)sender {
	NSTextStorage * outputTextStorage = [consoleView textStorage];
	[outputTextStorage deleteCharactersInRange:NSMakeRange(0, [outputTextStorage length])];
}

-(IBAction)help:(id)sender {
	printf("help\n");
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://luaav.github.io/libluaav/index.html"]];
	//openFile: [[NSString stringWithUTF8String:luaav_app_path()] stringByAppendingPathComponent: @"/extra/docs/index.html"]
}

-(IBAction)logScrolling:(id)sender {
	consoleViewScrolling = !consoleViewScrolling;
	if (consoleViewScrolling) {
		[consoleView scrollRangeToVisible:NSMakeRange([[consoleView string] length], 0)];
	}
}

-(IBAction)stop:(id)sender {
	printf("stop\n");
	[self clear];
}

-(IBAction)reload:(id)sender {
	[self startRunning];
}

-(IBAction)edit:(id)sender {
	char cmd[4096];
	//printf("edit %s\n", [posix_path cStringUsingEncoding:NSASCIIStringEncoding]);
	sprintf(cmd, "open %s\n", [posix_path cStringUsingEncoding:NSASCIIStringEncoding]);
	printf("%s\n", cmd);
	system(cmd);
}

// currently disabled (no close button on main window).
- (void)windowWillClose:(NSNotification *)aNotification
{
	//[[NSApplication sharedApplication] terminate:self];
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"luaavDocument";
}

- (BOOL)readFromURL:(NSURL *)inAbsoluteURL ofType:(NSString *)inTypeName error:(NSError **)outError {
	[self clear];
	
	posix_path = [[inAbsoluteURL path] retain];
	posix_path_cstr = [posix_path cStringUsingEncoding:NSASCIIStringEncoding];
	
	watchThread = [[NSThread alloc] initWithTarget:self selector:@selector(watchInBackground) object:nil];
	[watchThread start];
	
	printf("opened %s\n", posix_path_cstr);
	
	return YES;
}

- (void)watchInBackground
{
	int status;
	struct kevent change;
	struct kevent event;
	
	fildes = open(posix_path_cstr, O_EVTONLY); //O_RDONLY);
	if(fildes <= 0) {
		printf("No such file %s...\n", posix_path_cstr);
		return;
	}
	
	EV_SET(&change, fildes, EVFILT_VNODE,
		   EV_ADD | EV_ENABLE | EV_CLEAR, //ONESHOT,
		   NOTE_WRITE, // | NOTE_DELETE | NOTE_EXTEND | NOTE_ATTRIB,
		   0, 0);
	
	status = kevent(kq, &change, 1, &event, 1, NULL);
	while (status > 0) {
		
		printf("file event %s\n", posix_path_cstr);
		
		[self performSelectorOnMainThread:@selector(startRunning) withObject:self waitUntilDone:YES];
		
		status = kevent(kq, &change, 1, &event, 1, NULL);
	}
	
	printf("watching complete\n");
	
	close(kq);
	close(fildes);
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	//NSLog(@"luaav nib loaded");
	
	[self startRunning];
}

- (void)startRunning
{
	[self clear];
	
	printf("------------------------------\n");
	
	//NSAttributedString * attr = [[NSAttributedString alloc] initWithString:posix_path attributes:attributeStdOut];
	//[[consoleView textStorage] appendAttributedString:attr];
	
	// do we also need to flush the pipes here?
	NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:@"-- begin\n" attributes:attributeStdErr] ;
	[[consoleView textStorage] appendAttributedString:attr];
	if (consoleViewScrolling)
		[consoleView scrollRangeToVisible:NSMakeRange([[consoleView string] length], 0)];
	
	// TODO: add to filewatcher
	
	///// SET UP PIPES /////
	
	outpipe = [[NSPipe alloc] init];
	errpipe = [[NSPipe alloc] init];
	
	outpipeReadHandle = [[outpipe fileHandleForReading] retain];
	errpipeReadHandle = [[errpipe fileHandleForReading] retain];
	
	/*
	 [[NSNotificationCenter defaultCenter]	addObserver: self
	 selector: @selector(stdOutNotification:)
	 name: NSFileHandleDataAvailableNotification
	 object: outpipeReadHandle];
	 [[NSNotificationCenter defaultCenter]	addObserver: self
	 selector: @selector(stdErrNotification:)
	 name: NSFileHandleDataAvailableNotification
	 object: errpipeReadHandle];
	 */
	
	[[NSNotificationCenter defaultCenter]	addObserver: self
											 selector: @selector(stdOutNotification:)
												 name: NSFileHandleReadCompletionNotification
											   object: outpipeReadHandle];
	[[NSNotificationCenter defaultCenter]	addObserver: self
											 selector: @selector(stdErrNotification:)
												 name: NSFileHandleReadCompletionNotification
											   object: errpipeReadHandle];
	
	// notify if the script terminates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(terminateNotification:)
												 name:NSTaskDidTerminateNotification
											   object:task];
	
	[outpipeReadHandle readInBackgroundAndNotify];
	[errpipeReadHandle readInBackgroundAndNotify];
	//[outpipeReadHandle waitForDataInBackgroundAndNotify];
	//[errpipeReadHandle waitForDataInBackgroundAndNotify];
	
	/*
	 http://www.cocoabuilder.com/archive/cocoa/170680-using-nstask-and-nspipe-to-perform-shell-script.html
	 
	 NSPipe *writePipe = [NSPipe pipe];
	 NSFileHandle *writeHandle = [writePipe
	 fileHandleForWriting];
	 
	 [writeHandle writeData:[NSData
	 dataWithContentsOfFile:@"/users/keithblount/Markdown/readme.markdown"]];
	 [writeHandle closeFile];
	 */
	
	///// SET UP TASK /////
	
	// run luajit from the resources folder:
	task = [[NSTask alloc] init];
	
	[task setLaunchPath: [NSString stringWithFormat:@"%@/modules/osx/luajit", [[NSBundle mainBundle] resourcePath]]];
	//[task setLaunchPath: [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"luajit"]];
	[task setArguments: [NSArray arrayWithObjects: [NSString stringWithFormat:@"%@/av.lua", [[NSBundle mainBundle] resourcePath]], posix_path, nil]];
	
	// set cwd to the source script
	[task setCurrentDirectoryPath:[posix_path stringByDeletingLastPathComponent]];
	
	// [task setEnvironment ];
	
	[task setStandardOutput: outpipe];
	[task setStandardError: errpipe];
	//[task setStandardInput: writePipe];
	
	[task launch];
}

- (void)stdOutNotification:(NSNotification *)notification
{
	@autoreleasepool {
		
		NSString *str = [[NSString alloc] initWithData:[[notification userInfo]
														objectForKey: NSFileHandleNotificationDataItem]
											  encoding: NSASCIIStringEncoding];
		//NSLog(@"out1 %@|%p", str, str);
		fprintf(stdout, "%s\n", [str cStringUsingEncoding:NSASCIIStringEncoding]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAttributedString * attr = [[NSAttributedString alloc] initWithString:str attributes:attributeStdOut];
			//NSLog(@"out2 %@|%p", str, str);
			
			[[consoleView textStorage] appendAttributedString:attr];
			if (consoleViewScrolling)
				[consoleView scrollRangeToVisible:NSMakeRange([[consoleView string] length], 0)];
		});
	}
}

- (void)stdErrNotification:(NSNotification *)notification
{
	@autoreleasepool {
		
		NSData * data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
		
		NSString *str = [[NSString alloc] initWithData:data
											  encoding: NSASCIIStringEncoding];
		fprintf(stderr, "%s\n", [str cStringUsingEncoding:NSASCIIStringEncoding]);
		//NSLog(@"err %p %@", str, str);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributeStdErr] ;
			//NSLog(@"err %p %@", str, str);
			
			[[consoleView textStorage] appendAttributedString:attr];
			if (consoleViewScrolling)
				[consoleView scrollRangeToVisible:NSMakeRange([[consoleView string] length], 0)];
		});
		
		//NSFileHandle * fh = [notification object];
		//[fh readInBackgroundAndNotify];
		
	}
}

// this is the notification when the script terminates itself (by error or natural end)
- (void)terminateNotification:(NSNotification *)notification
{
	// do we also need to flush the pipes here?
	NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString:@"-- end" attributes:attributeStdErr] ;
	//NSLog(@"err %p %@", str, str);
	
	[[consoleView textStorage] appendAttributedString:attr];
	if (consoleViewScrolling) {
		[consoleView scrollRangeToVisible:NSMakeRange([[consoleView string] length], 0)];
	}
	
	[self clear];
}

// this is the notification when the application quits:
- (void) appWillTerminateNotification:(NSNotification *)notification
{
	[self clear];
}

// this seems to be the best way to be notified when the document window is closed:
- (void) canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo;
{
	[self clear];
	[super canCloseDocumentWithDelegate:delegate shouldCloseSelector: shouldCloseSelector contextInfo: contextInfo];
}

@end
