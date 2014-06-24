#import "DisclaimerViewController_iphone.h"

@interface DisclaimerViewController_iphone ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *topTollBar;
@property (weak, nonatomic) IBOutlet UITextView *disclaimerTextView;

@end

@implementation DisclaimerViewController_iphone


#pragma 
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.disclaimerTextView.backgroundColor = [UIColor blackColor];
        self.toolBar.tintColor = [UIColor whiteColor];
    }
    else {
        self.disclaimerTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.toolBar = nil;
    self.topTollBar = nil;
    self.disclaimerTextView = nil;
    [super viewDidUnload];
}

- (IBAction)dismissDisclaimer:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeApplication:(id)sender {
    exit(0);
}

@end
