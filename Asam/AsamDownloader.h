#import <Foundation/Foundation.h>

@interface AsamDownloader : NSObject

- (void)downloadAndSaveAsamsWithURL:(NSURL *)url completionBlock:(void(^)(BOOL success, NSError *error))block;

@end
