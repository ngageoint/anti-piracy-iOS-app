#import "LegalDetailsViewController_ipad.h"

@interface LegalDetailsViewController_ipad()

@property (nonatomic, weak) IBOutlet UITextView *detailText;

@end

@implementation LegalDetailsViewController_ipad

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.titleString;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:self.fileName ofType:@"txt"];
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
    self.detailText.text = fileContents;
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.detailText.font = titleFont;
    self.detailText.textColor = [UIColor clearColor];
    self.detailText.textColor = [UIColor whiteColor];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.detailText.backgroundColor = [UIColor blackColor];
    }
    else {
        self.detailText.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    }
}

- (void)viewDidUnload {
    self.detailText = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end