#import "CommonViewController.h"

@protocol AsamUpdateDelegate <NSObject>

@optional

- (void)updateAsamFromDate;

@end

@interface SettingsViewController : CommonViewController

@property (nonatomic, strong) id<AsamUpdateDelegate> asamUpdateDelegate;

@end
