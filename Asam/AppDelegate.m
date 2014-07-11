#import "AppDelegate.h"
#import "AsamDisclaimerView.h"
#import "AsamUtility.h"
#import "DSActivityView.h"
#import "MainView.h"
#import "MainViewController_iphone.h"
#import "OfflineMapUtility.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isDeviceInLandscapeMode:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

        // Override point for customization after application launch.
        self.viewController = [[MainView alloc] initWithNibName:@"MainView" bundle:nil];
        self.window.rootViewController = self.viewController;
    }
    else {
        
        // Override point for customization after application launch.
        self.mainViewController_iphone = [[MainViewController_iphone alloc] initWithNibName:@"MainViewController_iphone" bundle:nil];
        self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController_iphone];
        self.window.rootViewController = self.navController;
    }
    
    //initializing offline map polygons (potentially thread this)
    NSDictionary *geojson = [OfflineMapUtility dictionaryWithContentsOfJSONString:@"ne_110m_land"];
    NSMutableArray *featuresArray = [geojson objectForKey:@"features"];
    [OfflineMapUtility generateExteriorPolygons:featuresArray];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (self.disclaimerView_iphone.isViewLoaded && self.disclaimerView_iphone.view.window) {
            
            //view is visible -- dismiss it
            [self.disclaimerView_iphone dismissViewControllerAnimated:NO completion:nil];
        }
    }
    else if (self.disclaimerView_ipad.isViewLoaded && self.disclaimerView_ipad.view.window) {
        
        //view is visible -- dismiss it
        [self.disclaimerView_ipad dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:kShowDisclaimer] isEqual:@"No"]) {
        return;
    }
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.disclaimerView_iphone = [[DisclaimerViewController_iphone alloc]initWithNibName:@"DisclaimerViewController_iphone" bundle:nil];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self.navController presentViewController:self.disclaimerView_iphone animated:YES completion:nil];
        });
    }
    else {
        self.disclaimerView_ipad = [[AsamDisclaimerView alloc]initWithNibName:@"AsamDisclaimerView" bundle:nil];
        [self.disclaimerView_ipad setModalPresentationStyle:UIModalPresentationFormSheet];
        UIViewController *currentVC = [self getVisibleViewController];
        if (![currentVC isKindOfClass:[AsamDisclaimerView class]]) {
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [currentVC presentViewController:self.disclaimerView_ipad animated:YES completion:nil];
            });
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Asam" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"Asam.sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Asam.sqlite"]; 
    
    // Put down default db if it doesn't already exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:writableDBPath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Asam" ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:writableDBPath error:NULL];
        }
    }    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (UIViewController *)getVisibleViewController {
    UIViewController *viewController = nil;
    UIViewController *visibleViewController = nil;
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        viewController = navigationController.visibleViewController;
    }
    else {
        viewController = self.window.rootViewController;
    }
    while (visibleViewController == nil) {
        if (viewController.presentedViewController == nil) {
            visibleViewController = viewController;  
        }
        else {
            if ([viewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *)viewController.presentedViewController;
                viewController = navigationController.visibleViewController;
            }
            else {
                viewController = viewController.presentedViewController;
            }
        }
    }
    return visibleViewController;
}
  
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  YES;
}

- (BOOL)isDeviceInLandscapeMode:(NSNotification*)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        return TRUE;
    }
    return FALSE;
}

@end
