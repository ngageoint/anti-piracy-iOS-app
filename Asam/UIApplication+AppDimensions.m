//
//  UIApplication+AppDimensions.m
//  Asam
//
//  Created by Hicham Laoudi on 11/27/12.
//
//

#import "UIApplication+AppDimensions.h"

@implementation UIApplication (AppDimensions)


+(CGSize) currentSize {
    return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

//+(BOOL) isDeviceInLandscapeMode {
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
//    return orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight;
//
//}

@end
