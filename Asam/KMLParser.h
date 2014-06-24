#import <Foundation/Foundation.h>

@class Asam;

@interface KMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) Asam *asam;
@property (nonatomic) NSUInteger dataElementType;
@property (nonatomic, strong) NSMutableArray *asams;

- (KMLParser *)initXMLParser;

@end
