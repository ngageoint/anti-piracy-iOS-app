
#import <UIKit/UIKit.h>
#import "CommonViewController.h"

#define kConnectedKey @"connected"
#define kLastSyncDateKey @"lastsyncdate"
#define kShowDisclainer @"showDisclaimer"



@protocol AsamUpdateDelegate <NSObject>
- (void) updateAsamFromDate;
@end

@interface SettingsView : CommonViewController <UITableViewDelegate,UITableViewDataSource>{
    NSArray *settingsArray;
}

@property (nonatomic, strong)NSArray *settingsArray;
@property (nonatomic, strong)    id <AsamUpdateDelegate> asamUpdateDelegate;

- (IBAction)dismissView:(id)sender;
- (IBAction) syncNow:(id)sender;
- (void)switchAction:(UISwitch*)sender;
- (void)switchDisclaimer:(UISwitch*)sender;

- (void) updateAsam:(id)sender;
- (void) setUpBarTitle;
@end
