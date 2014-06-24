#import "LegalDetailsViewController_iPhone.h"

@interface LegalDetailsViewController_iPhone()

@property (nonatomic, weak) IBOutlet UITextView *detailText;

@end

@implementation LegalDetailsViewController_iPhone

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.titleString;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:self.fileName ofType:@"txt"];
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
    self.detailText.text = fileContents;
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
    [self setDetailText:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
