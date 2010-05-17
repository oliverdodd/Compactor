//
//  NSTask+launchSynchronous.m
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-16.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//

#import "NSTask+LaunchSynchronous.h"

@implementation NSTask (LaunchSynchronous)

- (NSString *)launchSynchronous {
	// io
    [self setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	NSPipe *outputPipe = [NSPipe pipe];
    [self setStandardOutput: outputPipe];
	[self setStandardError: outputPipe];
    NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
	//launch
	[self launch];
	// synchronous output
	return [[[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] 
								  encoding:NSUTF8StringEncoding] autorelease];
}

@end
