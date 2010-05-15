//
//  Compactor.m
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-09.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//	http://01001111.net
//

#import "Compactor.h"

@interface Compactor (Private)
- (void)finishedTask:(NSNotification *)aNotification;
@end

@implementation Compactor
@synthesize files, type, charset, delegate;

- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(finishedTask:) 
												 name:NSTaskDidTerminateNotification 
											   object:nil];
	command = nil;
	return self;
}

-(BOOL)compress:(NSString *)outPath error:(NSString **)errorMessage {
	// args
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"compact.sh",@"-t",type,@"-o",outPath,nil];
	if (charset != nil) {
		[args addObject:@"-charset"];
		[args addObject:charset];
	}
	[args addObjectsFromArray:files];
	
	// command
	command = [[NSTask alloc] init];
	[command setCurrentDirectoryPath:[[NSBundle mainBundle]resourcePath]];
	[command setLaunchPath:@"/bin/sh"];
	[command setArguments:args];
	
	// io
    [command setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	NSPipe *outputPipe = [NSPipe pipe];
    [command setStandardOutput: outputPipe];
	[command setStandardError: outputPipe];
    NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
	
	// run
	DLog(@"running command: %@ %@",[command launchPath],[command arguments]);
	[command launch];
	// synchronous
	*errorMessage = [[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] encoding: NSUTF8StringEncoding]; 
	DLog(@"output: %@",*errorMessage);
	
	return [*errorMessage length] == 0;
}

- (void)finishedTask:(NSNotification *)aNotification {
	
}

@end
