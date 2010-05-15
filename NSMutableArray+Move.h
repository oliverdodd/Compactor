//
//  NSMutableArray+Move.h
//  Compactor
//
//  http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray (Move)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end
