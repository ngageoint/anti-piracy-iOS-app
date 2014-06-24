#import "AsamDownloader.h"
#import "AppDelegate.h"
#import "AsamFetch.h"

@implementation AsamDownloader

- (void)downloadAndSaveAsamsWithURL:(NSURL *)url completionBlock:(void(^)(BOOL success, NSError *error))block {

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data.length > 0 && connectionError == nil) {
            NSError *error;
            NSData *escapedData = [[self removeUnescapedCharacter:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:escapedData options:kNilOptions error:&error];
            if (error) {
                block(YES, nil);
            }
            else {
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
                [context setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
                for (NSDictionary *dict in parsedData) {
                    if (![self doesAsamReferenceNumberExistInDB:[dict objectForKey:@"Reference"]]) {
                        NSManagedObject *manageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Asam" inManagedObjectContext:context];
                        [manageObject setValue:[dict objectForKey:@"Victim"] forKey:@"victim"];
                        [manageObject setValue:[dict objectForKey:@"Aggressor"] forKey:@"aggressor"];
                        [manageObject setValue:[dict objectForKey:@"Reference"] forKey:@"referenceNumber"];
                        [manageObject setValue:[AsamUtility getDateFromString:[dict objectForKey:@"Date"]] forKey:@"dateofOccurrence"];
                        [manageObject setValue:[dict objectForKey:@"Subregion"] forKey:@"geographicalSubregion"];
                        [manageObject setValue:[[dict objectForKey:@"Description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"asamDescription"];
                        [manageObject setValue:[NSNumber numberWithDouble:[[dict objectForKey:@"lat"] doubleValue]] forKey:@"decimalLatitude"];
                        [manageObject setValue:[NSNumber numberWithDouble:[[dict objectForKey:@"lng"] doubleValue]] forKey:@"decimalLongitude"];
                        [manageObject setValue:[dict objectForKey:@"Latitude"] forKey:@"degreeLatitude"];
                        [manageObject setValue:[dict objectForKey:@"Longitude"] forKey:@"degreeLongitude"];
                    }
                }
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSDate* date = [NSDate date];
                NSDateFormatter* lastSynDateFormatter = [[NSDateFormatter alloc] init];
                lastSynDateFormatter.dateFormat = @"MM/dd/yyyy";
                NSString* formattedNewSyncDate = [lastSynDateFormatter stringFromDate:date];
                [prefs setObject:formattedNewSyncDate forKey:kLastSyncDateKey];
                [prefs synchronize];
                if (![context save:&error]) {
                    block(FALSE, error);
                }
                block(NO, nil);
            }
        }
        else {
            block(YES, nil);
        }
    }];
}

#pragma 
#pragma mark - remove Unescaped Character
- (NSString *)removeUnescapedCharacter:(NSString *)inputStr {
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputStr;
}

- (BOOL)doesAsamReferenceNumberExistInDB:(NSString *)refNumber {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"referenceNumber ==%@", refNumber];
    NSArray *results =  [context fetchObjectsForEntityName:@"Asam" withPredicate:predicate];
    return results.count > 0;
}

@end
