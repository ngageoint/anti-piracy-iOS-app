#import <UIKit/UIKit.h>
#import "CommonViewController.h"


@protocol SubRegionDelegate <NSObject>

@required
- (void)setPredicate:(NSPredicate *)predicateForSubregions;
- (void)isDeviceInLandscapeMode:(BOOL)value;

@end


@interface SubRegionView : CommonViewController

@property (nonatomic, strong) id<SubRegionDelegate> subRegionDelegate;

@end
