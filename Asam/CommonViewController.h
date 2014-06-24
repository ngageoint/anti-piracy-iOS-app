#import <UIKit/UIKit.h>

@interface CommonViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *dateLabel;

- (void)setUpSettingsBarTitle;

@end
