//
//  luaavRedirect.h
//  AV
//
//  Created by Graham Wakefield on 1/23/14.
//  Copyright (c) 2014 LuaAV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface luaavLog : NSObject
{
	NSPipe * pipe;
	NSFileHandle * pipeReadHandle;
	FILE * stream;
	
	int oldfileno;
	FILE * oldstream;
}

-(void)poll;
-(void) oldprint: (const char *)str;
-(id)initWithObserver:(id)observer withFile:(FILE *)file withSelector:(SEL)selector;

/*
+ (void)flush;
+ (id)stdoutRedirect;
+ (id)stderrRedirect;

- (bool)isActive;
- (void)readPipe;
- (void)readPipeDirect;
*/
@end
