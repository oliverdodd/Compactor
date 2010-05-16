//
//  Document.m
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-09.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//	http://01001111.net
//

#import "Document.h"
#import "NSMutableArray+Move.h"

@interface Document (Private)
- (BOOL)checkFileType:(NSURL *)url;
- (BOOL)addFile:(NSURL *)url;
- (void)alertWithMessage:(NSString *)msg information:(NSString *)info;
- (void)alertWithMessage:(NSString *)msg;
- (void)updateButtons;
- (void)showLoading;
- (void)hideLoading;
@end

@implementation Document
@synthesize table;

/*-----------------------------------------------------------------------------\
 |	initialization
 \----------------------------------------------------------------------------*/
#pragma mark initialization
- (id)init {
    self = [super init];
    if (self) {
		files = [[NSMutableArray alloc] init];
		compactor = [[Compactor alloc] init];
		[self updateChangeCount:NSChangeCleared];
    }
    return self;
}

/*-----------------------------------------------------------------------------\
 |	window
 \----------------------------------------------------------------------------*/
#pragma mark window
- (NSString *)windowNibName {
    return @"Compactor";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
    [super windowControllerDidLoadNib:aController];
	NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType,nil];
	[table registerForDraggedTypes:dragTypes];
}

/*-----------------------------------------------------------------------------\
 |	save
 \----------------------------------------------------------------------------*/
#pragma mark save
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	if (files.count < 1) {
		[self alertWithMessage:@"You haven't added any files."];
		return NO;
	}
	DLog(@"Saving to %@",absoluteURL);
	
	[self showLoading];
	
	NSString *errorMessage;
	compactor.files = files;
	compactor.type = fileType;
	BOOL result = [compactor compress:[absoluteURL relativePath] error:&errorMessage];
	
	[self hideLoading];
	
	if (!result && outError != NULL) {
		NSLog(@"Compact Error: @%", errorMessage);
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Unable to compact files." forKey:NSLocalizedDescriptionKey];
		[errorDetail setValue:@"Unable to compact files.  Verify the syntax of your includes and try again."
					   forKey:NSLocalizedRecoverySuggestionErrorKey];
		// [errorDetail setValue:errorMessage forKey:NSLocalizedFailureReasonErrorKey];
		*outError = [NSError errorWithDomain:@"compact" code:1 userInfo:errorDetail];
	}
	
	return result;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
	SEL action = [anItem action];
	if (action == @selector(saveDocument:) || action == @selector(saveDocumentAs:)) {
		return files.count > 0;
	} else {
		return [super validateUserInterfaceItem:anItem];
	}
}

/*-----------------------------------------------------------------------------\
 |	open
 \----------------------------------------------------------------------------*/
#pragma mark open

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	return [self addFile:absoluteURL];
}

- (BOOL)checkFileType:(NSURL *)url {
	NSString *ext = [[url pathExtension] lowercaseString];
	if (fileType == nil) {
		return [fileType compare:@"js"] == NSOrderedSame ||
				[fileType compare:@"css"] == NSOrderedSame;
	} else if ([fileType compare:ext] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)addFile:(NSURL *)url {
	NSString *ext = [[url pathExtension] lowercaseString];
	// DLog(@"ext: %@, fileType: %@", ext, fileType);
	if (fileType == nil) {
		fileType = [NSString stringWithString:ext];
		[self _setDisplayName:[NSString stringWithFormat:@"%@.%@",[self displayName],fileType]];
	}
	if ([self checkFileType:url]) {
		fileType = [NSString stringWithString:ext];
		DLog(@"adding file: %@",url);
		[files addObject:[url relativePath]];
		[self updateChangeCount:NSChangeDone];
		[self updateButtons];
		[table reloadData];
		return YES;
	} else {
		[self alertWithMessage:@"Files must all be of the same type."];
		return NO;
	}
}

/*-----------------------------------------------------------------------------\
 |	remove
 \----------------------------------------------------------------------------*/
#pragma mark remove
- (IBAction)removeSelectedItems:(id)sender {
	NSInteger count = [table numberOfSelectedRows];
	NSInteger index = [[table selectedRowIndexes] firstIndex];
	
	int i;
	for(i = 0; i < count; i++) {
		[files removeObjectAtIndex:index];
	}
	[self updateChangeCount:(files.count > 0 ? NSChangeDone : NSChangeCleared)];
	[self updateButtons];
	[table reloadData];
}

/*-----------------------------------------------------------------------------\
 |	alert
 \----------------------------------------------------------------------------*/
#pragma mark alert

- (void)alertWithMessage:(NSString *)msg information:(NSString *)info {
	if (alert == nil) {
		alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setAlertStyle:NSCriticalAlertStyle];
	}
	[alert setMessageText:msg];
	if (info != nil) {
		[alert setInformativeText:info];
	}
	[alert runModal];
}

- (void)alertWithMessage:(NSString *)msg {
	[self alertWithMessage:msg information:nil];
}

/*-----------------------------------------------------------------------------\
 |	table
 \----------------------------------------------------------------------------*/
#pragma mark table

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [files count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSParameterAssert(rowIndex >= 0 && rowIndex < [files count]);
	return [files objectAtIndex:rowIndex];
}

/*-----------------------------------------------------------------------------\
 |	drag and drop
 \----------------------------------------------------------------------------*/
#pragma mark drag_and_drop

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
	NSArray *fileArray = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	NSDragOperation dragOperation = [info draggingSourceOperationMask];
	
	DLog(@"pasteboard data %@",fileArray);
	DLog(@"drag operation %i / %i",dragOperation,operation);
	DLog(@"row %i",row);
	
	if (dragOperation & NSDragOperationPrivate) {
		NSInteger i;
		for (NSString *path in fileArray) {
			i = [files indexOfObject:path];
			if (i < row) row--;
			[files moveObjectFromIndex:i toIndex:row];
			row++;
			
		}
	} else if (dragOperation & NSDragOperationCopy) {
		for (NSString *path in fileArray) {
			[self addFile:[NSURL URLWithString:path]];
			[files moveObjectFromIndex:([files count] - 1) toIndex:row];
			row++;
		}
	}
	[table reloadData];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
	NSArray *fileArray = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	if (op == NSTableViewDropOn) {
		return NSDragOperationNone;
	}
	for (NSString *path in fileArray) {
		if (![self checkFileType:[NSURL URLWithString:path]])
			return NSDragOperationNone;
	}
	return [info draggingSourceOperationMask];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    // grab selected files
	NSMutableArray *selectedFiles = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	[rowIndexes enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
		[selectedFiles addObject:[files objectAtIndex:idx]];
    }];
	// Copy the row numbers to the pasteboard.
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
    [pboard setPropertyList:selectedFiles forType:NSFilenamesPboardType];
    return YES;
}

/*-----------------------------------------------------------------------------\
 |	ui
 \----------------------------------------------------------------------------*/
#pragma mark ui

- (void)updateButtons {
	[compactButton setEnabled:(files.count > 0)];
}

- (void)showLoading {
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
}
	
- (void)hideLoading {
	[progressIndicator setHidden:YES];
	[progressIndicator stopAnimation:self];
}

/*-----------------------------------------------------------------------------\
 |	dealloc
 \----------------------------------------------------------------------------*/
- (void)dealloc {
	[super dealloc];
	[files dealloc];
	[compactor dealloc];
}

@end
