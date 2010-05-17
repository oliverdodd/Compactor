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
- (BOOL)cat:(NSArray *)paths to:(NSString *)outPath;
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

- (BOOL)cat:(NSArray *)paths to:(NSString *)outPath {
	// out
	FILE *outFile = fopen([outPath UTF8String],"w");
	if (outFile == NULL){
		return NO;
	}
	// files
	FILE *file;
	char c;
	for(NSString *path in paths){
		file = fopen([path UTF8String],"r");
		if (file == NULL){
			return NO;
		}
		while ((c=fgetc(file)) != EOF)
			fputc(c,outFile);
		fclose(file);
	}
	fclose(outFile);
	return YES;
}

- (BOOL)compress:(NSString *)outPath error:(NSString **)errorMessage {
	// combine
	if (![self cat:files to:outPath]) {
		*errorMessage = @"Unable to combine files";
		return NO;
	}
	// compress
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"compress.sh",@"-t",type,outPath,nil];
	// if (charset != nil) {
	// 	[args addObject:@"-charset"];
	// 	[args addObject:charset];
	// }
	// command
	command = [[NSTask alloc] init];
	[command setCurrentDirectoryPath:[[NSBundle mainBundle]resourcePath]];
	[command setLaunchPath:@"/bin/sh"];
	[command setArguments:args];
	*errorMessage = [command launchSynchronous];
	
	return [*errorMessage length] == 0;
}

- (void)finishedTask:(NSNotification *)aNotification {
	
}

@end
