//
//  NSMutableArray+Move.m
//  Compactor
//
//  http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/
//

#import "NSMutableArray+Move.h"


@implementation NSMutableArray (Move)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
	if (to != from) {
		id obj = [self objectAtIndex:from];
		[obj retain];
		[self removeObjectAtIndex:from];
		if (to >= [self count]) {
			[self addObject:obj];
		} else {
			[self insertObject:obj atIndex:to];
		}
		[obj release];
	}
}

@end
