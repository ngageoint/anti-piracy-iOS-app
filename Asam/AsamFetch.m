//
//  AsamFeth.m
//  Asam
//
//  Created by Giat on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AsamFetch.h"

@implementation AsamFetch


+ (NSArray *)fetchAsamsWithDays:(NSString *)withDays{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];	
    [context setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
    return [context fetchObjectsForEntityName:@"Asam"];

    if(  [withDays isEqualToString:@"All"]){
        return [context fetchObjectsForEntityName:@"Asam"];
    }
    
    NSString *formattedDays =  [AsamUtility subtractDaysWithParamfromToday:withDays];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateofOccurrence >=%@", formattedDays];
    return [context fetchObjectsForEntityName:@"Asam" withPredicate:predicate];
}

@end
