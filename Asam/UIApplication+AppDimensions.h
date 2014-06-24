//
//  UIApplication+AppDimensions.h
//  Asam
//
//  Created by Hicham Laoudi on 11/27/12.
//
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppDimensions)

+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
    //+(BOOL) isDeviceInLandscapeMode;
@end
