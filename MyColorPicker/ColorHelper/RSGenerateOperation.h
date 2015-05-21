//
//  GenerateOperation.h
//  RSColorPicker
//
//  Created by Ryan on 7/22/13.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-no-attribute"

@class ANImageBitmapRep;

@interface RSGenerateOperation : NSOperation

-(id)initWithDiameter:(CGFloat)diameter andPadding:(CGFloat)padding;

@property (readonly) CGFloat diameter;
@property (readonly) CGFloat padding;

@property ANImageBitmapRep *bitmap;

@end

#pragma clang diagnostic pop