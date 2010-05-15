//
//  AppDelegate.m
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-09.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//	http://01001111.net
//

#import "AppDelegate.h"
#import "Document.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL display:(BOOL)displayDocument error:(NSError **)outError {
	[(Document *)[self currentDocument] readFromURL:absoluteURL ofType:@"Document" error:outError];
	return [self currentDocument];
}

- (IBAction)newDocument:(id)sender {
	[super newDocument:sender];
}

@end
