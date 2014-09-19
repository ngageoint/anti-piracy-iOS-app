//
//  MapLayoutGuide.m
//  Asam
//
//  Created by William Newman on 9/10/14.
//
//

#import "MapLayoutGuide.h"

@implementation MapLayoutGuide

@synthesize length = _insetLength;

- (id)initWithLength:(CGFloat)insetlength
{
    self = [super init];
    if (self) {
        _insetLength = insetlength;
    }
    return self;
}

@end