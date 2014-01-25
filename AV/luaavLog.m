//
//  luaavRedirect.m
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import "luaavLog.h"

@implementation luaavLog

- (id) initWithObserver:(id)observer withFile:(FILE *)file withSelector:(SEL)selector
{
	if (self = [super init])
	{
		pipe = [[NSPipe pipe] retain];
		pipeReadHandle = [[pipe fileHandleForReading] retain];
		stream = file;
		
		/*
		 // set pipe nonblocking?
		 for(int n=0; n < 2; n++) {
			int f = fcntl(pipe[n], F_GETFL, 0);
			f |= O_NONBLOCK;
			fcntl(spipe[n], F_SETFL, f);
		 }
		 */
		
		oldfileno = dup(fileno(file));
		oldstream = fdopen(oldfileno, "w");
		
		dup2([[pipe fileHandleForWriting] fileDescriptor], fileno(file));
		
		[[NSNotificationCenter defaultCenter]	addObserver: observer
												selector: selector
												name: NSFileHandleReadCompletionNotification
												object: pipeReadHandle];
		[self poll];
	}
	return self;
}

-(void) dealloc
{
	[pipe release];
	[pipeReadHandle release];
	[super dealloc];
}


-(void) oldprint: (const char *)str
{
	fputs(str, oldstream);
}

-(void) poll {
	
	fflush(stream);
	[pipeReadHandle readInBackgroundAndNotify];
}

@end
