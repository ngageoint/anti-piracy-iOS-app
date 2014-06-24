#import "AsamCustomCell.h"

@interface AsamCustomCell() {
    REVClusterPin *_asam;
}

@property (nonatomic, strong) IBOutlet UILabel *dateOfOccurance;
@property (nonatomic, strong) IBOutlet UILabel *refNumber;
@property (nonatomic, strong) IBOutlet UILabel *aggressor;
@property (nonatomic, strong) IBOutlet UILabel *victim;

@end

@implementation AsamCustomCell

- (REVClusterPin *)asam {
    return _asam;
}

- (void)setAsam:(REVClusterPin *)newAsam {
    _asam = newAsam;
    self.dateOfOccurance.text = [AsamUtility getCellStringFromDate:_asam.dateofOccurrence];
    self.victim.text = _asam.victim;
    self.aggressor.text = _asam.aggressor;
    self.refNumber.text = _asam.referenceNumber;
    
    // set up the font size
    UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue Bold" size:14.0];
    [self.aggressor setFont:titleFont];
    [self.dateOfOccurance setFont:titleFont];
    [self.refNumber setFont:titleFont];
    [self.victim setFont:titleFont];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
