//
//  Document.h
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-09.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//	http://01001111.net
//

#import <Cocoa/Cocoa.h>
#import "Compactor.h"

@interface Document : NSDocument<NSTableViewDelegate, NSTableViewDataSource> {
	Compactor *compactor;
	NSMutableArray *files;
	NSString *fileType;
	
	IBOutlet NSTableView *table;
	IBOutlet NSButton *plusButton;
	IBOutlet NSButton *minusButton;
	IBOutlet NSButton *compactButton;
	IBOutlet NSImageView *image;

	NSAlert *alert;
	IBOutlet NSProgressIndicator *progressIndicator;
}
@property(nonatomic,retain) IBOutlet NSTableView *table;

- (IBAction)removeSelectedItems:(id)sender;

@end
