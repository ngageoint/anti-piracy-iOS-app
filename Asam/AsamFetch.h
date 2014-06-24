//
//  AsamFeth.h
//  Asam
//
//  Created by Giat on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObjectContext-EasyFetch.h"
#import "AppDelegate.h"
#import "AsamUtility.h"

@interface AsamFetch : NSObject

+ (NSArray *)fetchAsamsWithDays:(NSString *)withDays;
@end






