#import <UIKit/UIKit.h>


@protocol SubRegionDelegate <NSObject>

@required
- (void)setPredicate:(NSPredicate *)predicateForSubregions;
- (void)isDeviceInLandscapeMode:(BOOL)value;

@end


@interface SubRegionView : UIViewController

@property (nonatomic, strong) id<SubRegionDelegate> subRegionDelegate;

@end
