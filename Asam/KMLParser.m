#import "KMLParser.h"
#import "AppDelegate.h"
#import "Asam.h"
#import "AsamUtility.h"


@interface KMLParser()

@property (nonatomic, strong) NSMutableString *currentElementValue;

@end


@implementation KMLParser

- (KMLParser *)initXMLParser {
    if (self =  [super init]) {
        _asams = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"kml"]) {
        return;
    }
    else if ([elementName isEqualToString:@"Placemark"]) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        self.asam = [[Asam alloc] initWithEntity:[NSEntityDescription entityForName:@"Asam" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    }
	else if ([elementName isEqualToString:@"Data"]) {
		NSString *attributeValue = [attributeDict objectForKey:@"name"];
		if ([attributeValue isEqualToString:@"SubRegion"]) {
            self.dataElementType = 1;
        }
		else if ([attributeValue isEqualToString:@"Aggressor"]) {
            self.dataElementType = 2;
        }
        else if ([attributeValue isEqualToString:@"Date of Occurrence"]) {
            self.dataElementType = 3;
        }
        else if ([attributeValue isEqualToString:@"Reference Number"]) {
            self.dataElementType = 4;
        }
		else {
            self.dataElementType = 0;
        }
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *) string {
    if (!self.currentElementValue) {
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [self.currentElementValue appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"kml"]) {
        return;
    }
    else if ([elementName isEqualToString:@"Placemark"]) {
        [self.asams addObject:self.asam];
    }
    else if([elementName isEqualToString:@"name"]) {
        self.asam.victim = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else if ([elementName isEqualToString:@"coordinates"]) {
    }
    else if ([elementName isEqualToString:@"description"]) {
        self.asam.asamDescription = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
	else if ([elementName isEqualToString:@"value"]) {
		switch (self.dataElementType) {
			case 1:
                self.asam.geographicalSubregion = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				break;
                
			case 2:
                self.asam.aggressor = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				break;
                
            case 3:
                self.asam.dateofOccurrence = [AsamUtility getDateFromString:[self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				break;
                
            case 4:
                self.asam.referenceNumber = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				break;
                
			default:
                break;
		}
	}
    self.currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %li) URL", (long)[parseError code]];
    NSLog(@"error parsing XML: %@", errorString);
}

@end