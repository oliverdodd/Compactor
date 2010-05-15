//
//  Compactor.h
//  Compactor
//
//  Created by Oliver C Dodd on 2010-05-09.
//  Copyright 2010 Oliver C Dodd. All rights reserved.
//	http://01001111.net
//

#import <Cocoa/Cocoa.h>


@interface Compactor : NSObject {
	NSArray *files;
	NSString *type;
	NSString *charset;
	
	NSTask *command;
	
	id delegate;
}
@property(nonatomic,retain) NSArray *files;
@property(nonatomic,retain) NSString *type;
@property(nonatomic,retain) NSString *charset;
@property(nonatomic,retain) id delegate;

-(BOOL)compress:(NSString *)outPath error:(NSString **)errorMessage;

@end
