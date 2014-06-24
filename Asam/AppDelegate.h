#import <UIKit/UIKit.h>
#import "DisclaimerViewController_iphone.h"
#import "AsamDisclaimerView.h"


@class MainView, MainViewController_iphone;

#define kLastSyncDateKey @"lastsyncdate"
#define kShowDisclaimer @"showDisclaimer"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MainView *viewController;
@property (nonatomic, strong) MainViewController_iphone *mainViewController_iphone;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) DisclaimerViewController_iphone *disclaimerView_iphone;
@property (nonatomic, strong) AsamDisclaimerView *disclaimerView_ipad;

- (BOOL)isDeviceInLandscapeMode:(NSNotification*)notification;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
