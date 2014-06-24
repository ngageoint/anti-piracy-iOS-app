#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol AsamSearchDelegate <NSObject>

@required
- (void)setPredicateForSearching:(NSPredicate *)predicateForSearching;

@end

@interface AsamSearch : CommonViewController

@property (nonatomic, strong) id asamSearchDelegate;

@end
