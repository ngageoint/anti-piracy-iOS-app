//
//  MapLayoutGuide.h
//  Asam
//
//  Created by William Newman on 9/10/14.
//
//

#import <Foundation/Foundation.h>

@interface MapLayoutGuide : NSObject <UILayoutSupport>

@property (nonatomic) CGFloat length;

-(id)initWithLength:(CGFloat)length;

@end

